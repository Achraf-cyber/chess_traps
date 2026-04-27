# Chess Traps ♟️

**Chess Traps** is a comprehensive, open-source Flutter application designed to help chess players learn, practice, and master opening traps. 

By leveraging the power of local chess engines and an interactive UI, players can study the traps and play through them in a realistic practice mode to ensure they're ready to use them in real games.

## ✨ Features
* **Extensive Trap Library**: Browse through a curated list of popular and obscure chess opening traps.
* **Interactive Practice Mode**: Play through the traps move-by-move. The app uses an auto-reply mechanism to simulate the opponent's moves, helping you build muscle memory.
* **Real-time Engine Analysis**: Powered by the Stockfish chess engine running locally on your device to analyze positions and evaluate moves.
* **Lichess Integration**: Built using the high-quality, open-source `chessground` and `dartchess` packages from Lichess for an authentic and smooth board experience.
* **Daily Reminders**: Get notified with a "Trap of the Day" to keep your training consistent.
* **Multi-Language Support**: Fully localized in English, French, Spanish, and Arabic.
* **Theming**: Premium UI with support for both Light and Dark modes.

## 🛠 Tech Stack
* **Framework**: [Flutter](https://flutter.dev/)
* **State Management**: [Riverpod](https://riverpod.dev/) (with code generation)
* **Chess Board & Logic**: `chessground` & `dartchess`
* **Chess Engine**: `stockfish` (Local engine execution)
* **Backend / Analytics**: Firebase (Crashlytics, Analytics, Remote Config)
* **Monetization**: Google Mobile Ads

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.10.0 or higher)
* Dart SDK

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Achraf-cyber/chess_traps.git
   cd chess_traps
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run code generation (required for Riverpod, Freezed, and Assets):
   ```bash
   dart run build_runner build -d
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## 📜 Development Scripts
This project uses several tools to automate development tasks. You can run them using the following commands:

* **Generate Code (Riverpod/Freezed)**: `dart run build_runner build -d`
* **Generate Assets**: `dart run asset_gen`
* **Rename App Package**: `dart run package_rename`
* **Generate App Icons**: `dart run icons_launcher:create`

## 📄 License
This project is open-source and licensed under the **GNU General Public License v3.0 (GPL-3.0)**. 

Because this application integrates GPL-licensed libraries (such as the Lichess packages), the entire application is distributed under the GPL-3.0 license. See the [LICENSE](LICENSE) file for more details.
