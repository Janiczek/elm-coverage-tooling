module Report.Stdout exposing (generate)

import Report exposing (Input, ReportFile)
import Report.Plaintext


generate : Input -> { reports : List ReportFile }
generate input =
    let
        plaintextResult =
            Report.Plaintext.generate input
    in
    { reports =
        List.map
            (\report ->
                { report | filepath = "stdout" }
            )
            plaintextResult.reports
    }
