# Currency Converter 🌍

A professional, high-performance currency converter built with Flutter. This project features a modern UI, real-time exchange rates, and a seamless user experience.

## 🚀 Features

- **Real-time Conversion**: Get the latest exchange rates using the ExchangeRate-API.
- **Dark & Light Mode**: Seamless theme switching with persistent storage.
- **Interactive UI**: Smooth animations using `AnimatedContainer`, `AnimatedSwitcher`, and `AnimatedRotation`.
- **Currency Search & Favorites**: Easily find and bookmark your most-used currencies.
- **Connectivity Handling**: Built-in error handling for network issues.
- **Material 3 Design**: Follows the latest Material Design guidelines for a modern look.

## 📸 Screenshots

| Splash Screen | Home Screen (Light) | Home Screen (Dark) |
| :---: | :---: | :---: |
| ![Splash](assets/image/logo.png) | [Placeholder for Light Mode] | [Placeholder for Dark Mode] |

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: StatefulWidgets (Cleanly refactored)
- **Networking**: `http` package
- **Storage**: `shared_preferences`
- **Animations**: `animated_splash_screen`
- **API**: [ExchangeRate-API](https://www.exchangerate-api.com/)

## 📦 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/currency_convert.git
   ```
2. **Navigate to the project directory:**
   ```bash
   cd currency_convert
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```

## 🏗 Project Structure

```text
lib/
├── main.dart                 # App entry point
├── splash_screen.dart        # Animated splash screen
├── currency_converter.dart   # Main UI screen
├── services/
│   └── currency_service.dart # API & Business logic
└── utils/
    └── currency_data.dart    # Constants & Currency data
```

## 📄 License

This project is licensed under the MIT License.
