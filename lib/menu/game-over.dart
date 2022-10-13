import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameOver extends StatelessWidget {
  const GameOver({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Boardgames - Game Over!')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Back to main menu'),
          ),
        ],
      ),
    ),
  );
}
