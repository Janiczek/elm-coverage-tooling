import { Elm } from "../dist/elm-instrument.js";
import type { CoverageMetadataMap } from './types.js';

export type InstrumentOutput = {
    instrumentedElmSourceCode: string;
    coverageMetadata: CoverageMetadataMap;
    contentHash: number;
} | { error: string };

export function instrument(elmSourceCode: string): Promise<InstrumentOutput> {
    return new Promise((resolve) => {
        const app = Elm.Main.init({
            flags: {
                elmSourceCode: elmSourceCode
            }
        });

        app.ports.sendOutput.subscribe((output: any) => {
            // This all mostly boils down to converting an object to a Map.

            if (output.error) {
                resolve({ error: output.error });
            } else if (output.instrumentedElmSourceCode && output.coverageMetadata && output.contentHash) {
                const rawMetadata: Record<string, any> = output.coverageMetadata;
                const coverageMetadata: CoverageMetadataMap = new Map(Object.entries(rawMetadata)
                    .map(([key, value]) => [Number(key), value]));
                resolve({
                    instrumentedElmSourceCode: output.instrumentedElmSourceCode,
                    coverageMetadata,
                    contentHash: output.contentHash,
                });
            } else {
                resolve({ error: "Invalid output structure from Elm instrumenter." });
            }
        });

        // TODO: use Lamdera as the compiler and app.die() after this is done?
        // Or alternatively, make the Elm app a long-lived singleton and give it
        // all the code at once / feed it via ports?
    });
}
