module Instrument exposing (instrument)

import Dict exposing (Dict)
import Elm.Syntax.Declaration exposing (Declaration)
import Elm.Syntax.Expression exposing (Expression)
import Elm.Syntax.File exposing (File)
import Elm.Syntax.Module
import Elm.Syntax.Node exposing (Node(..))
import Elm.Syntax.Pattern exposing (Pattern)
import Random
import Elm.Syntax.Range exposing (Range)
import InstrumentState exposing (InstrumentState)
import PointId exposing (PointId)
import PointMetadata exposing (PointMetadata)


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
    ( { file | declarations = result.newDeclarations }
    , result.metadata
    )


instrumentDecl : Node Declaration -> InstrumentState -> InstrumentState
instrumentDecl declNode acc =
    -- TODO: all expressions have a region
    -- TODO: if-expr branches have their own region
    -- TODO: case-expr branches have their own region
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
            instrumentExpr fnImpl.expression declarationName state

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
        declarationName : String
        declarationName =
            -- TODO maybe show the LHS instead here?
            "_destructuring"

        ( instrumentedExpr, newState ) =
            instrumentExpr exprNode declarationName state

        newDecl : Node Declaration
        newDecl =
            Node declRange (Elm.Syntax.Declaration.Destructuring patternNode instrumentedExpr)
    in
    { newState | newDeclarations = newDecl :: newState.newDeclarations }


instrumentExpr : Node Elm.Syntax.Expression.Expression -> String -> InstrumentState -> ( Node Elm.Syntax.Expression.Expression, InstrumentState )
instrumentExpr exprNode declarationName state =
    let
        exprRange : Range
        exprRange =
            Elm.Syntax.Node.range exprNode

        ( instrumentedInnerExpr, stateAfterRecurse ) =
            instrumentExprRecurse exprNode declarationName state

        ( pointId, newSeed ) =
            Random.step PointId.generator stateAfterRecurse.seed

        metadata : PointMetadata
        metadata =
            { moduleName = state.moduleName
            , declarationName = declarationName
            , range = exprRange
            }

        newState : InstrumentState
        newState =
            { stateAfterRecurse
                | seed = newSeed
                , metadata = Dict.insert pointId metadata stateAfterRecurse.metadata
            }

        wrappedExpr : Node Elm.Syntax.Expression.Expression
        wrappedExpr =
            instrumentedInnerExpr
                |> wrapWithTracking pointId exprRange
    in
    ( wrappedExpr, newState )

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

instrumentExprRecurse :
    Node Elm.Syntax.Expression.Expression
    -> String
    -> InstrumentState
    -> ( Node Elm.Syntax.Expression.Expression, InstrumentState )
