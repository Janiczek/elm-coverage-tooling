// Type declarations for the Elm-generated elm-report.js module
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
            coverageMetadata: Record<number, {
                moduleName: string;
                moduleFilePath: string;
                declarationName: string;
                range: [[number, number], [number, number]];
            }>;
            coverageData: Record<number, number>;
            sources: Record<string, string>;
            moduleHashes: Record<string, number>;
            moduleNames: Record<string, string>;
            format: string;
        }
        
        export function init(options: { flags: Flags }): App;
    }
}
