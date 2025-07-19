# Enhanced ApiService Documentation

## Overview

The `ApiService` class provides a comprehensive HTTP client for communicating with the Spring Boot backend. It includes JWT authentication, error handling, and user-friendly snackbar notifications.

## Features

### 🔒 **JWT Authentication**
- Automatically includes JWT Bearer tokens in request headers
- Seamlessly integrates with `AuthService` for token management
- Handles token refresh and authentication failures

### 🎯 **Smart Error Handling**
- Custom `ApiException` class with detailed error information
- HTTP status code mapping to user-friendly messages
- Network timeout handling with 30-second timeout
- Comprehensive error categorization (401, 404, 500, etc.)

### 📱 **User Experience**
- Automatic success and error snackbars
- Context-aware messaging
- Color-coded notifications (green for success, red/orange for errors)
- Retry actions for server errors

### 🌐 **Full REST API Coverage**
- Authentication endpoints (signup, login)
- Loyalty card CRUD operations
- User profile management
- Server health monitoring

## Usage Examples

### Basic Setup

```dart
// Initialize in your main.dart or service provider
final authService = AuthService();
final apiService = ApiService(authService);
```

### Authentication

```dart
// User Registration
try {
  final user = await apiService.signup(
    email: 'user@example.com',
    password: 'password123',
    context: context, // Optional - shows success/error snackbars
  );
  print('User registered: ${user.email}');
} on ApiException catch (e) {
  print('Registration failed: ${e.message}');
}

// User Login
try {
  final loginData = await apiService.login(
    email: 'user@example.com',
    password: 'password123',
    context: context,
  );
  print('Login successful');
} on ApiException catch (e) {
  print('Login failed: ${e.message}');
}
```

### Loyalty Card Operations

```dart
// Get all cards
try {
  final cards = await apiService.getCards(context: context);
  print('Loaded ${cards.length} cards');
} on ApiException catch (e) {
  print('Failed to load cards: ${e.message}');
}

// Create a new card
final newCard = LoyaltyCard(
  cardName: 'Starbucks',
  barcodeData: '123456789',
  barcodeType: BarcodeType.code128,
  createdAt: DateTime.now(),
);

try {
  final createdCard = await apiService.createCard(
    newCard,
    context: context, // Shows "Card added successfully!" snackbar
  );
  print('Card created with ID: ${createdCard.id}');
} on ApiException catch (e) {
  print('Failed to create card: ${e.message}');
}

// Update an existing card
try {
  final updatedCard = await apiService.updateCard(
    cardId,
    updatedCardData,
    context: context,
  );
  print('Card updated successfully');
} on ApiException catch (e) {
  print('Update failed: ${e.message}');
}

// Delete a card
try {
  await apiService.deleteCard(
    cardId,
    cardName: 'Starbucks', // Optional - for better success message
    context: context,
  );
  print('Card deleted');
} on ApiException catch (e) {
  print('Delete failed: ${e.message}');
}
```

### User Profile Management

```dart
// Get current user profile
try {
  final user = await apiService.getCurrentUser(context: context);
  print('User: ${user.email}');
} on ApiException catch (e) {
  print('Failed to get profile: ${e.message}');
}

// Update user profile
try {
  final updatedUser = await apiService.updateUserProfile(
    updatedUserData,
    context: context,
  );
  print('Profile updated');
} on ApiException catch (e) {
  print('Update failed: ${e.message}');
}
```

## Error Handling

### ApiException Class

The `ApiException` class provides detailed error information:

```dart
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? details;
  final String operation;
}
```

### HTTP Status Code Mapping

| Status Code | User Message | Color | Action |
|-------------|--------------|-------|---------|
| 400 | Invalid request data | Red | - |
| 401 | Authentication failed. Please login again. | Orange | - |
| 403 | Access denied. Insufficient permissions. | Red | - |
| 404 | Resource not found | Grey | - |
| 409 | Resource already exists or conflict detected | Red | - |
| 422 | Validation error. Please check your input. | Red | - |
| 500+ | Server error. Please try again later. | Red | Retry button |

