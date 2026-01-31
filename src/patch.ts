/**
 * Patches the compiled JS code to make Test.Coverage.* functions actually work.
 * Injects code to track coverage and persist it when elm-test finishes.
 */
export function patch(compiledJsCode: string): string {
    // var $author$project$Test$Coverage$track = function (pointId) {
    //     return _Utils_Tuple0;
    // };
    const pattern = /var\s+\$author\$project\$Test\$Coverage\$track\s*=\s*function\s+\(pointId\)\s*\{[\s\S]*?return\s+_Utils_Tuple0;\s*\};/gm;

    if (!pattern.test(compiledJsCode)) {
        // If we can't find the track function, return unchanged
        // This might happen if the code wasn't instrumented
        return compiledJsCode;
    }

    const injection = `// elm-coverage-tooling patch
var fs = require("fs");
var path = require("path");
globalThis.__elm_line_coverage = {};
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

var $author$project$Test$Coverage$track = function (pointId) {
    globalThis.__elm_line_coverage[pointId] = (globalThis.__elm_line_coverage[pointId] || 0) + 1;
    return _Utils_Tuple0;
};`;

    return compiledJsCode.replace(pattern, injection);
}
