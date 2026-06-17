# Smart Scanner

Smart Scanner is a Flutter mobile app for warehouse and field inspections. Scan barcodes, QR codes, or text with OCR, build an inspection list with quantities, and export styled Excel spreadsheets to your device storage.

## Features

- **Barcode & QR scanning** — Live camera preview with a guided scan frame
- **OCR text scanning** — Capture text from labels and documents inside the frame
- **Inspection list** — Review scanned items, edit codes and quantities, and remove entries
- **Spreadsheet export** — Save inspection lists as `.xlsx` files with formatted headers and readable dates
- **Saved file list** — Browse, preview, share, send via Gmail, and delete exported files
- **Downloads storage** — Files are saved to `Download/Smart Scanner/` on Android

## Tech Stack

| Layer | Tools |
|-------|-------|
| Framework | Flutter (Dart 3) |
| State | Riverpod |
| Navigation | go_router |
| Camera / Barcode | mobile_scanner |
| OCR | google_mlkit_text_recognition |
| File storage | media_store_plus |
| Export | excel |
| Sharing | share_plus + native Gmail intent (Android) |

## Requirements

- Flutter SDK `^3.10.3`
- Android device or emulator with camera support (primary target)
- Gmail app installed on Android for the direct **Send** action (falls back to the system share sheet otherwise)

## Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd smart-scanner-flutter
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

### App icon & splash

Icons and splash screens are generated from `assets/icons/smart_scanner.png`:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## How to Use

1. Open the app and tap **Scanner** from the home screen.
2. Choose **Barcode / QR** or **OCR** mode.
3. Tap **Scan** (or **Scan Text** in OCR mode) to add items to the inspection list.
4. Adjust **Code** and **Quantity** for the active item, or edit quantities directly in the table.
5. Tap **Save** to export the list as an Excel file.
6. Open **Saved File List** to view, share, send by email, or delete exported files.

## Tests

```bash
flutter test
```

## Project Structure

```
lib/
├── core/           # Theme, routing, storage, shared widgets
├── features/
│   ├── home/       # Home screen
│   ├── scanner/    # Camera, scanning, inspection list
│   ├── save/       # Spreadsheet export
│   └── file_list/  # Saved file management
├── app.dart
└── main.dart
```

## License

Private project — not published to pub.dev.