instrumentExprRecurse exprNode declarationName state =
    let
        exprRange : Range
        exprRange =
            Elm.Syntax.Node.range exprNode

        doNothing : () -> ( Node Elm.Syntax.Expression.Expression, InstrumentState )
        doNothing () =
            ( exprNode, state )
    in
    case Elm.Syntax.Node.value exprNode of
        Elm.Syntax.Expression.Application exprs ->
            let
                ( instrumentedExprs, newState ) =
                    instrumentExprList exprs declarationName state
            in
            ( Node exprRange (Elm.Syntax.Expression.Application (List.reverse instrumentedExprs))
            , newState
            )

        Elm.Syntax.Expression.OperatorApplication op dir left right ->
            let
                ( instLeft, state1 ) =
                    instrumentExpr left declarationName state

                ( instRight, state2 ) =
                    instrumentExpr right declarationName state1
            in
            ( Node exprRange (Elm.Syntax.Expression.OperatorApplication op dir instLeft instRight)
            , state2
            )

        Elm.Syntax.Expression.IfBlock condition thenBranch elseBranch ->
            let
                ( instCondition, state1 ) =
                    instrumentExpr condition declarationName state

                ( instThen, state2 ) =
                    instrumentExpr thenBranch declarationName state1

                ( instElse, state3 ) =
                    instrumentExpr elseBranch declarationName state2
            in
            ( Node exprRange (Elm.Syntax.Expression.IfBlock instCondition instThen instElse)
            , state3
            )

        Elm.Syntax.Expression.Negation inner ->
            let
                ( instInner, newState ) =
                    instrumentExpr inner declarationName state
            in
            ( Node exprRange (Elm.Syntax.Expression.Negation instInner)
            , newState
            )

        Elm.Syntax.Expression.TupledExpression exprs ->
            let
                ( instrumentedExprs, newState ) =
                    instrumentExprList exprs declarationName state
            in
            ( Node exprRange (Elm.Syntax.Expression.TupledExpression (List.reverse instrumentedExprs))
            , newState
            )

        Elm.Syntax.Expression.ParenthesizedExpression inner ->
            let
                ( instInner, newState ) =
                    instrumentExpr inner declarationName state
            in
            ( Node exprRange (Elm.Syntax.Expression.ParenthesizedExpression instInner)
            , newState
            )

        Elm.Syntax.Expression.LetExpression letBlock ->
            let
                ( instrumentedDecls, state1 ) =
                    List.foldl
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
                    instrumentExpr letBlock.expression declarationName state1

                newLetBlock : Elm.Syntax.Expression.LetBlock
                newLetBlock =
                    { declarations = List.reverse instrumentedDecls
                    , expression = instLetExpr
                    }
            in
            ( Node exprRange (Elm.Syntax.Expression.LetExpression newLetBlock)
            , state2
            )

        Elm.Syntax.Expression.CaseExpression caseBlock ->
            let
                ( instExpr, state1 ) =
                    instrumentExpr caseBlock.expression declarationName state

                ( instrumentedCases, state2 ) =
                    List.foldl
                        (\( pattern, caseExpr ) ( acc, state_ ) ->
                            let
                                ( instCaseExpr, newState_ ) =
                                    instrumentExpr caseExpr declarationName state_
                            in
                            ( ( pattern, instCaseExpr ) :: acc, newState_ )
                        )
                        ( [], state1 )
                        caseBlock.cases

                newCaseBlock : Elm.Syntax.Expression.CaseBlock
                newCaseBlock =
                    { expression = instExpr
                    , cases = List.reverse instrumentedCases
                    }
            in
            ( Node exprRange (Elm.Syntax.Expression.CaseExpression newCaseBlock)
            , state2
            )

        Elm.Syntax.Expression.LambdaExpression lambda ->
            let
                ( instExpr, newState ) =
                    instrumentExpr lambda.expression declarationName state

                newLambda : Elm.Syntax.Expression.Lambda
                newLambda =
                    { lambda | expression = instExpr }
            in
            ( Node exprRange (Elm.Syntax.Expression.LambdaExpression newLambda)
            , newState
            )

        Elm.Syntax.Expression.RecordExpr setters ->
            let
                ( instrumentedSetters, newState ) =
                    List.foldl
                        (\setterNode ( acc, state_ ) ->
                            let
                                ( fieldNameNode, fieldExprNode ) =
                                    Elm.Syntax.Node.value setterNode

                                ( instExpr, newState_ ) =
                                    instrumentExpr fieldExprNode declarationName state_

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
            ( Node exprRange (Elm.Syntax.Expression.RecordExpr (List.reverse instrumentedSetters))
            , newState
            )

        Elm.Syntax.Expression.ListExpr exprs ->
            let
                ( instrumentedExprs, newState ) =
                    instrumentExprList exprs declarationName state
            in
            ( Node exprRange (Elm.Syntax.Expression.ListExpr (List.reverse instrumentedExprs))
            , newState
            )

        Elm.Syntax.Expression.RecordAccess record field ->
            let
                ( instRecord, newState ) =
                    instrumentExpr record declarationName state
            in
            ( Node exprRange (Elm.Syntax.Expression.RecordAccess instRecord field)
            , newState
            )

        Elm.Syntax.Expression.RecordUpdateExpression name setters ->
            let
                ( instrumentedSetters, newState ) =
                    List.foldl
                        (\setterNode ( acc, state_ ) ->
                            let
                                ( fieldNameNode, fieldExprNode ) =
                                    Elm.Syntax.Node.value setterNode

                                ( instExpr, newState_ ) =
                                    instrumentExpr fieldExprNode declarationName state_

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
            ( Node exprRange (Elm.Syntax.Expression.RecordUpdateExpression name (List.reverse instrumentedSetters))
            , newState
            )

        Elm.Syntax.Expression.UnitExpr ->
            doNothing ()

        Elm.Syntax.Expression.FunctionOrValue _ _ ->
            doNothing ()

        Elm.Syntax.Expression.PrefixOperator _ ->
            doNothing ()

        Elm.Syntax.Expression.Operator _ ->
            doNothing ()

        Elm.Syntax.Expression.Integer _ ->
            doNothing ()

        Elm.Syntax.Expression.Hex _ ->
            doNothing ()

        Elm.Syntax.Expression.Floatable _ ->
            doNothing ()

        Elm.Syntax.Expression.Literal _ ->
            doNothing ()

        Elm.Syntax.Expression.CharLiteral _ ->
            doNothing ()

        Elm.Syntax.Expression.RecordAccessFunction _ ->
            doNothing ()

        Elm.Syntax.Expression.GLSLExpression _ ->
            doNothing ()


instrumentExprList : List (Node Elm.Syntax.Expression.Expression) -> String -> InstrumentState -> ( List (Node Elm.Syntax.Expression.Expression), InstrumentState )
instrumentExprList exprs declarationName state =
    List.foldl
        (\exprNode_ ( acc, state_ ) ->
            let
                ( instExpr, newState_ ) =
                    instrumentExpr exprNode_ declarationName state_
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

                ( instExpr, newState ) =
                    instrumentExpr fnImpl.expression declarationName state

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
                ( instDestrExpr, newState ) =
                    instrumentExpr destrExpr declarationName state
            in
            ( Node declRange (Elm.Syntax.Expression.LetDestructuring pattern instDestrExpr)
            , newState
            )
