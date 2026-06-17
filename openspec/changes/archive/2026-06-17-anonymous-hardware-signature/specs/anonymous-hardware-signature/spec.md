## ADDED Requirements

### Requirement: GPU Signature Acquisition and Fallback
The system MUST retrieve a unique hardware signature based on the primary GPU or fall back to a persistent, randomly generated client-id UUID if GPU information is unavailable.

#### Scenario: NVIDIA GPU with proprietary driver
- **WHEN** executing on a system with an NVIDIA GPU and proprietary drivers installed
- **THEN** the system executes `nvidia-smi --query-gpu=uuid --format=csv,noheader` and retrieves the printed GPU UUID.

#### Scenario: AMD GPU
- **WHEN** executing on a system with an AMD GPU and the file `/sys/class/drm/card0/device/unique_id` exists
- **THEN** the system reads the content of that file to retrieve the GPU unique ID.

#### Scenario: Fallback to persistent client-id UUID
- **WHEN** the primary GPU is Intel/other or retrieving GPU signature fails, and the `client-id` file does not exist in the Goverlay configuration directory
- **THEN** the system generates a random UUID, saves it to the `client-id` file in the Goverlay config directory, and uses it as the hardware signature.

#### Scenario: Using existing persistent client-id UUID
- **WHEN** the primary GPU is Intel/other or retrieving GPU signature fails, and the `client-id` file exists in the Goverlay configuration directory
- **THEN** the system reads the content of the `client-id` file and uses it as the hardware signature.

### Requirement: SHA-256 Hashing of Signature
The system MUST compute the SHA-256 hash of the retrieved hardware signature to produce a unique, anonymous, fixed-length machine hash string.

#### Scenario: Compute machine hash
- **WHEN** a unique hardware signature string is obtained
- **THEN** the system hashes it using the SHA-256 algorithm to generate a 64-character hexadecimal `machine_hash` string.

### Requirement: Enriching Benchmark Submission Payload
The system MUST include the generated `machine_hash` in the benchmark submission JSON payload.

#### Scenario: Submit results with machine hash
- **WHEN** preparing the JSON benchmark submission payload
- **THEN** the system adds the key `"machine_hash"` with the computed SHA-256 hash value to the JSON object before spawning the submission thread.
