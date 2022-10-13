import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:go_router/go_router.dart';

import '../network/network.dart';

class LogIn extends StatelessWidget {
  final Network _network;

  const LogIn(this._network, {super.key});

  Future<String?> _authUser(final LoginData data) => _network.emailLogIn(data.name, data.password);

  Future<String?> _signupUser(final SignupData data) {
    if(data.name == null || data.password == null) {
      return Future(() => 'Email or password not provided.');
    }
    return _network.emailSignUp(data.name!, data.password!);
  }

  Future<String> _recoverPassword(final String name) async => 'Not yet implemented';

  @override
  Widget build(final BuildContext context) => FlutterLogin(
      title: 'Boardgames',
      logo: const AssetImage('assets/icon.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        context.go('/chooseGame'); // TODO: Can we avoid hard coding here and just go back from where we came from?
      },
      onRecoverPassword: _recoverPassword,
    );
}
