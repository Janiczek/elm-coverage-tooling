module Instrument exposing (instrument)

import Dict exposing (Dict)
import Elm.Syntax.Declaration exposing (Declaration)
import Elm.Syntax.Expression exposing (Expression)
import Elm.Syntax.File exposing (File)
import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.Module
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node exposing (Node(..))
import Elm.Syntax.Pattern exposing (Pattern)
import Elm.Syntax.Range
import InstrumentState exposing (InstrumentState)
import PointId exposing (PointId)
import PointMetadata exposing (PointMetadata)
import Random
import Range exposing (Range)


{-| Regions can overlap.
Later, we'll use a sweep algorithm to show only the innermost count (thus, even
if the whole if-expr gets tracked as visited, we'll show 0 for the unvisited
branch).
-}
instrument : File -> ( File, Dict PointId PointMetadata )
instrument file =
    let
        moduleName : String
        moduleName =
            file.moduleDefinition
                |> Elm.Syntax.Node.value
                |> Elm.Syntax.Module.moduleName
                |> String.join "."

        result =
            List.foldl
                instrumentDecl
                (InstrumentState.init moduleName)
                file.declarations
    in
    ( { file
        | declarations = result.newDeclarations
        , imports = addTestCoverageImport file.imports
      }
    , Dict.fromList result.metadataList
    )


addTestCoverageImport : List (Node Import) -> List (Node Import)
addTestCoverageImport imports =
    let
        testCoverageModuleName : List String
        testCoverageModuleName =
            [ "Test", "Coverage" ]

        hasTestCoverageImport : Node Import -> Bool
        hasTestCoverageImport importNode =
            let
                importModuleName : ModuleName
                importModuleName =
                    importNode
                        |> Elm.Syntax.Node.value
                        |> .moduleName
                        |> Elm.Syntax.Node.value
            in
            importModuleName == testCoverageModuleName
    in
    if List.any hasTestCoverageImport imports then
        imports

    else
        let
            newImportNode : Node Import
            newImportNode =
                Node Elm.Syntax.Range.empty
                    { moduleName = Node Elm.Syntax.Range.empty testCoverageModuleName
                    , moduleAlias = Nothing
                    , exposingList = Nothing
                    }
        in
        newImportNode :: imports


instrumentDecl : Node Declaration -> InstrumentState -> InstrumentState
instrumentDecl declNode acc =
    let
        declRange : Range
        declRange =
            Elm.Syntax.Node.range declNode

        doNothing : () -> InstrumentState
        doNothing () =
            { acc | newDeclarations = declNode :: acc.newDeclarations }
    in
    case Elm.Syntax.Node.value declNode of
        Elm.Syntax.Declaration.FunctionDeclaration fn ->
            instrumentFnDecl fn declRange acc

        Elm.Syntax.Declaration.AliasDeclaration typeAlias ->
            doNothing ()

        Elm.Syntax.Declaration.CustomTypeDeclaration type_ ->
            doNothing ()

        Elm.Syntax.Declaration.PortDeclaration _ ->
            doNothing ()

        Elm.Syntax.Declaration.InfixDeclaration _ ->
            doNothing ()

        Elm.Syntax.Declaration.Destructuring patternNode exprNode ->
            instrumentDestructuringDecl patternNode exprNode declRange acc


instrumentFnDecl : Elm.Syntax.Expression.Function -> Range -> InstrumentState -> InstrumentState
instrumentFnDecl fn declRange state =
    let
        fnImpl : Elm.Syntax.Expression.FunctionImplementation
        fnImpl =
            Elm.Syntax.Node.value fn.declaration

        declarationName : String
        declarationName =
            Elm.Syntax.Node.value fnImpl.name

        ( instrumentedExpr, newState ) =
            instrumentExprWithCategory fnImpl.expression declarationName "declaration" state

        newFnImpl : Elm.Syntax.Expression.FunctionImplementation
        newFnImpl =
            { fnImpl | expression = instrumentedExpr }

        newFn : Elm.Syntax.Expression.Function
        newFn =
            { fn | declaration = Elm.Syntax.Node.map (always newFnImpl) fn.declaration }

        newDecl : Node Declaration
        newDecl =
            Node declRange (Elm.Syntax.Declaration.FunctionDeclaration newFn)
    in
    { newState | newDeclarations = newDecl :: newState.newDeclarations }


