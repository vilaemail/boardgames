import 'dart:async';

import 'package:flutter_nakama/nakama.dart';
import 'package:flutter_nakama/rtapi.dart';

import '../util/environment.dart';
import '../util/logging.dart';

abstract class MatchCallbacks {
  void onData(final MatchData data);
  void onReady();
  void onFinished();
  abstract String matchId;
}

final String hostname = Environment.instance.loopbackAddress;

// TODO: Error handling - How does nakama library report errors? What about other errors that can happen in methods this class implements? Test edge cases and report errors to user properly
// TODO: Abstractions/encapsulation - Revisit [MatchCallbacks] and [Network] abstractions to improve code health
// TODO: Remove any hacks/fix linter errors
// ignore_for_file: cancel_subscriptions
// ignore_for_file: use_late_for_private_fields_and_variables
// ignore_for_file: avoid_catches_without_on_clauses
// ignore_for_file: use_if_null_to_convert_nulls_to_bools
class Network {
  Session? _session;
  late final NakamaBaseClient _client;
  StreamSubscription<MatchPresenceEvent>? _matchPresenceListener;
  StreamSubscription<MatchData>? _matchDataListener;
  final Map<String, MatchCallbacks> _callbacks = {};
  final Map<String, bool> _callbacksCalledReady = {};
  bool get isLoggedIn => _session != null;
  Future<NakamaWebsocketClient> get _wsClient async {
    await _ensureValidSession();
    return NakamaWebsocketClient.init(
      host: hostname,
      ssl: false,
      token: _session!.token,
    );
  }

  Network() {
    _client = getNakamaClient(
      host: hostname,
      ssl: false,
      serverKey: 'devbox', // TODO: Investigate what is this and what is the value we should set in prod
      grpcPort: 7349, // optional
      httpPort: 7350, // optional
    );
  }

  /// Returns null if successful, String with user error message if not
  Future<String?> emailLogIn(final String email, final String password) async {
    if(_session != null) {
      throw Exception('Session already exists');
    }
    try {
      await _onLogin(await _client.authenticateEmail(email: email, password: password));
      return null;
    } catch(e) {
      Log.info(e.toString);
      // TODO: Investigate which errors we can actually get and display correct error message to the user
      return 'Account does not exist or wrong password. Try again or sign up.';
    }
  }

  /// Returns null if successful, String with user error message if not
  Future<String?> emailSignUp(final String email, final String password) async {
    if(_session != null) {
      throw Exception('Session already exists');
    }
    try {
      await _onLogin(await _client.authenticateEmail(email: email, password: password, create: true));
      return null;
    } catch(e) {
      Log.info(e.toString);
      // TODO: Investigate which errors we can actually get and display correct error message to the user
      return 'Account already exists. Try a different email';
    }
  }

  // TODO: Add "game lobby" functionality what to do when more than 2 players are there - actual "game lobby" functionality
  Future<String> createMatch(final MatchCallbacks callbacks) async {
    final match = await (await _wsClient).createMatch();
    _callbacks[match.matchId] = callbacks;
    Log.debug(() => 'created match ${match.matchId}');
    callbacks.matchId = match.matchId;
    return match.matchId;
  }

  // TODO: Ensure everyone in the match is playing the same game
  Future<void> joinMatch(final String id, final MatchCallbacks callbacks) async {
    _callbacks[id] = callbacks;
    await (await _wsClient).joinMatch(id);
    if(_callbacksCalledReady[id] != true) {
      _callbacksCalledReady[id] = true;
      Log.debug(() => 'calling ready on joinmatch call');
      callbacks.onReady();
    } else {
      Log.debug(() => 'ready already called when we wanted to call in joinmatch');
    }
  }

  Future<void> leaveMatch(final String id) async {
    _callbacks.remove(id);
    await (await _wsClient).leaveMatch(id);
  }

  Future<void> sendData(final String id, final List<int> data) async {
    if(_callbacks[id] == null) {
      throw Exception("Can't send data to match which is not active $id. Active matches ${_callbacks.keys.toList()}");
    }
    await (await _wsClient).sendMatchData(matchId: id, opCode: Int64(0), data: data);
  }

  Future<void> close() async {
    if(_session == null) {
      return;
    }
    await _logOut();
  }

  // TODO: Better way of limiting number of users in the match ("match lobby")
  Future<void> _onLogin(final Session session) async {
    if(_session != null) {
      throw Exception('Session already exists');
    }
    _session = session;
    await _wsClient;
    _matchPresenceListener = (await _wsClient).onMatchPresence.listen((final event) {
      final callbacks = _callbacks[event.matchId];
      if(callbacks == null) {
        Log.debug(() => 'got no callbacks for ${event.matchId}');
        return;
      }
      if(event.joins.length == 1) {
        if(event.joins.first.userId == _session!.userId) {
          Log.debug(() => 'we joined to our match');
          return;
        }
        Log.debug(() => 'got join for ${event.matchId} and userid ${_session!.userId}');
        if(_callbacksCalledReady[event.matchId] == true) {
          Log.debug(() => 'we already called ready! skipping.');
          return;
        }
        Log.debug(() => 'calling ready on matchpresence event');
        callbacks.onReady();
        _callbacksCalledReady[event.matchId] = true;
        return;
      } 
      if(event.joins.isNotEmpty) {
        throw Exception('got more than 1 join for ${event.matchId}');
      }
      if(event.leaves.isNotEmpty) {
        Log.debug(() => 'got ${event.leaves.length} leaves for ${event.matchId}');
        callbacks.onFinished();
      }
    });
    _matchDataListener = (await _wsClient).onMatchData.listen((final event) {
      final callbacks = _callbacks[event.matchId];
      if(callbacks == null) {
        Log.debug(() => 'got no callbacks for ${event.matchId}');
        return;
      }
      callbacks.onData(event);
    });
  }

  Future<void> _logOut() async {
    // TODO: Make these safe (right now they can call on non-initialized fields/instances)
    await _matchPresenceListener!.cancel();
    await _matchDataListener!.cancel();
    await (await _wsClient).close();
    _session = null;
  }

  Future<void> _ensureValidSession() async {
    final session = _session;
    if(session == null) {
      throw Exception('not logged in');
    }
    final currentTimePlusFiveMinutes = DateTime.now().toUtc().add(const Duration(minutes: 5)).millisecondsSinceEpoch / 1000;
    Log.debug(() => 'session expires at ${session.expiresAt}. current+5min $currentTimePlusFiveMinutes. remaining ${session.expiresAt - currentTimePlusFiveMinutes}');
    if(session.expiresAt < currentTimePlusFiveMinutes) {
      try {
        _session = await _client.sessionRefresh(session: session);
        Log.debug(() => 'refresh success');
      } catch(e) {
        Log.info(e.toString);
        await _logOut();
        throw Exception('Can not refresh session, need to log in again, but not implemented yet.');
      }
    }
  }
}
