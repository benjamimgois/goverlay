# Specification: pascube-web-dashboard

## Purpose
A modern, responsive HTML5 dashboard to visualize performance results from the Pascube benchmark.

## Requirements

### Requirement: Fetch and parse CSV data from Google Sheets
The web dashboard SHALL dynamically fetch the Pascube benchmark CSV data from the public Google Sheets export URL. It MUST parse the CSV format properly, handling quote encapsulation, comma-grouped numeric strings (e.g. "3,909" to 3909), and missing values (e.g., N/D mapped to null or skipped).

#### Scenario: Successful data retrieval and parsing
- **WHEN** the web dashboard is initialized in the browser
- **THEN** it fetches the CSV export from the public Google Sheet URL, parses the rows into objects containing CPU, RAM, GPU, VRAM, Driver, Kernel, Operating System, Main Score, CPU Single, CPU Multi, GPU Score, and Date/Time, and updates the UI state.

### Requirement: Render interactive CPU Single-Thread and Multi-Thread charts
The web dashboard SHALL render interactive bar charts showing the Top 8 CPUs ranked by their CPU Single-Thread score and CPU Multi-Thread score respectively, matching the logical ranking in the original spreadsheet.

#### Scenario: Render CPU benchmarks
- **WHEN** the data is parsed and loaded
- **THEN** the system generates two separate horizontal or vertical bar charts showcasing the top 8 unique or top 8 individual CPUs with valid non-empty scores.

### Requirement: Render interactive GPU Score chart
The web dashboard SHALL render an interactive bar chart showing the Top 8 GPUs ranked by their GPU Score.

#### Scenario: Render GPU benchmarks
- **WHEN** the data is parsed and loaded
- **THEN** the system generates a bar chart showcasing the top 8 GPUs with valid non-empty scores.

### Requirement: Interactive data table with search, filter, and sorting
The web dashboard SHALL display all parsed benchmark runs in an interactive HTML5 table. The table MUST allow users to search for specific hardware (CPU, GPU, OS), filter runs by operating system, and sort runs by clicking on any of the column headers (e.g., Main Score, Date/Time).

#### Scenario: User filters and sorts table data
- **WHEN** the user types a query in the search input or clicks a column header
- **THEN** the table rows are instantly filtered or re-ordered based on the user's action.
