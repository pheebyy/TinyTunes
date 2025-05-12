import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BandRoomScreen extends StatefulWidget {
  const BandRoomScreen({super.key});

  @override
  State<BandRoomScreen> createState() => _BandRoomScreenState();
}

class _BandRoomScreenState extends State<BandRoomScreen> {
  final Map<String, String> instruments = {
    'Drum': 'sounds/drum.mp3',
    'Trumpet': 'sounds/trumpet.mp3',
    'Piano': 'sounds/piano.mp3',
    'Xylophone': 'sounds/xylophone.mp3',
  };

  final Map<String, String> instrumentImages = {
    'Drum': 'assets/images/drum.jpg',
    'Trumpet': 'assets/images/trumpet.jpg',
    'Piano': 'assets/images/piano.jpg',
    'Xylophone': 'assets/images/xylophone.jpg',
  };

  final Map<String, bool> isLooping = {};
  final Map<String, Timer?> loopTimers = {};
  // Create a separate player for each instrument to enable simultaneous playback
  final Map<String, AudioPlayer> _instrumentPlayers = {};
  final List<AudioPlayer> _tempPlayers = []; // For one-time plays

  @override
  void initState() {
    super.initState();
    // Initialize a dedicated player for each instrument
    for (final name in instruments.keys) {
      isLooping[name] = false;
      loopTimers[name] = null;
      _instrumentPlayers[name] = AudioPlayer();
    }
  }

  @override
  void dispose() {
    _stopAllSounds();
    // Dispose all dedicated players
    for (final player in _instrumentPlayers.values) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> _playSound(String name) async {
    final path = instruments[name]!;
    
    // For one-off playing, use a temporary player
    final player = AudioPlayer();
    _tempPlayers.add(player);
    
    await player.play(AssetSource(path));
    
    player.onPlayerComplete.listen((_) {
      _tempPlayers.remove(player);
      player.dispose();
    });
  }

  void _toggleLoop(String name) {
    setState(() {
      if (isLooping[name] == true) {
        loopTimers[name]?.cancel();
        loopTimers[name] = null;
        isLooping[name] = false;
        
        // Stop the looping sound
        final dedicatedPlayer = _instrumentPlayers[name];
        dedicatedPlayer?.stop();
      } else {
        // Use the dedicated player for looping
        _loopSound(name);
        isLooping[name] = true;
        // Set a timer to restart the sound when it ends
        loopTimers[name] = Timer.periodic(const Duration(seconds: 3), (_) => _loopSound(name));
      }
    });
  }

  Future<void> _loopSound(String name) async {
    final path = instruments[name]!;
    final dedicatedPlayer = _instrumentPlayers[name]!;
    await dedicatedPlayer.play(AssetSource(path));
  }

  void _stopAllSounds() {
    // Cancel all loop timers
    for (final timer in loopTimers.values) {
      timer?.cancel();
    }
    
    // Stop all dedicated players
    for (final player in _instrumentPlayers.values) {
      player.stop();
    }
    
    // Stop and dispose all temporary players
    for (final player in _tempPlayers) {
      player.stop();
      player.dispose();
    }
    _tempPlayers.clear();
    
    // Reset loop states
    for (final name in instruments.keys) {
      isLooping[name] = false;
    }
    
    setState(() {});
  }

  Widget _buildInstrumentTile(String name) {
    final looping = isLooping[name] ?? false;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep column size to a minimum
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                instrumentImages[name]!,
                height: 80, // Reduced from 100
                width: 80,  // Reduced from 100
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6), // Reduced from 10
            Text(
              name, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold) // Reduced from 18
            ),
            const SizedBox(height: 6), // Reduced from 10
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _playSound(name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: const Icon(Icons.play_arrow),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _toggleLoop(name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: looping ? Colors.green : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: Icon(looping ? Icons.repeat_on : Icons.repeat),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎶 Band Room')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text("Mix your band!", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Adjusted to fit content
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: instruments.keys.map((name) => _buildInstrumentTile(name)).toList(),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _stopAllSounds,
              icon: const Icon(Icons.stop_circle),
              label: const Text("Stop All"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}