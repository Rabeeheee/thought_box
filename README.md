# CurrencyX - Currency Rate Calculator

Hey there! This is a currency converter app I built for the ThoughtBox machine test. It's a fully functional Flutter app with Firebase authentication, smart offline caching, and some nice animations to make it feel polished.

## What does it do?

Pretty straightforward - you can convert between different currencies (USD, EUR, GBP, etc.), and the app remembers your recent conversions so you can quickly check them again even when you're offline. There's also a simple chart showing how the exchange rate has changed over the last 5 days (using mock data for now, but it could easily be hooked up to real historical data).

The cool part is that I've focused on making it work well offline. Once you've converted something, it gets cached locally, so if you lose your internet connection, you can still view your recent conversions without any issues.

## Tech Stack

I went with Clean Architecture and BLoC for state management because they're solid patterns for Flutter apps. Here's what I used:

Flutter 3.16.0+ and Dart 3.2.0+
Firebase for user authentication (email/password)
BLoC pattern for state management (no setState calls anywhere!)
GetIt for dependency injection
Dio for API calls
SharedPreferences for caching
fl_chart for the trend graphs
flutter_animate for smooth animations
How it's structured
The app follows Clean Architecture with three main layers:



Presentation Layer (UI + BLoC)
        ↓
Domain Layer (Business Logic)
        ↓
Data Layer (API + Cache)

The presentation layer handles all the UI stuff and user interactions through BLoC. The domain layer defines what the app should do (like "convert currency" or "login user"), and the data layer actually does it by talking to the API or local storage.

## Here's the actual folder structure:

```
lib/
├── core/              # Shared stuff like themes, constants, utilities
├── data/              # API calls, caching, data models
├── domain/            # Repository interfaces (contracts)
├── presentation/      # Screens, widgets, and BLoCs
└── main.dart
```
## Getting Started

What you need
Flutter 3.16.0 or newer
A Firebase project (free tier is fine)
An internet connection for the first run

## Setup

## 1. Clone and install dependencies

Bash
``
git clone https://github.com/Rabeeheee/thought_box.git
cd currency-converter
flutter pub get
``
## 2. Firebase setup

This is probably the most important part. You'll need to:

Go to Firebase Console and create a new project
Add an Android app (package name: com.example.currency_converter)
Download the google-services.json file and put it in android/app/
In Firebase Console, go to Authentication and enable "Email/Password" sign-in
For iOS (if you need it):

Add an iOS app (bundle ID: com.example.currencyConverter)
Download GoogleService-Info.plist and put it in ios/Runner/
## 3. Update your Android build files

In android/build.gradle, make sure you have:

gradle

dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
In android/app/build.gradle, add this at the bottom:

gradle

apply plugin: 'com.google.gms.google-services'
And set the minSdkVersion to at least 21.

## 4. Run it

Bash
``
flutter run
That should do it! You'll see a splash screen, then a login page.
``
Running with different modes
I've set it up so you can run with the real API or with mock data:

Real API (default):

Bash
``
flutter run --dart-define=BASE_URL=https://api.exconvert.com \
            --dart-define=ACCESS_KEY=270ca084-96a82de7-ae4aff0f-60b941d9
Mock mode (no internet needed):
``
Bash
``
flutter run --dart-define=USE_MOCK=true
Mock mode is great for demos or when you're working on UI stuff and don't want to keep hitting the API.
``

How the caching works
This was one of the more interesting parts to build. Here's how it works:

