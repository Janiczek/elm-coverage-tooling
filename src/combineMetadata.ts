import type { CoverageMetadata } from './types.js';

/**
 * Combines multiple coverage metadata objects into a single one.
 * TODO: this might be unnecessary if we change the instrument function to take in an array of files.
 */
export function combineMetadata(metadataArray: CoverageMetadata[]): CoverageMetadata {
    return new Map(metadataArray.flatMap(m => [...m]));
}
