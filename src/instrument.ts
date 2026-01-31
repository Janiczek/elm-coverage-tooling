import { Elm } from "../dist/elm-instrument.js";

export type InstrumentOutput = {
    instrumentedElmSourceCode: string;
    coverageMetadata: Record<number, {
        moduleName: string;
        declarationName: string;
        range: [[number, number], [number, number]];
    }>;
} | { error: string };

export function instrument(elmSourceCode: string): Promise<InstrumentOutput> {
    return new Promise((resolve) => {
        const app = Elm.Main.init({
            flags: {
                elmSourceCode: elmSourceCode
            }
        });

        app.ports.sendOutput.subscribe((output: any) => {
            resolve(output);
        });

        // TODO: use Lamdera as the compiler and app.die() after this is done?
        // Or alternatively, make the Elm app a long-lived singleton and give it
        // all the code at once / feed it via ports?
    });
}
