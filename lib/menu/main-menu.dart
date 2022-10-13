import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../network/network.dart';

class MainMenu extends StatelessWidget {
  final Network _network;

  const MainMenu(this._network, {super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Boardgames')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => context.go('/chooseGame?local=1'),
            child: const Text('Play Local'),
          ),
          ElevatedButton(
            onPressed: () => context.go(_network.isLoggedIn ? '/chooseGame' : '/login'),
            child: const Text('Play Online'),
          ),
          ElevatedButton(
            onPressed: () => context.go('/settings'),
            child: const Text('Settings'),
          ),
        ],
      ),
    ),
  );
}
