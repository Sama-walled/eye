# Retinopathy AI Detector - Flutter App

AI-powered retinopathy detection mobile application built with Flutter.

## Features

- Splash Screen with animated logo
- Onboarding screens with 3D eye visualization
- Login page with form validation
- Home page with photo upload and AI analysis
- Orange, white, and black color scheme
- AI-powered branding throughout

## Installation

1. Make sure you have Flutter installed (SDK >=3.0.0)
2. Install dependencies:

```bash
flutter pub get
```

## Running the App

```bash
flutter run
```

## Project Structure

```
lib/
  ├── main.dart              # App entry point
  ├── theme/
  │   └── app_theme.dart     # Theme configuration
  └── screens/
      ├── splash_screen.dart
      ├── onboarding_screen.dart
      ├── login_screen.dart
      └── home_screen.dart
```

## Dependencies

- shared_preferences: For storing onboarding and login status
- image_picker: For selecting images from gallery/camera
- lottie: For animations (optional)

## Color Scheme

- Primary Orange: #FF6B35
- Secondary Orange: #FF8C42
- Dark Black: #1A1A1A
- Light White: #FFFFFF
- Grey Background: #F5F5F5
