## ADDED Requirements

### Requirement: Display Environment and Runtime Metadata in Submission Confirmation Dialog
The system MUST display the processor architecture, the GOverlay package type, and the total benchmark duration in seconds in the submission confirmation dialog before sending the benchmark results.

#### Scenario: Render confirmation dialog
- **WHEN** the user initiates benchmark result submission
- **THEN** the system displays a confirmation dialog containing CPU architecture, packaging type, and benchmark duration.

### Requirement: Record and Submit Processor Architecture, Packaging Type, and Duration
The system MUST record the CPU architecture, the GOverlay packaging type, and the total duration of the benchmark run in seconds, and transmit these details under the keys `"architecture"`, `"package"`, and `"timer"` in the benchmark results JSON payload during submission.

#### Scenario: Prepare submission payload
- **WHEN** the submission payload is generated after a benchmark run
- **THEN** the system serializes CPU architecture, package type, and timer in seconds into the JSON payload with keys `"architecture"`, `"package"`, and `"timer"`.
