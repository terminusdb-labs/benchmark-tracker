import * as core from '@actions/core';
import { configFromJobInput } from './config';
import { extractResult } from './extract';
import { writeBenchmark } from './write';

async function main() {
    const config = await configFromJobInput();
    core.debug(`Config extracted from job: ${config}`);

    const bench = await extractResult(config);
    core.debug(`Benchmark result was extracted: ${bench}`);

    await writeBenchmark(bench, config);
    console.log('terminusdb-labs/benchmark-tracker ran successfully!', '\nData:', bench);
}

main().catch((e) => core.setFailed(e.message));
