import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:tiny_tunes/main.dart'; 

class GuessSoundScreen extends StatefulWidget {
  const GuessSoundScreen({super.key});

  @override
  State<GuessSoundScreen> createState() => _GuessSoundScreenState();
}

class _GuessSoundScreenState extends State<GuessSoundScreen> {
  final List<Map<String, String>> _sounds = [
    {'name': 'Drum', 'path': 'sounds/drum.mp3'},
    {'name': 'Trumpet', 'path': 'sounds/trumpet.mp3'},
    {'name': 'Piano', 'path': 'sounds/piano.mp3'},
    {'name': 'Xylophone', 'path': 'sounds/xylophone.mp3'},
  ];

  late Map<String, String> _currentSound;
  late List<String> _options;
  String? _selectedOption;
  bool _answered = false;

  int _score = 0;
  int _round = 0;

  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    _loadNewSound();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _loadNewSound() {
    final random = Random();
    _currentSound = _sounds[random.nextInt(_sounds.length)];

    _options = _sounds.map((s) => s['name']!).toList()..shuffle();
    _selectedOption = null;
    _answered = false;
    _round++;

    AudioPlayerManager().playSound('assets/${_currentSound['path']}');
    setState(() {});
  }

  void _checkAnswer(String selected) {
    setState(() {
      _selectedOption = selected;
      _answered = true;
      if (selected == _currentSound['name']) {
        _score++;
        _confettiController.play();
      }
    });
  }

  void _replaySound() {
    AudioPlayerManager().playSound('assets/${_currentSound['path']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Guess the Sound')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Score: $_score / $_round',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Icon(Icons.volume_up, size: 60, color: Colors.blue),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _replaySound,
                  icon: Icon(Icons.replay),
                  label: Text("Replay Sound"),
                ),
                SizedBox(height: 20),
                Text('What instrument do you hear?',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                ..._options.map((option) {
                  bool isCorrect = option == _currentSound['name'];
                  bool isSelected = option == _selectedOption;
                  Color color = const Color.fromARGB(255, 120, 71, 234);

                  if (_answered) {
                    if (isSelected && isCorrect) {
                      color = Colors.green;
                    } else if (isSelected && !isCorrect) {
                      color = Colors.red;
                    } else if (isCorrect) {
                      color = Colors.green.shade200;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      onPressed: _answered ? null : () => _checkAnswer(option),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: color,
                      ),
                      child: Text(option, style: TextStyle(fontSize: 18)),
                    ),
                  );
                }),
                SizedBox(height: 30),
                if (_answered)
                  ElevatedButton.icon(
                    onPressed: _loadNewSound,
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Next Sound'),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.green, Colors.blue, Colors.yellow, Colors.pink],
            ),
          ),
        ],
      ),
    );
  }
}
