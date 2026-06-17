# Pascube Benchmark Dashboard

A modern, high-fidelity responsive HTML5 dashboard to visualize performance results from the Pascube benchmark. The dashboard dynamically fetches real-time data from the public Google Sheet spreadsheet and renders interactive, beautiful CPU and GPU comparison charts.

## Features

- **Real-time Synchronization:** Dynamic fetching directly from Google Sheets via the CSV export endpoint.
- **Robust Parsing:** Cleans up numbers with embedded comma separators (e.g., `"3,909"` $\rightarrow$ `3909`) and handles missing data (`N/D`).
- **Interactive Visualizations:**
  - Top 8 CPU Single-Thread Score Chart (Chart.js)
  - Top 8 CPU Multi-Thread Score Chart (Chart.js)
  - Top 8 GPU Performance Chart (Chart.js)
- **Community Leaderboard:** Fully searchable, sortable, and filterable data table of all benchmark runs.
- **Responsive Layout:** Beautiful dark mode themed with glassmorphism cards, optimizing for desktop, tablet, and mobile screens.
- **Offline / CORS Fallback:** Built-in cached database that loads automatically if network connection fails or if CORS limits are hit.

## How to Run Locally

Since this dashboard is built using standard Vanilla HTML5, CSS3, and JavaScript, it does not require any compile step or complex node development servers.

1. Navigate to the `pascube_dashboard` directory.
2. Double-click the `index.html` file to open it directly in any modern browser.
3. Alternatively, you can serve it using a lightweight local server:
   ```bash
   npx serve .
   # or
   python3 -m http.server 8000
   ```

## Deploying to GitHub Pages (Recommended)

To host the site publicly for free:

1. Create a new GitHub repository or push these files to your existing project.
2. Go to **Settings** $\rightarrow$ **Pages** in the repository.
3. Under **Build and deployment**, select **Deploy from a branch** and set the source branch to `main` (or the folder where the dashboard is located).
4. Click **Save**. Your site will be live at `https://<username>.github.io/<repository>/pascube_dashboard/`.

## Embedding in Google Sites

If you want to use **Google Sites** as the host (as mentioned in your request), you can easily embed this dashboard:

### Method A: Embed URL (Recommended)
1. Deploy the dashboard to GitHub Pages (or any other hosting service like Vercel/Netlify).
2. Open your project on **Google Sites**.
3. In the right panel, select **Insert** $\rightarrow$ **Embed**.
4. Paste the URL of your hosted site (e.g., `https://<username>.github.io/<repository>/pascube_dashboard/`) and select **Whole page**.
5. Click **Insert** and resize the block as needed.

### Method B: Embed Code
If you do not want to host it externally, you can embed the entire application directly as code:
1. Open your project on **Google Sites**.
2. Select **Insert** $\rightarrow$ **Embed** $\rightarrow$ **Embed code**.
3. Paste the contents of `index.html` but replace the stylesheet link `<link rel="stylesheet" href="style.css">` and script tag `<script src="app.js"></script>` with the actual CSS from `style.css` and JavaScript from `app.js` inline:
   - Paste `style.css` content inside `<style> ... </style>` tags.
   - Paste `app.js` content inside `<script> ... </script>` tags.
4. Click **Next** and **Insert**. Google Sites will render it inside an iframe.
