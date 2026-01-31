export * from './types.js';

export { instrument, type InstrumentOutput } from './instrument.js';
export { combineMetadata } from './combineMetadata.js';
export { patch } from './patch.js';
export { analyzeCoverage, type CoverageAnalysis } from './analyzeCoverage.js';
export { report, type ReportFormat, type ReportFile, type Report } from './report.js';
