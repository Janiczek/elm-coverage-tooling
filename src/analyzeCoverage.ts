import type { CoverageMetadata, CoverageData } from './types.js';

export type CoverageAnalysis = {
    totalPoints: number;
    coveredPoints: number;
    coveragePercentage: number;
    details: Array<{
        pointId: number;
        moduleName: string;
        declarationName: string;
        range: [[number, number], [number, number]];
        count: number;
        covered: boolean;
    }>;
};

/**
 * Analyzes coverage data given metadata and counts.
 */
export function analyzeCoverage(_metadata: CoverageMetadata, _counts: CoverageData): CoverageAnalysis {
    // TODO: implement
    return {
        totalPoints: 0,
        coveredPoints: 0,
        coveragePercentage: 0,
        details: [],
    };
}