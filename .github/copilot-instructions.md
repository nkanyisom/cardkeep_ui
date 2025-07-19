<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Flutter Loyalty Card App - Copilot Instructions

## Project Overview
This is a Flutter application for managing loyalty cards with the following key features:
- Firebase Authentication (email/password)
- Barcode/QR code scanning capabilities  
- REST API integration with JWT authentication
- State management using Provider pattern
- Firebase Cloud Messaging for push notifications

## Architecture & Patterns
- **State Management**: Use Provider pattern for app-wide state
- **Folder Structure**: 
  - `lib/models/` - Data models with null safety
  - `lib/services/` - API clients, Firebase services, business logic
  - `lib/screens/` - UI pages/screens
  - `lib/widgets/` - Reusable UI components
- **Null Safety**: All code should use null safety features
- **Material Design**: Follow Material Design 3 principles

## Key Dependencies
- `provider` - State management
- `firebase_core`, `firebase_auth`, `firebase_messaging` - Firebase integration
- `flutter_barcode_scanner` - Barcode scanning
- `http` - REST API calls

## Code Style Guidelines
- Use `const` constructors wherever possible
- Implement proper error handling with try-catch blocks
- Follow Flutter naming conventions (camelCase for variables, PascalCase for classes)
- Use meaningful variable and function names
- Add proper validation for user inputs
- Handle loading states and error states in UI

## Firebase Integration
- Use Firebase Auth for user authentication
- Implement proper token management for API calls
- Handle auth state changes properly
- Use Firebase Messaging for push notifications

## API Integration
- Base URL: `http://localhost:8080/api`
- Authentication: JWT Bearer tokens
- Endpoints: `/auth/signup`, `/auth/login`, `/cards` CRUD operations
- Always include proper error handling for network requests

## UI/UX Guidelines
- Use Material Design components
- Implement responsive layouts
- Add loading indicators for async operations
- Show meaningful error messages to users
- Use proper navigation patterns

## Security Considerations
- Store sensitive data securely
- Validate all user inputs
- Handle authentication tokens properly
- Implement proper permission requests for camera access

When generating code for this project, prioritize null safety, proper error handling, and follow the established architectural patterns.
