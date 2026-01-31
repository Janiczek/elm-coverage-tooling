import { Elm } from "../dist/elm-instrument.js";

type InstrumentOutput = {
    instrumentedElmSourceCode: string;
    coverageMetadata: Record<number, {
        moduleName: string;
        declarationName: string;
        range: [[number, number], [number, number]];
    }>;
}

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
    });
}
