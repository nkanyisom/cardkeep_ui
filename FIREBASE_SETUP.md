# Firebase Configuration Instructions

## 🔧 Configuration Required

Your Flutter app is now ready for Firebase Auth with the following features:
- ✅ Email/Password authentication
- ✅ Google Sign-In integration  
- ✅ JWT token storage with SharedPreferences
- ✅ Automatic token management

## 🚀 Firebase Setup Steps

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it "loyalty-card-app" (or your preference)
4. Enable Google Analytics (optional)

### 2. Configure Android App
1. In Firebase Console, click "Add app" → Android
2. **Android package name**: `za.co.jbrew.sto_karata_ui`
3. **App nickname**: "Loyalty Card App"
4. **Debug signing certificate SHA-1**: Get from Android Studio or use:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

### 3. Configure iOS App (Optional)
1. In Firebase Console, click "Add app" → iOS  
2. **iOS bundle ID**: `za.co.jbrew.stoKarataUi`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### 4. Enable Authentication Methods
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google** sign-in
   - Add your app's SHA-1 fingerprint
   - Add support email

## 📱 Android Configuration Files

### android/app/build.gradle
Add to the bottom of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Add to dependencies section:
```gradle
implementation 'com.google.firebase:firebase-auth'
implementation 'com.google.android.gms:play-services-auth'
```

### android/build.gradle  
Add to dependencies in buildscript:
```gradle
classpath 'com.google.gms:google-services:4.3.15'
```

## 🔑 Updated AuthService Methods

Your AuthService now includes:

```dart
// Email authentication
Future<bool> signUpWithEmail({required String email, required String password})
Future<bool> signInWithEmail({required String email, required String password})

// Google authentication  
Future<bool> signInWithGoogle()

// Token management
Future<String?> getIdToken()
Future<String?> refreshToken()
String? get jwtToken

// Sign out
Future<void> signOut()
```

## 🔗 Integration Features

- **Automatic JWT Storage**: Tokens saved to SharedPreferences
- **API Integration**: ApiService automatically uses stored tokens
- **Provider State Management**: AuthService available throughout app
- **Google Sign-In UI**: Added to LoginScreen with Material Design

## 📋 Next Steps

1. **Install Flutter** (if not done): Follow `FLUTTER_SETUP.md`
2. **Add Firebase config files** as described above
3. **Run the app**: `flutter run`
4. **Test authentication**: Try email signup and Google sign-in

## 🎯 Usage Example

```dart
// In your widget
final authService = context.read<AuthService>();

// Email signup
await authService.signUpWithEmail(
  email: "user@example.com", 
  password: "password123"
);

// Google sign-in
await authService.signInWithGoogle();

// Get token for API calls
final token = await authService.getIdToken();
```

## 🔍 Error Handling

The AuthService provides comprehensive error messages for:
- Invalid email format
- Weak passwords  
- User not found
- Network errors
- Google sign-in failures

All errors are available via `authService.errorMessage`.
