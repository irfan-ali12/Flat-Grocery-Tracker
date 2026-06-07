# Flat Grocery Tracker

A simple grocery expense tracker for a shared apartment or flat. Built with Flutter and backed by Google Sheets through Google Apps Script.

## Project Overview

Flat Grocery Tracker helps flatmates record grocery purchases, see who bought what, and track total shared expenses. The app uses a lightweight architecture with no Firebase and no authentication in v1.

## Architecture

```
Flutter App
     ↓ REST API
Google Apps Script Web App
     ↓
Google Sheet
```

## Features

- View all grocery items
- Add new grocery entries
- Edit existing entries
- See total expenses
- Pull-to-refresh
- Material 3 UI with a green grocery theme
- Google Sheets as the database

## Folder Structure

```
lib/
 ├── main.dart
 ├── constants/
 │   └── api_constants.dart
 ├── models/
 │   └── grocery_item.dart
 ├── services/
 │   ├── api_service.dart
 │   └── grocery_provider.dart
 ├── screens/
 │   ├── home_screen.dart
 │   └── add_item_screen.dart
 └── widgets/
     ├── grocery_item_card.dart
     ├── total_expenses_card.dart
     └── empty_state.dart
```

## Dependencies

- `http` — API calls
- `provider` — state management
- `intl` — currency formatting

## Flutter Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. Clone or open this project.
3. Run:

```bash
flutter pub get
```

## Backend Setup

1. Create a Google Sheet named **Groceries** with columns:
   - Timestamp
   - Item
   - Quantity
   - Cost
   - BoughtBy
2. Copy `apps_script_backend.gs` into Google Apps Script.
3. Replace `YOUR_GOOGLE_SHEET_ID` with your spreadsheet ID.
4. Deploy as a Web App.

See [DEPLOYMENT_INSTRUCTIONS.md](DEPLOYMENT_INSTRUCTIONS.md) for full step-by-step instructions.

## Google Apps Script Deployment

1. Open your Google Sheet.
2. Go to **Extensions** → **Apps Script**.
3. Paste the code from `apps_script_backend.gs`.
4. Replace `YOUR_GOOGLE_SHEET_ID`.
5. Deploy as **Web app**.
6. Set:
   - Execute as: **Me**
   - Access: **Anyone with link**
7. Copy the deployed Web App URL.

## Replace API URL

Open `lib/constants/api_constants.dart` and replace:

```dart
static const String apiUrl = "YOUR_APPS_SCRIPT_WEB_APP_URL";
```

with your deployed Apps Script Web App URL.

## Run the App

```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```

## APK Output Path

After a successful release build, the APK will be at:

```
build/app/outputs/flutter-apk/app-release.apk
```

## Google Sheet Example

| Timestamp | Item | Quantity | Cost | BoughtBy |
|---|---|---|---|---|
| 2026-06-01 10:00 | Milk | 2 | 600 | Ali |

## Notes

- No Firebase
- No authentication in v1
- Internet permission is included for Android
- Currency is formatted as `Rs 1,250`
