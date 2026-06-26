import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashlight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC857)),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const FlashlightPage(),
    );
  }
}

class FlashlightPage extends StatefulWidget {
  const FlashlightPage({Key? key}) : super(key: key);

  @override
  State<FlashlightPage> createState() => _FlashlightPageState();
}

class _FlashlightPageState extends State<FlashlightPage> {
  bool _isFlashlightOn = false;
  bool _isSupported = true;
  int? _autoOffMinutes = 5;
  Timer? _autoOffTimer;

  @override
  void initState() {
    super.initState();
    _checkFlashlightSupport();
  }

  Future<void> _checkFlashlightSupport() async {
    try {
      final supported = await TorchLight.isTorchAvailable();
      setState(() {
        _isSupported = supported;
      });
    } catch (e) {
      setState(() {
        _isSupported = false;
      });
    }
  }

  void _scheduleAutoOffTimer() {
    _autoOffTimer?.cancel();

    if (!_isFlashlightOn || _autoOffMinutes == null) {
      return;
    }

    _autoOffTimer = Timer(Duration(minutes: _autoOffMinutes!), () async {
      if (!mounted || !_isFlashlightOn) {
        return;
      }

      try {
        await TorchLight.disableTorch();
      } catch (_) {
        // Ignore torch shutdown errors when the timer expires.
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isFlashlightOn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flashlight turned off automatically'),
        ),
      );
    });
  }

  Future<void> _turnOffFlashlight() async {
    _autoOffTimer?.cancel();

    if (!_isFlashlightOn) {
      return;
    }

    try {
      await TorchLight.disableTorch();
      if (!mounted) return;
      setState(() {
        _isFlashlightOn = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _toggleFlashlight() async {
    if (!_isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flashlight not supported on this device'),
        ),
      );
      return;
    }

    try {
      if (_isFlashlightOn) {
        await _turnOffFlashlight();
      } else {
        await TorchLight.enableTorch();
        if (!mounted) return;
        setState(() {
          _isFlashlightOn = true;
        });
        _scheduleAutoOffTimer();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _autoOffTimer?.cancel();
    TorchLight.disableTorch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor =
        _isFlashlightOn ? const Color(0xFFFFD166) : const Color(0xFF4B5563);
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: _isFlashlightOn
          ? const [Color(0xFF31260A), Color(0xFF101820), Color(0xFF05070A)]
          : const [Color(0xFF111827), Color(0xFF0B1120), Color(0xFF030712)],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flashlight',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quick torch control',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                    _StatusPill(
                      label: _isSupported ? 'READY' : 'NO TORCH',
                      color: _isSupported
                          ? const Color(0xFF34D399)
                          : const Color(0xFFF87171),
                    ),
                  ],
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowColor.withValues(alpha: 0.16),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(
                          alpha: _isFlashlightOn ? 0.45 : 0.12,
                        ),
                        blurRadius: _isFlashlightOn ? 70 : 28,
                        spreadRadius: _isFlashlightOn ? 18 : 4,
                      ),
                    ],
                    border: Border.all(
                      color: glowColor.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isFlashlightOn
                            ? const Color(0xFFFFF3B0)
                            : const Color(0xFF1F2937),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 24,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFlashlightOn
                            ? Icons.flashlight_on
                            : Icons.flashlight_off,
                        size: 92,
                        color: _isFlashlightOn
                            ? const Color(0xFFB45309)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  _isFlashlightOn ? 'LIGHT IS ON' : 'LIGHT IS OFF',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isFlashlightOn
                      ? 'Tap the button to switch it off.'
                      : 'Tap the button to brighten things up.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFD1D5DB),
                      ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827).withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF374151).withValues(alpha: 0.7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-off timer',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Flash on thakle selected time shesh hole app nijer theke light off kore dibe.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFCBD5E1),
                            ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int?>(
                        value: _autoOffMinutes,
                        dropdownColor: const Color(0xFF111827),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1F2937),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Off'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 1,
                            child: Text('1 minute'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 3,
                            child: Text('3 minutes'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 5,
                            child: Text('5 minutes'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 10,
                            child: Text('10 minutes'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 15,
                            child: Text('15 minutes'),
                          ),
                        ],
                        onChanged: (value) {
                          if (!mounted) return;
                          setState(() {
                            _autoOffMinutes = value;
                          });
                          if (_isFlashlightOn) {
                            _scheduleAutoOffTimer();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton.icon(
                    onPressed: _isSupported ? _toggleFlashlight : null,
                    icon: Icon(
                      _isFlashlightOn ? Icons.power_settings_new : Icons.bolt,
                    ),
                    label: Text(_isFlashlightOn ? 'Turn Off' : 'Turn On'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _isFlashlightOn
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFFFC857),
                      foregroundColor: _isFlashlightOn
                          ? Colors.white
                          : const Color(0xFF111827),
                      disabledBackgroundColor: const Color(0xFF374151),
                      disabledForegroundColor: const Color(0xFF9CA3AF),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                if (!_isSupported)
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Text(
                      'Flashlight is not available on this device.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: const Color(0xFFFCA5A5)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
          ),
        ],
      ),
    );
  }
}
