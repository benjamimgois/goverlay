## Why

Currently, Pascube benchmark data is stored in a Google Sheet, which limits data visualization and user interaction. To make the benchmark results more accessible and visually engaging, we need a modern, interactive web dashboard that dynamically pulls and visualizes this data.

## What Changes

- Create a new web application under `pascube_dashboard/` with a modern dark-themed HTML5 visual design.
- Dynamically fetch and parse data from the public Google Sheets CSV export URL.
- Support clean parsing of numeric values (including values with comma grouping like `"3,909"`) and handle missing data (`N/D`).
- Integrate interactive charts using a modern charting library (such as Chart.js or ECharts):
  - Top CPU Single-Thread Score
  - Top CPU Multi-Thread Score
  - Top GPU Performance Score
  - Overall Main Score ranking
- Provide an interactive, sortable, and searchable data table showing all benchmark runs.
- Add features like system hardware filtering (e.g., filter by CPU brand, GPU brand, Operating System).

## Capabilities

### New Capabilities
- `pascube-web-dashboard`: A modern, responsive HTML5 web dashboard that reads and visualizes Pascube benchmark results from Google Sheets.

### Modified Capabilities
<!-- No modified capabilities since this is a new standalone web frontend -->

## Impact

- Adds a new directory `pascube_dashboard/` containing the frontend files (HTML, CSS, JS).
- No changes to existing Lazarus/Pascal code, build commands, or other backend code.