instrumentDestructuringDecl : Node Pattern -> Node Expression -> Range -> InstrumentState -> InstrumentState
instrumentDestructuringDecl patternNode exprNode declRange state =
    let
        ( instrumentedExpr, newState ) =
            instrumentExprWithCategory exprNode "_destructuring" "declaration" state

        newDecl : Node Declaration
        newDecl =
            Node declRange (Elm.Syntax.Declaration.Destructuring patternNode instrumentedExpr)
    in
    { newState | newDeclarations = newDecl :: newState.newDeclarations }


instrumentExpr : Node Elm.Syntax.Expression.Expression -> String -> InstrumentState -> ( Node Elm.Syntax.Expression.Expression, InstrumentState )
instrumentExpr exprNode declarationName state =
    instrumentExprHelp exprNode declarationName Nothing state


instrumentExprWithCategory : Node Elm.Syntax.Expression.Expression -> String -> String -> InstrumentState -> ( Node Elm.Syntax.Expression.Expression, InstrumentState )
instrumentExprWithCategory exprNode declarationName category state =
    instrumentExprHelp exprNode declarationName (Just category) state


{-| Single traversal: Maybe category = Just cat when we may add a point at this node (with that category), Nothing = recurse only.
-}
instrumentExprHelp : Node Elm.Syntax.Expression.Expression -> String -> Maybe String -> InstrumentState -> ( Node Elm.Syntax.Expression.Expression, InstrumentState )
instrumentExprHelp exprNode declarationName mode state =
    let
        exprRange : Range
        exprRange =
            Elm.Syntax.Node.range exprNode

        doNothing : () -> ( Node Elm.Syntax.Expression.Expression, InstrumentState )
        doNothing () =
            ( exprNode, state )

        maybeAddPoint : String -> ( Node Elm.Syntax.Expression.Expression, InstrumentState )
        maybeAddPoint category =
            let
                ( instrumentedInnerExpr, stateAfterRecurse ) =
                    instrumentExprHelp exprNode declarationName Nothing state

                ( pointId, newSeed ) =
                    Random.step PointId.generator stateAfterRecurse.seed

                metadata : PointMetadata
                metadata =
                    { moduleName = state.moduleName
                    , moduleFilePath = state.moduleFilePath
                    , declarationName = declarationName
                    , range = exprRange
                    , category = category
                    }

                newState : InstrumentState
                newState =
                    { stateAfterRecurse
                        | seed = newSeed
                        , metadataList = ( pointId, metadata ) :: stateAfterRecurse.metadataList
                    }

                wrappedExpr : Node Elm.Syntax.Expression.Expression
                wrappedExpr =
                    instrumentedInnerExpr
                        |> wrapWithTracking pointId exprRange
            in
            ( wrappedExpr, newState )
    in
    case Elm.Syntax.Node.value exprNode of
        Elm.Syntax.Expression.Application exprs ->
            let
                ( instrumentedExprs, newState ) =
                    instrumentExprList exprs declarationName state
            in
            ( Node exprRange (Elm.Syntax.Expression.Application instrumentedExprs)
            , newState
            )

        Elm.Syntax.Expression.OperatorApplication op dir left right ->
            if op == "<|" || op == "|>" then
                let
                    ( instLeft, state1 ) =
                        instrumentExprHelp left declarationName mode state

                    ( instRight, state2 ) =
                        instrumentExprHelp right declarationName mode state1
                in
                ( Node exprRange (Elm.Syntax.Expression.OperatorApplication op dir instLeft instRight)
                , state2
                )

            else if op == "&&" || op == "||" then
                let
                    ( instLeft, state1 ) =
                        instrumentExprHelp left declarationName (Just "subexpression") state

                    ( instRight, state2 ) =
                        instrumentExprHelp right declarationName (Just "subexpression") state1
                in
                ( Node exprRange (Elm.Syntax.Expression.OperatorApplication op dir instLeft instRight)
                , state2
                )

            else
                case mode of
                    Just category ->
                        maybeAddPoint category

                    Nothing ->
                        let
                            ( instLeft, state1 ) =
                                instrumentExprHelp left declarationName Nothing state

                            ( instRight, state2 ) =
                                instrumentExprHelp right declarationName Nothing state1
                        in
                        ( Node exprRange (Elm.Syntax.Expression.OperatorApplication op dir instLeft instRight)
                        , state2
                        )

        Elm.Syntax.Expression.IfBlock condition thenBranch elseBranch ->
            let
                ( instCondition, state1 ) =
                    instrumentExprHelp condition declarationName (Just "subexpression") state

                ( instThen, state2 ) =
                    instrumentExprHelp thenBranch declarationName (Just "if-branch") state1

                ( instElse, state3 ) =
                    instrumentExprHelp elseBranch declarationName (Just "if-branch") state2
            in
            ( Node exprRange (Elm.Syntax.Expression.IfBlock instCondition instThen instElse)
            , state3
            )

        Elm.Syntax.Expression.Negation inner ->
            let
                ( instInner, newState ) =
                    instrumentExprHelp inner declarationName Nothing state
            in
            ( Node exprRange (Elm.Syntax.Expression.Negation instInner)
            , newState
            )

        Elm.Syntax.Expression.TupledExpression exprs ->
            let
                ( instrumentedExprs, newState ) =
                    instrumentExprListWithCategory exprs declarationName "subexpression" state
            in
            ( Node exprRange (Elm.Syntax.Expression.TupledExpression instrumentedExprs)
            , newState
            )

        Elm.Syntax.Expression.ParenthesizedExpression inner ->
            let
                ( instInner, newState ) =
                    instrumentExprHelp inner declarationName mode state
            in
            ( Node exprRange (Elm.Syntax.Expression.ParenthesizedExpression instInner)
            , newState
            )

        Elm.Syntax.Expression.LetExpression letBlock ->
            let
                ( instrumentedDecls, state1 ) =
                    List.foldr
                        (\declNode ( acc, state_ ) ->
                            let
                                ( instDecl, newState_ ) =
                                    instrumentLetDeclaration declNode declarationName state_
                            in
                            ( instDecl :: acc, newState_ )
                        )
                        ( [], state )
                        letBlock.declarations

                ( instLetExpr, state2 ) =
                    instrumentExprHelp letBlock.expression declarationName (Just "declaration") state1

                newLetBlock : Elm.Syntax.Expression.LetBlock
                newLetBlock =
                    { declarations = instrumentedDecls
                    , expression = instLetExpr
                    }
            in
            ( Node exprRange (Elm.Syntax.Expression.LetExpression newLetBlock)
            , state2
            )

        Elm.Syntax.Expression.CaseExpression caseBlock ->
            let
                ( instExpr, state1 ) =
                    instrumentExprHelp caseBlock.expression declarationName (Just "subexpression") state

                ( instrumentedCases, state2 ) =
                    List.foldr
                        (\( pattern, caseExpr ) ( acc, state_ ) ->
                            let
                                ( instCaseExpr, newState_ ) =
                                    instrumentExprHelp caseExpr declarationName (Just "case-branch") state_
                            in
                            ( ( pattern, instCaseExpr ) :: acc, newState_ )
                        )
                        ( [], state1 )
                        caseBlock.cases

                newCaseBlock : Elm.Syntax.Expression.CaseBlock
                newCaseBlock =
                    { expression = instExpr
                    , cases = instrumentedCases
                    }
            in
            ( Node exprRange (Elm.Syntax.Expression.CaseExpression newCaseBlock)
            , state2
            )

        Elm.Syntax.Expression.LambdaExpression lambda ->
            let
                ( instExpr, stateAfterRecurse ) =
                    instrumentExprHelp lambda.expression declarationName Nothing state

                ( pointId, newSeed ) =
                    Random.step PointId.generator stateAfterRecurse.seed

                metadata : PointMetadata
                metadata =
                    { moduleName = state.moduleName
                    , moduleFilePath = state.moduleFilePath
                    , declarationName = declarationName
                    , range = exprRange
                    , category = "lambda"
                    }

                newState : InstrumentState
                newState =
                    { stateAfterRecurse
                        | seed = newSeed
                        , metadataList = ( pointId, metadata ) :: stateAfterRecurse.metadataList
                    }

                bodyRange : Range
                bodyRange =
                    Elm.Syntax.Node.range lambda.expression

                wrappedBody : Node Elm.Syntax.Expression.Expression
                wrappedBody =
                    instExpr
                        |> wrapWithTracking pointId bodyRange

                newLambda : Elm.Syntax.Expression.Lambda
                newLambda =
                    { lambda | expression = wrappedBody }
            in
            ( Node exprRange (Elm.Syntax.Expression.LambdaExpression newLambda)
            , newState
            )

        Elm.Syntax.Expression.RecordExpr setters ->
            let
                ( instrumentedSetters, newState ) =
                    List.foldr
                        (\setterNode ( acc, state_ ) ->
                            let
                                ( fieldNameNode, fieldExprNode ) =
                                    Elm.Syntax.Node.value setterNode

                                ( instExpr, newState_ ) =
                                    instrumentExprHelp fieldExprNode declarationName (Just "subexpression") state_

                                newSetter : Elm.Syntax.Expression.RecordSetter
                                newSetter =
                                    ( fieldNameNode, instExpr )

                                newSetterNode : Node Elm.Syntax.Expression.RecordSetter
                                newSetterNode =
                                    Node (Elm.Syntax.Node.range setterNode) newSetter
                            in
                            ( newSetterNode :: acc, newState_ )
                        )
                        ( [], state )
                        setters
            in
            ( Node exprRange (Elm.Syntax.Expression.RecordExpr instrumentedSetters)
            , newState
            )

        Elm.Syntax.Expression.ListExpr exprs ->
            let
                ( instrumentedExprs, newState ) =
                    instrumentExprListWithCategory exprs declarationName "subexpression" state
            in
            ( Node exprRange (Elm.Syntax.Expression.ListExpr instrumentedExprs)
            , newState
            )

        Elm.Syntax.Expression.RecordAccess record field ->
            let
                ( instRecord, newState ) =
                    instrumentExprHelp record declarationName Nothing state
            in
            ( Node exprRange (Elm.Syntax.Expression.RecordAccess instRecord field)
            , newState
            )

        Elm.Syntax.Expression.RecordUpdateExpression name setters ->
            let
                ( instrumentedSetters, newState ) =
                    List.foldr
                        (\setterNode ( acc, state_ ) ->
                            let
                                ( fieldNameNode, fieldExprNode ) =
                                    Elm.Syntax.Node.value setterNode

                                ( instExpr, newState_ ) =
                                    instrumentExprHelp fieldExprNode declarationName (Just "subexpression") state_

                                newSetter : Elm.Syntax.Expression.RecordSetter
                                newSetter =
                                    ( fieldNameNode, instExpr )

                                newSetterNode : Node Elm.Syntax.Expression.RecordSetter
                                newSetterNode =
                                    Node (Elm.Syntax.Node.range setterNode) newSetter
                            in
                            ( newSetterNode :: acc, newState_ )
                        )
                        ( [], state )
                        setters
            in
            ( Node exprRange (Elm.Syntax.Expression.RecordUpdateExpression name instrumentedSetters)
            , newState
            )

        Elm.Syntax.Expression.UnitExpr ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.FunctionOrValue _ _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.PrefixOperator _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.Operator _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.Integer _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.Hex _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.Floatable _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.Literal _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.CharLiteral _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.RecordAccessFunction _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()

        Elm.Syntax.Expression.GLSLExpression _ ->
            case mode of
                Just category ->
                    maybeAddPoint category

                Nothing ->
                    doNothing ()


