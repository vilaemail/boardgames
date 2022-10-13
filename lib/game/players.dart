enum PlayerState {
  playing,
  won,
  lost,
  drew,
  // TODO: More states such as spectating, queuing, etc.
}

class Player {
  /// Unique id of the player in the game
  final String id;
  /// Unique id of the authenticated user that is playing
  final String userId;
  /// Display name of the user
  final String name;
  PlayerState state;

  Player(this.id, this.userId, this.name, this.state);
}

class Players {
  final List<Player> list;
  int _activePlayerIndex = 0;
  Player get active => list[_activePlayerIndex];
  Player get me => list[_myIndex];
  int get activeIndex => _activePlayerIndex;
  bool get canPlayForThisUser => _isLocal || _myIndex == _activePlayerIndex;
  final bool _isLocal;
  final int _myIndex;

  Players(this.list, final Player me, {required final bool isLocal}): _myIndex = list.indexOf(me), _isLocal = isLocal;
  void moveToNextPlayer() {
    _activePlayerIndex = (_activePlayerIndex + 1) % list.length;
  }
}
