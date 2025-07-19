# 📱 CardKeep - Digital Loyalty Card Wallet

**Keep all your loyalty cards in one secure digital wallet**

CardKeep is a modern Flutter web application that allows you to scan, store, and manage all your loyalty cards in one convenient location. Say goodbye to bulky wallets and never lose your reward points again!

## ✨ Features

- � **Barcode Scanning** - Scan any loyalty card barcode or QR code
- � **Secure Storage** - Your cards are stored securely with offline support
- � **Auto Sync** - Seamlessly sync across devices
- 🌐 **Web & Mobile** - Works on any device with a web browser
- 🔒 **Firebase Auth** - Secure authentication with Google Sign-In
- 📊 **Card Management** - Organize and categorize your cards
- ⚡ **Lightning Fast** - Built with Flutter for optimal performance

## 🏗️ Built With

- **Flutter** - UI framework
- **Firebase** - Authentication and backend services
- **Hive** - Local database for offline storage
- **Provider** - State management
- **Camera & ML Kit** - Barcode scanning capabilities

## 📱 Supported Platforms

- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **Android** (via web browser)
- ✅ **iOS** (via web browser)
- 🔄 **Native Mobile Apps** (coming soon)
- **Reusable widgets** for consistent UI

## Folder Structure

```
lib/
├── models/          # Data models (LoyaltyCard, User)
├── services/        # API clients and business logic
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── card_service.dart
│   ├── firebase_messaging_service.dart
│   └── barcode_scanner_service.dart
├── screens/         # UI screens
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── cards_list_screen.dart
│   └── add_card_screen.dart
└── widgets/         # Reusable UI components
    ├── custom_button.dart
    ├── custom_text_field.dart
    └── card_tile.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Firebase project setup
- Running Spring Boot backend API

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sto_karata_ui
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

4. **Configure API endpoint**
   - Update the base URL in `lib/services/api_service.dart` if needed
   - Default: `https://cardkeep-backend.onrender.com/api`

5. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Configuration

### Android Setup
1. Add `google-services.json` to `android/app/`
2. Package name: `za.co.jbrew.sto_karata_ui`
3. Camera permission is already configured in `AndroidManifest.xml`

### iOS Setup
1. Add `GoogleService-Info.plist` to `ios/Runner/`
2. Bundle identifier: `za.co.jbrew.stoKarataUi`
3. Camera permission is already configured in `Info.plist`

## API Integration

The app integrates with a Spring Boot REST API:

- **Base URL**: `https://cardkeep-backend.onrender.com/api`
- **Authentication**: JWT Bearer tokens
- **Endpoints**:
  - `POST /auth/signup` - User registration
  - `POST /auth/login` - User login
  - `GET /cards` - Get user's loyalty cards
  - `POST /cards` - Add new loyalty card
  - `DELETE /cards/{id}` - Delete loyalty card

## State Management

The app uses the Provider pattern for state management:

- `AuthService` - Manages authentication state
- `CardService` - Manages loyalty cards state
- Global state accessible throughout the widget tree

## Permissions

### Android
- `CAMERA` - For barcode scanning
- `INTERNET` - For API calls

### iOS
- `NSCameraUsageDescription` - For barcode scanning

## Development

### Code Style
- Follow Flutter naming conventions
- Use null safety features
- Implement proper error handling
- Add const constructors where possible

### Testing
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

### Building

```bash
# Android APK
flutter build apk

# iOS
flutter build ios
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure Firebase configuration files are properly added
   - Check that `Firebase.initializeApp()` is called in `main.dart`

2. **Barcode scanner not working**
   - Verify camera permissions are granted
   - Test on physical device (camera doesn't work in simulator)

3. **API connection issues**
   - Ensure backend server is running
   - Check network connectivity
   - Verify API endpoints and authentication

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.
