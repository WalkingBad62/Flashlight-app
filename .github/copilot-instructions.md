- Project Type: Flutter (Mobile Application)
- Main Language: Dart
- Purpose: Simple flashlight/torch light app using device camera flash
- Key Dependencies: flutter, torch_light
- Target Platforms: Android (API 21+), iOS (11.0+)

## Setup Steps

1. Run `flutter pub get` to install dependencies
2. Configure Android permissions in `android/app/src/main/AndroidManifest.xml`
3. Configure iOS permissions in `ios/Runner/Info.plist`
4. Run `flutter run` to launch the app

## Running the App

```bash
flutter run
```

To run on a specific device:
```bash
flutter run -d <device_id>
flutter devices  # List available devices
```

## Building for Release

Android:
```bash
flutter build apk --release
flutter build appbundle --release
```

iOS:
```bash
flutter build ios --release
```
