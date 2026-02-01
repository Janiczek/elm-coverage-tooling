module Report.Lcov exposing (generate)

import Report exposing (Input, ReportFile)


generate : Input -> { reports : List ReportFile }
generate input =
    { reports = [ { filepath = "coverage.lcov", contents = "TODO: Implement LCOV format" } ]
    }
