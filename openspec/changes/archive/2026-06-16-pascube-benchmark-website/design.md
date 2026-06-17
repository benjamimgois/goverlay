## Context

Pascube benchmark data is stored in a public Google Sheets file. The user currently uses native Google Sheets charts but wants a modern HTML5-based web dashboard that loads this data and generates beautiful, interactive charts.

## Goals / Non-Goals

**Goals:**
- Create a standalone modern HTML5 dashboard for Pascube benchmarks under a new directory `pascube_dashboard/`.
- Dynamically fetch the benchmark data as CSV directly from the Google Sheets public URL.
- Support interactive charting for CPU (Single/Multi-Thread) and GPU metrics.
- Provide a clean, dark-themed responsive UI with responsive filters (search, OS filtering) and a sortable data table.
- Keep the site self-contained (HTML, CSS, JS) so it can be run locally, hosted on GitHub Pages, or embedded in Google Sites.

**Non-Goals:**
- Creating a backend server, database, or API (client-side dynamic fetching is sufficient and cost-effective).
- Writing complex Lazarus Pascal code changes to generate the web dashboard.

## Decisions

### 1. Framework Choice: Vanilla HTML5, CSS3, and JavaScript
- **Choice:** Pure client-side Vanilla HTML, CSS, and JS.
- **Rationale:** The dashboard is a single-page visualization app. Using frameworks like React or Next.js would add unnecessary build step overhead and make local file execution (double-clicking `index.html`) impossible. Vanilla files are immediately runnable and hostable anywhere.

### 2. Charting Library: Chart.js (via CDN)
- **Choice:** Chart.js.
- **Rationale:** Chart.js is lightweight, highly customizable, responsive, and easy to configure via Javascript. It allows us to create beautiful bar charts matching the visual style of the original Google Sheets charts but with better tooltips, animations, and dark-mode styling.

### 3. Data Source Integration: Google Sheets CSV Export API
- **Choice:** Dynamic `fetch` from `https://docs.google.com/spreadsheets/d/1nlMgeW0ZFmtwwT3hty8JAFT3sM0SNhMpc24mH3In9zI/export?format=csv`.
- **Rationale:** Using the direct CSV export endpoint requires no Google Cloud API keys or authentication, is public, and ensures the site always displays the most up-to-date benchmarks.

### 4. Client-side Parsing
- **Choice:** Custom robust CSV parsing function in JavaScript.
- **Rationale:** The format is simple comma-separated columns but needs to handle quotes correctly (e.g., numbers with comma separators inside quotes like `"3,909"`). A simple regex-based or stateful line-by-line parser will cleanly process the data without external dependencies.

## Risks / Trade-offs

- **CORS / Fetch issues** &rarr; *Mitigation:* Google Sheets export endpoints natively support CORS and allow public requests.
- **Rate limiting on export URL** &rarr; *Mitigation:* The data updates on benchmark runs only. If rate limiting occurs under high traffic, we can provide a fallback cached CSV locally, but under normal use, direct fetching is reliable.
- **Data parsing errors (e.g., user inputs N/D or formatting changes)** &rarr; *Mitigation:* The JavaScript parser will sanitize numbers by stripping quotes, commas, and handling non-numeric values like `N/D` gracefully (treating them as `null` or skipping them in calculations).