{-|

     expr
     -->
     let _ = Test.Coverage.track 1830518580 in expr

-}
wrapWithTracking : Int -> Range -> Node Elm.Syntax.Expression.Expression -> Node Elm.Syntax.Expression.Expression
wrapWithTracking pointId exprRange exprNode =
    let
        nodify : a -> Node a
        nodify a =
            Node exprRange a
    in
    nodify <|
        Elm.Syntax.Expression.LetExpression
            { declarations =
                [ nodify <|
                    Elm.Syntax.Expression.LetDestructuring
                        (nodify Elm.Syntax.Pattern.AllPattern)
                        (nodify <|
                            Elm.Syntax.Expression.Application
                                [ nodify <| Elm.Syntax.Expression.FunctionOrValue [ "Test", "Coverage" ] "track"
                                , nodify <| Elm.Syntax.Expression.Integer pointId
                                ]
                        )
                ]
            , expression = exprNode
            }


instrumentExprList : List (Node Elm.Syntax.Expression.Expression) -> String -> InstrumentState -> ( List (Node Elm.Syntax.Expression.Expression), InstrumentState )
instrumentExprList exprs declarationName state =
    List.foldr
        (\exprNode_ ( acc, state_ ) ->
            let
                ( instExpr, newState_ ) =
                    instrumentExpr exprNode_ declarationName state_
            in
            ( instExpr :: acc, newState_ )
        )
        ( [], state )
        exprs


