## 1. Constants & URLs

- [x] 1.1 Add raw GitHub JSON manifest URL constant in `constants.pas`

## 2. Manifest Fetching & Parsing

- [x] 2.1 Refactor update check logic to download manifest JSON file
- [x] 2.2 Parse stable and bleeding-edge versions and download URLs directly from manifest JSON keys
- [x] 2.3 Remove legacy `/tags` API retrieval and regex tags sorting methods

## 3. UI Update Logic

- [x] 3.1 Update update‑checking functions to compare installed version with manifest version
- [x] 3.2 Update download and installer triggers to use URLs extracted from manifest

## 4. Verification

- [x] 4.1 Mock manifest file locally or use test repository and verify successful version check and update triggers
