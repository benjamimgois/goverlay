## Why

The Pascube benchmark collects and submits telemetry to a spreadsheet database to build a hardware performance comparison board. Currently, it lacks CPU and GPU maximum frequency metrics, making it harder to evaluate if hardware is running underclocked or overclocked during testing. Adding this telemetry improves data value for hardware comparisons.

## What Changes

- Add CPU maximum frequency tracking to the benchmark results, retrieved from sysfs on Linux.
- Add GPU maximum frequency tracking to the benchmark results, covering Intel, AMD, and NVIDIA architectures on Linux.
- Persist the CPU and GPU maximum frequencies in the local benchmark history JSON.
- Submit the CPU and GPU maximum frequencies in the payload sent to the spreadsheet under the keys `"cpumaxfreq"` and `"gpumaxfreq"`.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `pascube-extended-telemetry`: Extend the specification to require querying and reporting CPU and GPU maximum frequencies on Linux.

## Impact

- `UnitPasCubeScreen.pas`: Struct `TBenchmarkResult` will be updated, and telemetry retrieval and payload generation will be modified.
- Saved local JSON history format will include `"cpu_max_freq"` and `"gpu_max_freq"` keys.
- Spreadsheet submission payload will send `"cpumaxfreq"` and `"gpumaxfreq"` JSON parameters.
