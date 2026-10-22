## ADDED Requirements

### Requirement: Clean process lifecycle and subprocess supervision
The `bgmod` launcher SHALL supervise the execution lifecycle of game processes without circular process dependencies, ensuring that background logging processes terminate cleanly upon game exit and do not prevent external supervisors (such as Steam's reaper) from detecting game completion.

#### Scenario: Clean game exit on Steam with active tool logging
- **WHEN** a game is launched via `bgmod` under Steam with one or more diagnostic tool logs enabled
- **AND** the user closes the game normally
- **THEN** the game process tree terminates, `bgmod` detects child process exit, `RunSubprocessLogger` terminates cleanly, and Steam transitions the game status from running to stopped without manual user intervention.

#### Scenario: Forwarding cancellation signals to supervised game process
- **WHEN** Steam or an external launcher sends a termination signal (SIGTERM or SIGINT) to `bgmod`
- **THEN** `bgmod` forwards the signal to the child game process, waits for process tree teardown, signals the logger, and exits cleanly.

### Requirement: Isolated stream redirection and pipe closure
The `bgmod` launcher SHALL ensure that the write descriptor of the tool logging pipe is owned exclusively by the game process tree and closed in the supervisor process, guaranteeing that closing the game triggers an end-of-file (EOF) on the logger read descriptor.

#### Scenario: Pipe write end closed in supervisor
- **WHEN** `bgmod` spawns the game process with standard error redirected to the logging pipe
- **THEN** the supervisor process immediately closes its inherited write descriptor and restores its original standard error stream, ensuring that no lingering write references keep the pipe open after the game exits.
