# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Donkey Kong Arcade clone built with Flutter and Flame game engine. The game implements a basic version of the classic arcade game with platforms, ladders, barrels, and player movement.

## Project Structure

- `/lib/main.dart` - Entry point and main app structure
- `/lib/dkong_game.dart` - Core game implementation using Flame
- `/lib/scenes/` - Different game scenes (splash, menu, game, gameover, victory)
- `/lib/components/` - Game components (player, platforms, barrels, etc.)
- `/lib/widgets/` - UI widgets (d-pad, jump button)
- `/assets/` - Game assets (images, audio)

## Architecture

The game follows a scene-based architecture:
- `main.dart` contains the Flutter app and scene switching logic
- `dkong_game.dart` implements the core game using Flame
- Scenes are implemented as Flutter widgets
- Game components are implemented as Flame components
- Input is handled via custom widgets that communicate with the game

## Development Commands

### Flutter Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build for specific platform
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Game-specific Debugging

When working with the game logic, ensure to understand how the component system works in Flame. The game uses:
- `FlameGame` as the base class
- Scene switching via callbacks
- Input handling via custom widgets
- Component hierarchy for rendering

## Assets Management

Assets are defined in `pubspec.yaml` and should be placed in the appropriate directories:
- Images: `/assets/images/`
- Audio: `/assets/audio/`

After adding new assets, run:
```bash
flutter pub get
```

## Adding New Components

When adding new game components:
1. Create a new file in `/lib/components/`
2. Extend the appropriate Flame component class (e.g., `SpriteComponent`)
3. Implement `onLoad()` to load assets
4. Add the component to the game in `dkong_game.dart`

## Testing

To add tests for new components or game features:
1. Create test files in the `/test/` directory
2. Run tests with `flutter test`