### Network Error Handling

```dart
try {
  final cards = await apiService.getCards(context: context);
} on SocketException {
  // Network timeout or connection error
  // Automatically shows "Network error. Please check your connection."
} on ApiException catch (e) {
  // API-specific errors with status codes
  // Automatically shows appropriate error message
} catch (e) {
  // Unexpected errors
  // Shows generic error message with exception details
}
```

## Snackbar Notifications

### Success Messages
- ✅ "Account created successfully!"
- ✅ "Login successful!"
- ✅ 'Card "[CardName]" added successfully!'
- ✅ 'Card "[CardName]" updated successfully!'
- ✅ '[CardName] deleted successfully!'
- ✅ "Profile updated successfully!"

### Error Messages
- ❌ "Authentication failed. Please login again."
- ❌ "Resource not found"
- ❌ "Server error. Please try again later." (with Retry button)
- ❌ "Network error. Please check your connection."
- ❌ "Validation error. Please check your input."

## Integration with CardService

The `CardService` class has been updated to work seamlessly with the enhanced `ApiService`:

```dart
class CardService extends ChangeNotifier {
  // All methods now accept optional BuildContext for snackbars
  
  Future<bool> loadCards({BuildContext? context}) async { ... }
  Future<bool> addCard(LoyaltyCard card, {BuildContext? context}) async { ... }
  Future<bool> deleteCard(int cardId, {String? cardName, BuildContext? context}) async { ... }
  Future<bool> updateCard(int cardId, LoyaltyCard card, {BuildContext? context}) async { ... }
}
```

## Configuration

### Base URL
The API base URL is configured in the `ApiService` class:

```dart
static const String baseUrl = 'http://localhost:8080/api';
```

For production, update this to your deployed backend URL.

### Timeout Configuration
All HTTP requests have a 30-second timeout:

```dart
.timeout(
  const Duration(seconds: 30),
  onTimeout: () => throw const SocketException('Connection timeout'),
)
```

## Security Features

1. **JWT Token Management**: Automatic inclusion of Bearer tokens
2. **Input Validation**: Server-side validation with user-friendly error messages
3. **Network Security**: HTTPS support (update baseUrl for production)
4. **Error Exposure**: Sensitive server details are not exposed to users

## Testing

### Health Check
```dart
final isHealthy = await apiService.checkServerHealth();
if (isHealthy) {
  print('Server is running');
} else {
  print('Server is unavailable');
}
```

### Manual Testing
1. Start your Spring Boot backend on `http://localhost:8080`
2. Run the Flutter app
3. Test authentication flows
4. Test card CRUD operations
5. Verify snackbar notifications appear correctly

## Best Practices

1. **Always pass context**: Include `context: context` parameter for better UX
2. **Handle exceptions**: Wrap API calls in try-catch blocks
3. **Check network status**: Handle `SocketException` for network issues
4. **Use loading states**: Show loading indicators during API calls
5. **Provide feedback**: Let users know when operations succeed or fail

## Troubleshooting

### Common Issues

1. **401 Unauthorized**: User needs to log in again
2. **Network timeouts**: Check internet connection and server status
3. **404 Not Found**: Resource doesn't exist or wrong endpoint
4. **500 Server Error**: Backend issue, check server logs

### Debugging

Enable debug prints by checking the Flutter debug console for:
- JWT token retrieval status
- HTTP response codes
- Error details
- Network connectivity issues

## Migration Guide

If upgrading from the previous ApiService:

1. **Method signatures**: Add optional `context` parameter to service calls
2. **Error handling**: Replace generic `Exception` with `ApiException`
3. **Success messages**: Remove manual snackbars (handled automatically)
4. **CardService**: Update to use new method signatures

### Before:
```dart
await cardService.addCard(card);
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Card added!')),
);
```

### After:
```dart
await cardService.addCard(card, context: context);
// Success snackbar shown automatically
```
