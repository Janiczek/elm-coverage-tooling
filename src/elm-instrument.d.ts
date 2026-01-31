// Type declarations for the Elm-generated elm-instrument.js module
// This file is copied to dist/ during build
export namespace Elm {
    export namespace Main {
        export interface App {
            ports: {
                sendOutput: {
                    subscribe: (callback: (output: any) => void) => void;
                };
            };
        }
        
        export interface Flags {
            elmSourceCode: string;
        }
        
        export function init(options: { flags: Flags }): App;
    }
}