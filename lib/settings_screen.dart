import 'package:flutter/material.dart';
import 'package:tiny_tunes/settings_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  double volume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    isDarkMode = await SettingsManager.getDarkMode();
    volume = await SettingsManager.getVolume();
    setState(() {});
  }

  Future<void> _toggleDarkMode(bool value) async {
    await SettingsManager.setDarkMode(value);
    setState(() => isDarkMode = value);
  }

  Future<void> _changeVolume(double value) async {
    await SettingsManager.setVolume(value);
    setState(() => volume = value);
  }

  Future<void> _resetSettings() async {
    await SettingsManager.resetAll();
    await _loadSettings();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Settings reset to default")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('⚙️ Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 100), // Replace with your mascot/logo
                SizedBox(height: 10),
                Text("Tiny Tunes Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(height: 30),

          SwitchListTile(
            title: Text("🌗 Dark Mode"),
            subtitle: Text(isDarkMode ? "Enabled" : "Disabled"),
            value: isDarkMode,
            onChanged: _toggleDarkMode,
          ),

          ListTile(
            title: Text("🔊 Volume: ${(volume * 100).round()}%"),
            subtitle: Slider(
              value: volume,
              onChanged: _changeVolume,
              min: 0,
              max: 1,
              divisions: 10,
              label: "${(volume * 100).round()}%",
            ),
          ),

          ListTile(
            leading: Icon(Icons.restore),
            title: Text("Reset All Settings"),
            onTap: _resetSettings,
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About Tiny Tunes"),
            subtitle: Text("Version 1.0.0\nCreated with ❤️ by Phoebe"),
          ),
        ],
      ),
    );
  }
}
