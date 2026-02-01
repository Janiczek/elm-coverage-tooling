const header = '// elm-coverage-tooling patch start';
const counterInitialization = 'globalThis.__elm_line_coverage = {};'
const writeCoverageToFile = `
var fs = require("fs");
var path = require("path");
setTimeout(function() {
    if (typeof app === "undefined") {
        throw "elm-coverage-tooling: can't find elm-test runner";
    }
    app.ports.elmTestPort__send.subscribe(function(rawData) {
        var data = JSON.parse(rawData);
        if (data.type === "FINISHED") {
            var coveragePath = path.join(
                "elm-stuff",
                "coverage-" + process.pid + ".json"
            );
            fs.writeFileSync(
                coveragePath,
                JSON.stringify(globalThis.__elm_line_coverage)
            );
        }
    });
}, 0);
`;
const footer = '// elm-coverage-tooling patch end';

/**
 * Generates the track function definition using the captured variable name.
 * @param variableName - The full variable name (e.g., $author$project$Test$Coverage$track or $elm_explorations$test$Test$Coverage$track)
 */
function generateTrackFunctionDefinition(variableName: string): string {
    return `
var ${variableName} = function (pointId) {
    globalThis.__elm_line_coverage[pointId] = (globalThis.__elm_line_coverage[pointId] || 0) + 1;
    return _Utils_Tuple0;
};
`;
}

/**
 * Patches the compiled JS code to make Test.Coverage.* functions actually work.
 * Injects code to track coverage and persist it when elm-test finishes.
 * @param compiledJsCode - The compiled JavaScript code to patch
 * @param config - Configuration object
 * @param config.inTestingContext - Whether the code is running in a testing context (elm-test)
 */
export function patch(compiledJsCode: string, config: { inTestingContext: boolean }): string {
    // var $author$project$Test$Coverage$track = function (_v0) {
    //     return _Utils_Tuple0;
    // };
    //
    // Match any parameter name (not just "pointId") - Elm compiler may rename it to _v0, _v1, etc.
    // Match the function with any content between the opening brace and return statement
    //
    // Note: Using RegExp constructor to ensure proper escaping of $ characters
    // In regex, $ means end-of-string, so we need \$ to match literal $
    // In source code string, we need \\$ to get \$ in the regex
    //
    // The pattern matches any module path ending with $Test$Coverage$track
    // and captures the full variable name in group 1
    const pattern = new RegExp('var\\s*(\\$(?:[^$]+\\$)+Test\\$Coverage\\$track)\\s*=\\s*function\\s+\\([^)]+\\)\\s*\\{.*?return\\s+_Utils_Tuple0;\\s*\\};', 'gms');

    if (config.inTestingContext) {
        // Full patch for testing context - includes writing coverage to file
        return compiledJsCode.replace(pattern, (_match, variableName) => {
            const trackFunctionDefinition = generateTrackFunctionDefinition(variableName);
            return `
${header}
${counterInitialization}
${writeCoverageToFile}
${trackFunctionDefinition}
${footer}
`;
        });
    } else {
        // Minimal patch for non-testing context - only enables the counter
        return compiledJsCode.replace(pattern, (_match, variableName) => {
            const trackFunctionDefinition = generateTrackFunctionDefinition(variableName);
            return `
${header}
${counterInitialization}
${trackFunctionDefinition}
${footer}
`;
        });
    }
}
