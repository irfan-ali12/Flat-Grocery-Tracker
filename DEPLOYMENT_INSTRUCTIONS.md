# Flat Grocery Tracker — Deployment Instructions

Follow these steps to connect the Flutter app to your Google Sheet backend.

## 1. Create the Google Sheet

1. Go to [Google Sheets](https://sheets.google.com).
2. Create a new blank spreadsheet.
3. Rename the spreadsheet to something like **Flat Grocery Tracker**.

## 2. Add Headers

1. Rename the first sheet tab to **Groceries**.
2. In row 1, add these column headers:

| A | B | C | D | E |
|---|---|---|---|---|
| Timestamp | Item | Quantity | Cost | BoughtBy |

3. Optionally add a sample row:

| Timestamp | Item | Quantity | Cost | BoughtBy |
|---|---|---|---|---|
| 2026-06-01 10:00 | Milk | 2 | 600 | Ali |

## 3. Copy the Spreadsheet ID

1. Open your Google Sheet.
2. Look at the URL in your browser:

```
https://docs.google.com/spreadsheets/d/SPREADSHEET_ID_HERE/edit
```

3. Copy the long ID between `/d/` and `/edit`.

## 4. Open Apps Script

1. In your Google Sheet, click **Extensions** → **Apps Script**.
2. Delete any default code in the editor.

## 5. Paste the Backend Code

1. Open the file `apps_script_backend.gs` from this project.
2. Copy all of its contents.
3. Paste the code into the Apps Script editor.

## 6. Replace YOUR_GOOGLE_SHEET_ID

At the top of the script, replace:

```javascript
const SPREADSHEET_ID = "YOUR_GOOGLE_SHEET_ID";
```

with your actual spreadsheet ID, for example:

```javascript
const SPREADSHEET_ID = "1gtBT4p8hHHhKVfhOZp1oygJyaMuP2LTEJzqZ33GCp3A";
```

4. Click **Save** and name the project **Flat Grocery Tracker API**.

## 7. Deploy as Web App

1. In Apps Script, click **Deploy** → **New deployment**.
2. Click the gear icon next to **Select type**.
3. Choose **Web app**.
4. Fill in the settings:
   - **Description:** Flat Grocery Tracker API v1
   - **Execute as:** Me
   - **Who has access:** Anyone
5. Click **Deploy**.
6. Approve permissions when prompted.

## 8. Access Settings

Make sure your deployment uses:

- **Execute as:** Me (owner)
- **Who has access:** Anyone with link / Anyone

This allows the Flutter app to call the API without authentication.

## 9. Copy the Web App URL

After deployment, Google will show a **Web app URL** like:

```
https://script.google.com/macros/s/AKfycb.../exec
```

Copy this full URL.

## 10. Paste the Web App URL in the Flutter App

1. Open `lib/constants/api_constants.dart`.
2. Replace:

```dart
static const String apiUrl = "YOUR_APPS_SCRIPT_WEB_APP_URL";
```

with your deployed URL:

```dart
static const String apiUrl = "https://script.google.com/macros/s/AKfycb.../exec";
```

3. Save the file.
4. Rebuild or rerun the app.

## API Routes

The backend supports these routes:

- `GET {WEB_APP_URL}?path=list`
- `POST {WEB_APP_URL}?path=add`
- `POST {WEB_APP_URL}?path=update`

The Flutter app already uses these through `ApiConstants.listUrl`, `ApiConstants.addUrl`, and `ApiConstants.updateUrl`.

## Quick Test

Open this URL in your browser:

```
YOUR_WEB_APP_URL?path=list
```

You should see JSON like:

```json
{
  "success": true,
  "data": []
}
```

If that works, the backend is ready.
