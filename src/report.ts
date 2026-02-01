import { Elm } from "../dist/elm-report.js";
import type { CoverageMetadata, CoverageMetadataMap, CoverageData } from './types.js';

export type ReportFormat = 'lcov' | 'html' | 'csv' | 'plaintext' | 'stdout';

export type ReportFile = {
    filepath: string;
    contents: string;
};

export type Report = ReportFile[];

/**
 * Formats the coverage data into a report.
 */
export async function report(
    metadata: CoverageMetadataMap,
    data: CoverageData,
    format: ReportFormat,
    sources: Map<string, string>,
    moduleHashes: Map<string, number>
): Promise<Report> {
    const coverageMetadataRecord: Record<number, CoverageMetadata> = Object.fromEntries(metadata.entries());
    const coverageDataRecord: Record<number, number> = Object.fromEntries(data.entries());
    const sourcesRecord: Record<string, string> = Object.fromEntries(sources.entries());
    const moduleHashesRecord: Record<string, number> = Object.fromEntries(moduleHashes.entries());

    return new Promise((resolve, reject) => {
        const app = Elm.Main.init({
            flags: {
                coverageMetadata: coverageMetadataRecord,
                coverageData: coverageDataRecord,
                sources: sourcesRecord,
                moduleHashes: moduleHashesRecord,
                format: format
            }
        });

        app.ports.sendOutput.subscribe((output: any) => {
            if (output.error) {
                reject(new Error(output.error));
            } else if (output.reports) {
                resolve(output.reports);
            } else {
                reject(new Error("Invalid output structure from Elm reporter."));
            }
        });
    });
}