instrumentExprListWithCategory : List (Node Elm.Syntax.Expression.Expression) -> String -> String -> InstrumentState -> ( List (Node Elm.Syntax.Expression.Expression), InstrumentState )
instrumentExprListWithCategory exprs declarationName category state =
    List.foldr
        (\exprNode_ ( acc, state_ ) ->
            let
                ( instExpr, newState_ ) =
                    instrumentExprWithCategory exprNode_ declarationName category state_
            in
            ( instExpr :: acc, newState_ )
        )
        ( [], state )
        exprs


instrumentLetDeclaration : Node Elm.Syntax.Expression.LetDeclaration -> String -> InstrumentState -> ( Node Elm.Syntax.Expression.LetDeclaration, InstrumentState )
instrumentLetDeclaration declNode declarationName state =
    let
        declRange : Range
        declRange =
            Elm.Syntax.Node.range declNode
    in
    case Elm.Syntax.Node.value declNode of
        Elm.Syntax.Expression.LetFunction fn ->
            let
                fnImpl : Elm.Syntax.Expression.FunctionImplementation
                fnImpl =
                    Elm.Syntax.Node.value fn.declaration

                -- Track let function binding body with "declaration" category
                ( instExpr, newState ) =
                    instrumentExprWithCategory fnImpl.expression declarationName "declaration" state

                newFnImpl : Elm.Syntax.Expression.FunctionImplementation
                newFnImpl =
                    { fnImpl | expression = instExpr }

                newFn : Elm.Syntax.Expression.Function
                newFn =
                    { fn | declaration = Elm.Syntax.Node.map (always newFnImpl) fn.declaration }
            in
            ( Node declRange (Elm.Syntax.Expression.LetFunction newFn)
            , newState
            )

        Elm.Syntax.Expression.LetDestructuring pattern destrExpr ->
            let
                -- Track let destructuring binding body with "declaration" category
                ( instDestrExpr, newState ) =
                    instrumentExprWithCategory destrExpr declarationName "declaration" state
            in
            ( Node declRange (Elm.Syntax.Expression.LetDestructuring pattern instDestrExpr)
            , newState
            )