When you convert a currency (let's say 100 USD to EUR), the app:

Checks if we already have this exact conversion cached
If yes, and it's less than 30 minutes old, it shows the cached result instantly
If no (or expired), it calls the API, shows the result, and saves it to cache
The cache key looks like this: conversion_USD_EUR_100.0

But there's more! The app also saves a "last conversion" for each currency pair (without the amount). So when you click on a recent conversion, it can show you the result even if you're offline, even if the amount was different.

Cache expires after 30 minutes. You can change this in lib/core/constants/app_constants.dart:


static const int cacheTTLMinutes = 30;  
When you logout, everything gets cleared for privacy.

## Error handling
Network stuff can be unreliable, so I've tried to handle errors gracefully:

No internet?

The app will try to show you cached data
Recent conversions still work
You'll see a friendly message if there's no cached data
API errors?

Timeout? You get a retry button
Rate limited? The app tells you to wait
Server error? Retry button again
Completely offline?

You can still browse your previously converted amounts
New conversions obviously won't work, but the app won't crash
The error handling happens in layers:

API layer catches network errors (timeouts, connection issues)
Repository layer converts them to user-friendly messages
BLoC layer manages the state
UI layer shows appropriate messages and retry options
The architecture in action
Let me walk you through what happens when you convert USD to EUR:

You type "100" and tap the Convert button
The home screen triggers a ConvertCurrencyRequested event
ConversionBloc receives it and emits ConversionLoading state
UI shows a loading shimmer
BLoC calls CurrencyRepository.convertCurrency()
Repository checks the cache first
If cache miss, it calls the API via CurrencyApi
API returns the result
Repository saves it to cache and returns Right(response)
BLoC emits ConversionSuccess state
UI rebuilds and shows the animated result card
If anything fails along the way, it returns Left(failure) instead, and the UI shows an error message.

## Building for production

### To build an APK:

Bash
``
flutter build apk --release \
  --dart-define=BASE_URL=https://api.exconvert.com \
  --dart-define=ACCESS_KEY=270ca084-96a82de7-ae4aff0f-60b941d9
You'll find the APK in build/app/outputs/flutter-apk/app-release.apk
``
For iOS:

Bash
```
flutter build ios --release \
  --dart-define=BASE_URL=https://api.exconvert.com \
  --dart-define=ACCESS_KEY=270ca084-96a82de7-ae4aff0f-60b941d9
Common issues and fixes
Firebase not working?

Double-check that google-services.json is in the right place (android/app/)
Make sure the package name matches exactly
Confirm Email/Password authentication is enabled in Firebase Console
API calls failing?

Try mock mode first: flutter run --dart-define=USE_MOCK=true
Check if you can access the API directly in your browser
Make sure your internet connection is working
Build errors?
```
Bash
```
flutter clean
flutter pub get
flutter run
This fixes like 80% of build issues.
```
App crashes on startup?

Check if Firebase is initialized correctly
Look at the logs: flutter logs
Try running on a different device/emulator
Project highlights
A few things I'm particularly happy with:

Zero setState calls: Everything uses BLoC for state management. Even password visibility toggles and form validation errors go through BLoC events. It's completely reactive.

Offline-first: The app works surprisingly well without internet. Recent conversions are always available, and the UI clearly indicates when you're looking at cached data.

Animations: I spent time making interactions feel smooth - the result card slides up with a count-up animation, there's a shake effect on validation errors, the currency picker has hero animations, etc.

Error messages: Instead of generic "Something went wrong", the app gives you specific, helpful messages and retry options.

Clean code: I've tried to keep files small and focused. Each widget has a single responsibility, and the BLoC layer is completely separate from the UI.

Testing
Run the tests with:

Bash
``
flutter test
``
For coverage:

Bash
``
flutter test --coverage
``
I've focused testing on the BLoC layer and repository implementations since that's where the critical business logic lives.

What could be better
If I had more time, here's what I'd add:

Real historical data for the trend chart (instead of mock data)
More currencies
Ability to favorite certain currency pairs
A proper settings screen
Unit tests for all BLoCs and repositories
Widget tests for key user flows
Support for more languages
The dependencies

## Main ones:

flutter_bloc and equatable for state management
firebase_core and firebase_auth for authentication
dio for HTTP requests
shared_preferences for caching
fl_chart for the trend graphs
flutter_animate for animations
get_it for dependency injection
dartz for the Either pattern (functional error handling)
Check pubspec.yaml for the complete list.

Notes for reviewers
A few things to note:

The API key is hardcoded in the env config with a default value, but the proper way to run it is with --dart-define
I've used mock data for the 5-day trend because the free API doesn't provide historical data
The cache TTL is set to 30 minutes, but it's easily configurable
I've tested on Android primarily, but it should work fine on iOS too
Running a quick demo
Want to see it in action? Here's the fastest way:

### Clone the repo

Run flutter pub get
Add your Firebase config (or let me know if you need a demo Firebase project)
Run with mock mode: flutter run --dart-define=USE_MOCK=true
The app will work completely offline with fake data
For the real experience with the API:

## Screenshots

<img src="https://github.com/user-attachments/assets/6a13250c-40ab-43a1-956f-c9e57ba0cd05" alt="Login Screen" width="250"/>
<img src="https://github.com/user-attachments/assets/8e859622-61b1-48a3-8ca9-7f27c2ac7cd6" alt="Home Screen" width="250"/>
<img src="https://github.com/user-attachments/assets/969d8850-615a-4833-8230-947319d30257" alt="Trend Screen" width="250"/>


## Contact

## If you have questions or run into issues:

Email: rabeehm802@gmail.com
GitHub: github.com/Rabeeheee
Built with Flutter 3.16.0
Last updated: January 2024

