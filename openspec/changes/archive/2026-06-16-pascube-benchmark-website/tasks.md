## 1. Web App Structure & CSS Foundation

- [x] 1.1 Create directory `pascube_dashboard/` and core assets `pascube_dashboard/index.html` and `pascube_dashboard/style.css`
- [x] 1.2 Implement a modern dark-themed responsive CSS layout with glassmorphism effects and custom UI elements in `style.css`

## 2. CSV Data Fetching & Parsing

- [x] 2.1 Implement the dynamic fetch helper in `pascube_dashboard/app.js` to read from the Google Sheets CSV export endpoint
- [x] 2.2 Implement robust CSV parsing that handles double quotes, comma separators in numbers, and `N/D` missing data values

## 3. Interactive Charts Integration

- [x] 3.1 Integrate Chart.js via public CDN in `index.html`
- [x] 3.2 Implement CPU single-thread and multi-thread top 8 charting functions in `app.js`
- [x] 3.3 Implement GPU score top 8 charting function in `app.js`

## 4. Searchable & Sortable Data Table

- [x] 4.1 Implement the data table renderer in `app.js` with full column details (CPU, RAM, GPU, Operating System, Main Score, CPU Single/Multi, GPU Score, and Date/Time)
- [x] 4.2 Add a search bar to filter table content by CPU/GPU/OS name dynamically
- [x] 4.3 Add sorting capabilities to table column headers
- [x] 4.4 Add a top overview cards row showing summary statistics (e.g., Total Runs, Top CPU Single, Top CPU Multi, Top GPU Score)

## 5. Verification & Documentation

- [x] 5.1 Perform manual verification of dashboard loading, responsiveness, and charting accuracy
- [x] 5.2 Create `pascube_dashboard/README.md` with instructions on local execution, deployment, and how to embed the site into Google Sites
