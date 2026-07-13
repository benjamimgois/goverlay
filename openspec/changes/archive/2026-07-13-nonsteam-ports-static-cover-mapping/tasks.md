## 1. Static Database Implementation

- [x] 1.1 Declare `TPortMapping` structure and `STATIC_PORT_MAPPINGS` database constant in `games_tab.pas`
- [x] 1.2 Implement `ResolveUnofficialPortName` helper function in `games_tab.pas` to lookup official game names case-insensitively

## 2. Integration in Cover Thread Loop

- [x] 2.1 Integrate `ResolveUnofficialPortName` inside `TNonSteamCoverThread.Execute` to map project names before calling search APIs

## 3. Verification and Testing

- [x] 3.1 Verify that the Pascal project builds successfully without syntax or type errors
- [x] 3.2 Programmatically verify port translation using a test script
