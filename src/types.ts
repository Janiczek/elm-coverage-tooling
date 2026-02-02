export type CoverageMetadata = {
    moduleName: string;
    moduleFilePath: string;
    declarationName: string;
    range: [[number, number], [number, number]];
    category: string;
};

export type CoverageMetadataMap = Map<number, CoverageMetadata>;

export type CoverageData = Map<number, number>; // pointId -> count

export type ModuleMetadata = Map<string, number>; // filePath -> contentHash