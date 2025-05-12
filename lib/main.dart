import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'package:tiny_tunes/bandroom_screen.dart';
import 'package:tiny_tunes/guesssound_screen.dart';
import 'package:tiny_tunes/makeasong_screen.dart';
import 'package:tiny_tunes/playinstrument_screen.dart';
import 'package:tiny_tunes/settings_screen.dart';
import 'package:tiny_tunes/settings_manager.dart';
import 'package:tiny_tunes/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TinyTunesApp());
}

class TinyTunesApp extends StatefulWidget {
  const TinyTunesApp({super.key});

  @override
  State<TinyTunesApp> createState() => _TinyTunesAppState();
}

class _TinyTunesAppState extends State<TinyTunesApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await SettingsManager.getDarkMode();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiny Tunes',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Rounded', //  a rounded font for child-friendly appearance
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          accentColor: Colors.orange,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        fontFamily: 'Rounded',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          accentColor: Colors.orangeAccent,
        ),
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
            case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/play':
            return MaterialPageRoute(builder: (_) => PlayInstrumentScreen());
          case '/record':
            return MaterialPageRoute(builder: (_) => MakeSongScreen());
          case '/guess':
            return MaterialPageRoute(builder: (_) => GuessSoundScreen());
          case '/band':
            return MaterialPageRoute(builder: (_) => BandRoomScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => SettingsScreen());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Controller for background animation
  late AnimationController _backgroundController;
  
  // Controllers for bouncing animations
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _bounceAnimations;
  
  // Controller for title animation
  late AnimationController _titleController;
  late Animation<double> _titleScaleAnimation;
  
  // Audio effects
  final AudioPlayer _buttonSoundPlayer = AudioPlayer();
  
  // Colors for background gradient
  final List<Color> _backgroundColors = [
    Colors.blue.shade300,
    Colors.purple.shade300,
    Colors.pink.shade300,
    Colors.orange.shade300,
  ];
  
  // Current background color indices
  int _currentColorIndex = 0;
  int _nextColorIndex = 1;
  
  // Floating music notes positions
  final List<Offset> _notePositions = [];
  final List<double> _noteSizes = [];
  final List<double> _noteAngles = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    
    // Initialize title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _titleScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_titleController);
    
    _titleController.repeat();
    
    // Setup button animations (one for each button)
    _bounceControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: Duration(milliseconds: 150 + (index * 50)),
        vsync: this,
      ),
    );
    
    _bounceAnimations = _bounceControllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 50,
        ),
      ]).animate(controller);
    }).toList();
    
    // Generate random floating notes
    final random = math.Random();
    for (int i = 0; i < 10; i++) {
      _notePositions.add(Offset(
        random.nextDouble() * 300,
        random.nextDouble() * 600,
      ));
      _noteSizes.add(10 + random.nextDouble() * 20);
      _noteAngles.add(random.nextDouble() * math.pi * 2);
    }
    
    // Background color transition timer
    Future.delayed(const Duration(seconds: 5), () {
      _changeBackgroundColors();
    });
    
    // Preload sound effect
    _buttonSoundPlayer.setSource(AssetSource('sounds/pop.mp3'));
  }
  
  void _changeBackgroundColors() {
    setState(() {
      _currentColorIndex = _nextColorIndex;
      _nextColorIndex = (_nextColorIndex + 1) % _backgroundColors.length;
    });
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _changeBackgroundColors();
      }
    });
  }
  
  Future<void> _playButtonSound() async {
    await _buttonSoundPlayer.stop();
    await _buttonSoundPlayer.play(AssetSource('sounds/pop.mp3'));
  }
  
  void _animateButton(int index) {
    _bounceControllers[index].reset();
    _bounceControllers[index].forward();
    _playButtonSound();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _titleController.dispose();
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    _buttonSoundPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    _backgroundColors[_currentColorIndex],
                    _backgroundColors[_nextColorIndex],
                    _backgroundController.value,
                  )!,
                  Color.lerp(
                    _backgroundColors[(_currentColorIndex + 2) % _backgroundColors.length],
                    _backgroundColors[(_nextColorIndex + 2) % _backgroundColors.length],
                    _backgroundController.value,
                  )!,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Floating musical notes
            ..._buildFloatingNotes(),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // App title
                    AnimatedBuilder(
                      animation: _titleScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _titleScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Text(
                          '🎵 Tiny Tunes 🎵',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Menu buttons
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAnimatedButton(0, '🎹 Play Instrument', '/play', Colors.blue),
                            _buildAnimatedButton(1, '🎤 Make a Song', '/record', Colors.purple),
                            _buildAnimatedButton(2, '❓ Guess the Sound', '/guess', Colors.pink),
                            _buildAnimatedButton(3, '🐵 Band Room', '/band', Colors.orange),
                            _buildAnimatedButton(4, '⚙️ Settings', '/settings', Colors.teal),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildFloatingNotes() {
    final List<Widget> notes = [];
    final noteSymbols = ['♪', '♫', '🎵', '🎶'];
    final random = math.Random();
    
    for (int i = 0; i < _notePositions.length; i++) {
      notes.add(
        Positioned(
          left: _notePositions[i].dx,
          top: _notePositions[i].dy,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  math.sin((_backgroundController.value * math.pi * 2) + i) * 10,
                  math.cos((_backgroundController.value * math.pi * 2) + i) * 10,
                ),
                child: Transform.rotate(
                  angle: _noteAngles[i] + (_backgroundController.value * math.pi / 2),
                  child: Text(
                    noteSymbols[i % noteSymbols.length],
                    style: TextStyle(
                      fontSize: _noteSizes[i],
                      color: Colors.white.withOpacity(0.6),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    
    return notes;
  }

  Widget _buildAnimatedButton(int index, String label, String route, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: AnimatedBuilder(
        animation: _bounceAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimations[index].value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () {
            _animateButton(index);
            // Delay navigation slightly to see animation
            Future.delayed(const Duration(milliseconds: 150), () {
              Navigator.pushNamed(context, route);
            });
          },
          child: Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// AudioPlayerManager remains unchanged
class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  final AudioPlayer player = AudioPlayer();
  final Map<String, Source> _preloadedSounds = {};
  bool _initialized = false;

  factory AudioPlayerManager() {
    return _instance;
  }

  AudioPlayerManager._internal();

  // Initialize and preload sounds
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _preloadSounds();
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  Future<void> _preloadSounds() async {
    // Store the asset sources for quicker playback
    _preloadedSounds['sounds/drum.mp3'] = AssetSource('sounds/drum.mp3');
    _preloadedSounds['sounds/trumpet.mp3'] = AssetSource('sounds/trumpet.mp3');
    _preloadedSounds['sounds/piano.mp3'] = AssetSource('sounds/piano.mp3');
    _preloadedSounds['sounds/xylophone.mp3'] = AssetSource('sounds/xylophone.mp3');
  }

  Future<void> playSound(String soundPath) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Extract just the sound file path without 'assets/'
      final String normalizedPath = soundPath.replaceFirst('assets/', '');

      if (_preloadedSounds.containsKey(normalizedPath)) {
        await player.stop(); // Stop any currently playing sound
        await player.play(_preloadedSounds[normalizedPath]!);
      } else {
        debugPrint('Sound not preloaded: $normalizedPath');
        await player.stop();
        await player.play(AssetSource(normalizedPath));
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void dispose() {
    player.dispose();
  }

  void stopAllSounds() {}
}