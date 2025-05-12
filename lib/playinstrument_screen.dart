import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiny_tunes/main.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PlayInstrumentScreen extends StatefulWidget {
  const PlayInstrumentScreen({super.key});

  @override
  _PlayInstrumentScreenState createState() => _PlayInstrumentScreenState();
}

class _PlayInstrumentScreenState extends State<PlayInstrumentScreen> with TickerProviderStateMixin {
  final AudioPlayerManager _audioManager = AudioPlayerManager();
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;
  
  @override
  void initState() {
    super.initState();
    _audioManager.initialize();
    _initTts();
    
    // Setup background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundAnimationController);
    
    // Speak screen content when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakScreenContent();
    });
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Slower rate for kids
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _speakScreenContent() async {
    await _flutterTts.speak("Do you want to play an instrument? Tap on an instrument to hear its sound.");
  }

  @override
  void dispose() {
    // Stop all audio when navigating away
    _audioManager.stopAllSounds();
    _flutterTts.stop();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Instrument'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _speakScreenContent,
            tooltip: 'Read screen aloud',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  HSVColor.fromAHSV(1, _backgroundAnimation.value * 360, 0.2, 1).toColor(),
                  HSVColor.fromAHSV(1, (_backgroundAnimation.value * 360 + 60) % 360, 0.2, 1).toColor(),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2, // Modified to prevent overflow
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      InstrumentButton(
                        label: '🥁 Drum',
                        sound: 'sounds/drum.mp3',
                        color: Colors.redAccent,
                        onTap: () => _speakInstrumentName('Drum'),
                        audioManager: _audioManager,
                      ),
                      InstrumentButton(
                        label: '🎺 Trumpet',
                        sound: 'sounds/trumpet.mp3',
                        color: Colors.amberAccent,
                        onTap: () => _speakInstrumentName('Trumpet'),
                        audioManager: _audioManager,
                      ),
                      InstrumentButton(
                        label: '🎹 Piano',
                        sound: 'sounds/piano.mp3',
                        color: Colors.blueAccent,
                        onTap: () => _speakInstrumentName('Piano'),
                        audioManager: _audioManager,
                      ),
                      InstrumentButton(
                        label: '🪇 Xylophone',
                        sound: 'sounds/xylophone.mp3',
                        color: Colors.greenAccent,
                        onTap: () => _speakInstrumentName('Xylophone'),
                        audioManager: _audioManager,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _speakInstrumentName(String name) {
    _flutterTts.speak("Playing $name");
  }
}

class InstrumentButton extends StatefulWidget {
  final String label;
  final String sound;
  final Color color;
  final VoidCallback? onTap;
  final AudioPlayerManager audioManager;

  const InstrumentButton({
    super.key,
    required this.label,
    required this.sound,
    this.color = Colors.indigo,
    this.onTap,
    required this.audioManager,
  });

  @override
  _InstrumentButtonState createState() => _InstrumentButtonState();
}

class _InstrumentButtonState extends State<InstrumentButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _bounceAnimation;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );
    
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playSound() async {
    if (_isPlaying) return;
    
    // Execute onTap callback if provided
    widget.onTap?.call();
    
    setState(() {
      _isPlaying = true;
    });
    
    _animationController.forward();
    HapticFeedback.mediumImpact(); // Add haptic feedback

    try {
      await widget.audioManager.playSound(widget.sound);
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _animationController.reverse();
    
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value * _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _playSound,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12), // Reduced padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                  children: [
                    Text(
                      widget.label.split(' ')[0], // Just the emoji
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 4), // Reduced spacing
                    Text(
                      widget.label.split(' ')[1], // Just the instrument name
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis, // Prevents text overflow
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Sound Note class to represent a note in a song sequence
class SoundNote {
  final String soundPath;
  final String instrumentName;
  final String emoji;
  final Color color;

  SoundNote({
    required this.soundPath,
    required this.instrumentName,
    required this.emoji,
    required this.color,
  });
}