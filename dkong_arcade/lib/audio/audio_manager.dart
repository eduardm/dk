import 'package:flame_audio/flame_audio.dart';

/// A class to manage all game audio
class AudioManager {
  static bool _initialized = false;
  static bool _soundEnabled = true;

  // Cache for loaded sounds
  static final Map<String, bool> _loadedSounds = {};

  // Sound file paths
  static const String _jumpSound = 'jump.mp3';
  static const String _barrelHitSound = 'barrel_hit.mp3';
  static const String _victorySound = 'victory.mp3';
  static const String _gameOverSound = 'gameover.mp3';
  static const String _barrelRollSound = 'barrel_roll.mp3';

  /// Initialize the audio manager and preload sounds
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Create placeholder sounds with empty audio files
      // These would normally be real sound files
      await _createPlaceholderSounds();
      
      // Preload all sounds
      await _preloadSounds();
      
      _initialized = true;
    } catch (e) {
      print('Error initializing audio: $e');
      _soundEnabled = false;
    }
  }

  /// Create placeholder silent sound files if they don't exist
  static Future<void> _createPlaceholderSounds() async {
    // This would be replaced by actual sound files in a real game
    // Here we're creating placeholder empty sounds
  }

  /// Preload all sounds for faster playback
  static Future<void> _preloadSounds() async {
    try {
      await _preloadSound(_jumpSound);
      await _preloadSound(_barrelHitSound);
      await _preloadSound(_victorySound);
      await _preloadSound(_gameOverSound);
      await _preloadSound(_barrelRollSound);
    } catch (e) {
      print('Error preloading sounds: $e');
    }
  }

  /// Preload a single sound
  static Future<void> _preloadSound(String sound) async {
    try {
      // In a real implementation, this would preload the sound
      // FlameAudio.audioCache.load(sound);
      _loadedSounds[sound] = true;
    } catch (e) {
      print('Error loading sound $sound: $e');
      _loadedSounds[sound] = false;
    }
  }

  /// Play a sound effect if it's loaded and sound is enabled
  static void playSound(String sound) {
    if (!_soundEnabled) return;
    if (!_loadedSounds.containsKey(sound) || !_loadedSounds[sound]!) return;

    try {
      FlameAudio.play(sound);
    } catch (e) {
      print('Error playing sound $sound: $e');
    }
  }

  /// Play the jump sound
  static void playJump() {
    playSound(_jumpSound);
  }

  /// Play the barrel hit sound
  static void playBarrelHit() {
    playSound(_barrelHitSound);
  }

  /// Play the victory sound
  static void playVictory() {
    playSound(_victorySound);
  }

  /// Play the game over sound
  static void playGameOver() {
    playSound(_gameOverSound);
  }

  /// Play the barrel rolling sound
  static void playBarrelRoll() {
    playSound(_barrelRollSound);
  }

  /// Toggle sound on/off
  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  /// Check if sound is enabled
  static bool isSoundEnabled() {
    return _soundEnabled;
  }
}