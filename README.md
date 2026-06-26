# Flashlight App

A simple Flutter flashlight (torch light) app that uses your device's camera flash to turn the light on and off.

## Features

- ✨ Simple and intuitive UI
- 💡 Turn flashlight on/off with a single tap
- ⏱️ Auto-off timer for battery saving
- 📱 Works on both Android and iOS devices
- ⚡ Fast and responsive

## Requirements

- Flutter SDK (2.18.0 or higher)
- Android: API 21 or higher
- iOS: iOS 11.0 or higher
- Device with flashlight/camera flash support

## Installation

1. **Clone or download the project**
   ```bash
   cd "New Flash Light"
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Permissions

### Android
Add the following to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.FLASHLIGHT" />
```

### iOS
Add the following to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to control the flashlight</string>
```

## Usage

1. Launch the app
2. Tap the "Turn On" button to enable the flashlight
3. Tap the "Turn Off" button to disable the flashlight
4. The app will display the current status (ON/OFF)

## Project Structure

```
lib/
├── main.dart          # Main app entry point and UI
pubspec.yaml          # Project dependencies
android/              # Android platform code
ios/                  # iOS platform code
```

## Troubleshooting

- **Flashlight not working**: Make sure your device has a camera flash
- **Permission denied**: Check that camera permissions are granted
- **App crashes**: Make sure you've run `flutter pub get` to install all dependencies

## Building for Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Author

Created as a simple Flutter demo app.

## License

This project is open source and available under the MIT License.
