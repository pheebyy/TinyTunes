import 'package:flutter/material.dart';
import 'package:tiny_tunes/main.dart';
import 'package:tiny_tunes/playinstrument_screen.dart';



class MakeSongScreen extends StatefulWidget {
  const MakeSongScreen({super.key});

  @override
  _MakeSongScreenState createState() => _MakeSongScreenState();
}

class _MakeSongScreenState extends State<MakeSongScreen> {
  final AudioPlayerManager _audioManager = AudioPlayerManager();
  final List<SoundNote> _songSequence = [];
  bool _isPlaying = false;
  String _songName = "My Song";
  
  // Available instruments
  final List<SoundNote> _availableInstruments = [
    SoundNote(
      soundPath: 'sounds/drum.mp3',
      instrumentName: 'Drum',
      emoji: '🥁',
      color: Colors.redAccent,
    ),
    SoundNote(
      soundPath: 'sounds/trumpet.mp3',
      instrumentName: 'Trumpet',
      emoji: '🎺',
      color: Colors.amberAccent,
    ),
    SoundNote(
      soundPath: 'sounds/piano.mp3',
      instrumentName: 'Piano',
      emoji: '🎹',
      color: Colors.blueAccent,
    ),
    SoundNote(
      soundPath: 'sounds/xylophone.mp3',
      instrumentName: 'Xylophone',
      emoji: '🪇',
      color: Colors.greenAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioManager.initialize();
  }

  // Add a note to the song sequence
  void _addNoteToSong(SoundNote note) {
    setState(() {
      _songSequence.add(note);
    });
    
    // Play the sound when added
    _audioManager.playSound(note.soundPath);
  }

  // Remove a note from the song sequence
  void _removeNoteFromSong(int index) {
    setState(() {
      _songSequence.removeAt(index);
    });
  }

  // Clear the entire song sequence
  void _clearSong() {
    setState(() {
      _songSequence.clear();
    });
  }

  // Play the entire song sequence
  Future<void> _playSong() async {
    if (_songSequence.isEmpty || _isPlaying) return;
    
    setState(() {
      _isPlaying = true;
    });
    
    // Play each note in sequence with a delay
    for (var note in _songSequence) {
      await _audioManager.playSound(note.soundPath);
      await Future.delayed(Duration(milliseconds: 500)); // Delay between notes
    }
    
    setState(() {
      _isPlaying = false;
    });
  }

  // Update song name
  void _updateSongName() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = _songName;
        return AlertDialog(
          title: Text('Name Your Song'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter a name for your song',
            ),
            onChanged: (value) {
              newName = value;
            },
            controller: TextEditingController(text: _songName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _songName = newName;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Make a Song'),
            SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _updateSongName,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          _songName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.edit, size: 16, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _songSequence.isEmpty ? null : _clearSong,
            tooltip: 'Clear Song',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Song visualization area - Reduced flex
            Expanded(
              flex: 2, // Reduced from 3
              child: Container(
                padding: EdgeInsets.all(12), // Reduced padding
                child: _songSequence.isEmpty
                    ? Center(
                        child: Text(
                          'Add instruments below to create your song!',
                          style: TextStyle(
                            fontSize: 16, // Reduced font size
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            _songSequence.length,
                            (index) => SongNoteCard(
                              note: _songSequence[index],
                              onRemove: () => _removeNoteFromSong(index),
                              noteIndex: index,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            
            // Play button - Reduced padding
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8), // Reduced padding
              child: ElevatedButton.icon(
                onPressed: _songSequence.isEmpty || _isPlaying ? null : _playSong,
                icon: Icon(_isPlaying ? Icons.music_note : Icons.play_arrow),
                label: Text(_isPlaying ? 'Playing...' : 'Play Song'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Reduced padding
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            // Divider
            Divider(thickness: 1, height: 1),
            
            // Instrument selection area
            Expanded(
              flex: 2, // Keep this flex the same
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 8), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Instruments:',
                      style: TextStyle(
                        fontSize: 16, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8), // Reduced spacing
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.2, // Increased aspect ratio for shorter buttons
                          crossAxisSpacing: 12, // Reduced spacing
                          mainAxisSpacing: 12, // Reduced spacing
                        ),
                        itemCount: _availableInstruments.length,
                        itemBuilder: (context, index) {
                          final instrument = _availableInstruments[index];
                          return InstrumentSelectorButton(
                            note: instrument,
                            onTap: () => _addNoteToSong(instrument),
                          );
                        },
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
}

// Widget for instrument selection buttons
class InstrumentSelectorButton extends StatelessWidget {
  final SoundNote note;
  final VoidCallback onTap;
  
  const InstrumentSelectorButton({
    super.key,
    required this.note,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: note.color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: note.color.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              note.emoji,
              style: TextStyle(fontSize: 28), // Slightly reduced size
            ),
            SizedBox(width: 8),
            Text(
              note.instrumentName,
              style: TextStyle(
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for song note display
class SongNoteCard extends StatelessWidget {
  final SoundNote note;
  final VoidCallback onRemove;
  final int noteIndex;
  
  const SongNoteCard({
    super.key,
    required this.note,
    required this.onRemove,
    required this.noteIndex,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, // Reduced width
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Note index
          Text(
            (noteIndex + 1).toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontSize: 12, // Smaller font size
            ),
          ),
          
          // Note card
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: note.color.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: note.color,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          note.emoji,
                          style: TextStyle(fontSize: 24), // Reduced size
                        ),
                        SizedBox(height: 2), // Reduced spacing
                        Text(
                          note.instrumentName,
                          style: TextStyle(
                            fontSize: 10, // Smaller font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Remove button
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(3), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 12, // Smaller icon
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

