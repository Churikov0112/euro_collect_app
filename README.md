# Euro Pack Collection

Flutter app for collecting Euro player sticker packs. Open packs, reveal random players, and track your album progress.

## Features
- Album grid with owned/missing player cards.
- Pack opening flow with animated reveal.
- Persistent collection storage with Hive.
- BLoC-based state management.
- Prepared integration points for Yandex Mobile Ads (currently disabled in code).

## Tech Stack
- Flutter
- flutter_bloc
- Hive / hive_flutter
- yandex_mobileads (optional, currently commented out)

## Getting Started

### Prerequisites
- Flutter SDK `>=3.4.0 <4.0.0`
- Dart SDK (bundled with Flutter)


## Project Structure
- `lib/main.dart` app entrypoint and app-level wiring
- `lib/presentation/` UI screens and widgets
- `lib/presentation/blocs/` BLoC state management
- `lib/data/` repositories and data sources
- `lib/domain/` models and domain logic
- `assets/` images, icons, and other assets

## Notes
- The app is portrait-only (`SystemChrome.setPreferredOrientations` in `lib/main.dart`).
- Ad units and initialization are present but commented out in the UI screens.

## License
Public project (not published to pub.dev).
