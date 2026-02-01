export type CoverageMetadata = {
    moduleName: string;
    declarationName: string;
    range: [[number, number], [number, number]];
};

export type CoverageMetadataMap = Map<number, CoverageMetadata>;

export type CoverageData = Map<number, number>; // pointId -> count

export type ModuleMetadata = Map<string, number>; // filePath -> contentHash