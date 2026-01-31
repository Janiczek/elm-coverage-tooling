export type CoverageMetadata = Map<number, {
    moduleName: string;
    declarationName: string;
    range: [[number, number], [number, number]];
}>;

export type CoverageData = Map<number, number>; // pointId -> count