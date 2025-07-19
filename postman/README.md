# Loyalty Card API - Postman Collection

This directory contains a comprehensive Postman collection for testing the Spring Boot loyalty card API endpoints.

## Files Included

- `Loyalty_Card_API_Collection.json` - Main Postman collection with all API endpoints
- `Loyalty_Card_API_Environment.json` - Environment variables for the collection

## Quick Start

1. **Import Collection**: Import both JSON files into Postman
2. **Set Environment**: Select "Loyalty Card API - Local" environment
3. **Start Server**: Ensure your Spring Boot server is running on `http://https://cardkeep-backend.onrender.com`
4. **Run Tests**: Execute the collection in order

## API Endpoints Included

### Authentication
- **POST /api/auth/signup** - Register a new user
- **POST /api/auth/login** - Login and get JWT token

### Loyalty Cards (Protected Routes)
- **GET /api/cards** - Get all user's loyalty cards
- **POST /api/cards** - Create a new loyalty card
- **GET /api/cards/{id}** - Get specific card by ID
- **PUT /api/cards/{id}** - Update existing card
- **DELETE /api/cards/{id}** - Delete a card

### Health Check
- **GET /api/health** - Server health status

## Sample Data

### User Registration/Login
```json
{
    "email": "testuser@example.com",
    "password": "password123"
}
```

### Create Loyalty Card
```json
{
    "cardName": "Checkers Xtra Savings",
    "barcodeData": "1122334455667",
    "barcodeType": "EAN13",
    "storeLogoUrl": "https://example.com/checkers-logo.png"
}
```

### Supported Barcode Types
- `CODE128`
- `CODE39` 
- `EAN13`
- `EAN8`
- `UPCA`
- `UPCE`
- `QRCODE`
- `PDF417`

## Environment Variables

The collection uses these environment variables (automatically managed):

- `base_url` - API base URL (https://cardkeep-backend.onrender.com/api)
- `jwt_token` - JWT token from login (auto-populated)
- `user_id` - Current user ID (auto-populated)
- `user_email` - Current user email (auto-populated)
- `created_card_id` - ID of newly created card (auto-populated)
- `first_card_id` - ID of first card in list (auto-populated)

## Test Scripts

Each request includes automated tests that:

- ✅ Verify response status codes
- ✅ Validate response structure
- ✅ Check required fields
- ✅ Store tokens and IDs for subsequent requests
- ✅ Measure response times

## Usage Workflow

1. **Register User** - Run signup endpoint to create test account
2. **Login** - Run login endpoint to get JWT token (auto-stored)
3. **Get Cards** - Retrieve user's existing cards
4. **Create Card** - Add new loyalty card (ID auto-stored)
5. **Update Card** - Modify the created card
6. **Delete Card** - Remove the test card

## Production Setup

For production testing:

1. Update `base_url` in environment to your production API
2. Replace `https://cardkeep-backend.onrender.com/api` with your production URL
3. Ensure HTTPS is used for production endpoints
4. Update authentication credentials as needed

## Response Examples

### Successful Login Response
```json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "type": "Bearer",
    "expiresIn": 86400,
    "user": {
        "id": "user123",
        "email": "testuser@example.com",
        "createdAt": "2025-07-19T10:30:00Z",
        "roles": ["ROLE_USER"]
    }
}
```

### Card List Response
```json
[
    {
        "id": 1,
        "cardName": "Starbucks Rewards",
        "barcodeData": "1234567890123",
        "barcodeType": "EAN13",
        "storeLogoUrl": "https://example.com/starbucks-logo.png",
        "createdAt": "2025-07-19T08:30:00Z"
    }
]
```

### Error Response
```json
{
    "error": "Unauthorized",
    "message": "JWT token is missing or invalid",
    "timestamp": "2025-07-19T10:30:00Z"
}
```

## Authentication Flow

1. All loyalty card endpoints require JWT authentication
2. Include JWT token in Authorization header: `Bearer <token>`
3. Tokens expire after 24 hours (86400 seconds)
4. Re-login to get fresh token if expired

## Testing Notes

- Tests automatically handle token management
- Failed authentication tests are included for edge cases
- Validation error examples show required field constraints
- Response time tests ensure API performance
- Collection can be run with Postman's Collection Runner for automated testing
