# elm-coverage-tooling

## CLI

### `elm-coverage-test`

Wrapper around `elm-test` (or `elm-test-rs`) that:

  * instruments the codebase with `let _ = Test.Coverage.track <pointId> in ...`
  * outputs `coverage-metadata.json` for later processing of line coverage data
  * patches compiled JS (for the `Test.Coverage.*` functions to actually do something)
  * runs `elm-test`
  * afterwards collect the line coverage data
  * analyzes the line coverage data into a report
  * outputs the report in the wanted format

### `elm-coverage-make`

Wrapper around `elm make` that:

  * instruments the codebase with `let _ = Test.Coverage.track <pointId> in ...`
  * outputs `coverage-metadata.json` for later processing of line coverage data
  * patches compiled JS (for the `Test.Coverage.*` functions to actually do something)

This allows the developer to eg. run instrumented code in the browser and send
line coverage data to an error monitoring service like Sentry.

## JS Library

### `instrument(elmSourceCode: string) => Promise<InstrumentOutput>`

Instruments the given Elm source code with `let _ = Test.Coverage.track <pointId> in ...`.

Returns coverage metadata to be combined with coverage counts during reporting.

### `patch(compiledJsCode: string) => string`

Patches the `Test.Coverage.*` functions in the JS form of the instrumented Elm
program to do useful work instead of being no-ops.

### `analyzeCoverage(metadata: CoverageMetadata, counts: CoverageData) => CoverageAnalysis`

Analyzes code coverage data.

### `report(analysis: CoverageAnalysis, format: ReportFormat) => Report`

Formats the coverage analysis into a report in the requested file format.

Formats:

  * LCOV
  * HTML
  * CSV
  * plaintext