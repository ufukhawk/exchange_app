# Exchange Rates App

A Flutter application that displays real-time currency exchange rates from the Turkish Central Bank (TCMB).

## Features

- 📊 Real-time exchange rates from TCMB API
- 💱 Currency conversion calculator
- 📅 Historical rates with date selection
- 🌐 Multi-language support (Turkish & English)
- 🎨 Multiple state management implementations (BLoC, GetX, MobX)
- 📱 Responsive UI with Material Design 3
- ✅ Comprehensive test coverage

## Architecture

- Clean Architecture
- SOLID Principles
- Dependency Injection
- Either pattern for error handling (fpdart)

## Getting Started

### Prerequisites

- Flutter SDK (3.5.4 or higher)
- Dart SDK (3.5.4 or higher)

### Installation

```bash
# Clone the repository
git clone <repository-url>

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## State Management

The app demonstrates three different state management solutions:

- **BLoC** - Default implementation
- **GetX** - Lightweight alternative
- **MobX** - Reactive approach

Switch between them in Settings.

## Tech Stack

- Flutter & Dart
- http - API calls
- xml - XML parsing
- fpdart - Functional programming
- flutter_bloc - State management
- get - Navigation & DI
- mobx - Reactive state
- shared_preferences - Local storage
- connectivity_plus - Network status

## License

This project is licensed under the MIT License.
