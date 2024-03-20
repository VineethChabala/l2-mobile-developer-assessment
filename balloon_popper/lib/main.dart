import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(BalloonPopGame());
}

class BalloonPopGame extends StatelessWidget {
  const BalloonPopGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balloon Pop Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int balloonsPopped = 0;
  int balloonsMissed = 0;
  Timer? timer;
  Duration duration = const Duration(minutes: 2);
  List<Widget> balloons = [];

  @override
  void initState() {
    super.initState();
    startGame();
    startTimer();
  }

  void startGame() {
    // Generate balloons periodically
    Timer.periodic(Duration(seconds: 1), (timer) {
      generateBalloons();
    });
  }

  void generateBalloons() async {
    // Generate balloons with a delay between each one
    await Future.delayed(const Duration(seconds: 1)); // Add a delay
    setState(() {
      balloons.add(
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          curve: Curves.linear,
          bottom: 0, // Start from the bottom
          left: Random().nextDouble() * MediaQuery.of(context).size.width -
              10, // Random horizontal position
          child: Balloon(
            onPop: () {
              popBalloon(true);
            },
            onMiss: () {
              popBalloon(false);
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (duration.inSeconds == 0) {
          endGame();
        } else {
          duration -= const Duration(seconds: 1);
        }
      });
    });
  }

  void endGame() {
    timer?.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(
              'Balloons Popped: $balloonsPopped\nBalloons Missed: $balloonsMissed'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      balloonsPopped = 0;
      balloonsMissed = 0;
      duration = const Duration(minutes: 2);
      balloons.clear(); // Clear the balloons list
    });
    startTimer();
  }

  void popBalloon(bool popped) {
    setState(() {
      if (popped) {
        balloonsPopped++;
      } else {
        balloonsMissed++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balloon Pop Game'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 32.0),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                popBalloon(true);
              },
              child: Stack(
                children: balloons, // Add generated balloons to the stack
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Balloons Popped: $balloonsPopped',
                  style: const TextStyle(fontSize: 18.0),
                ),
                Text(
                  'Balloons Missed: $balloonsMissed',
                  style: const TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Balloon extends StatefulWidget {
  final VoidCallback onPop;
  final VoidCallback onMiss;

  Balloon({required this.onPop, required this.onMiss});

  @override
  _BalloonState createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool popped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -1.0), // Move upward
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (popped) {
      _controller.forward(); // Start the animation
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: _offsetAnimation.value * MediaQuery.of(context).size.height,
          child: GestureDetector(
            onTap: () {
              setState(() {
                popped = true;
              });
              if (popped) {
                widget.onPop();
              } else {
                widget.onMiss();
              }
            },
            child: popped
                ? null
                : Image.asset(
                    'assets/balloon.png',
                    height: 100,
                    width: 60,
                    fit: BoxFit.contain,
                  ), // Hide the balloon if popped
          ),
        );
      },
    );
  }
}
