import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../authentication/domain/entities/access_token.dart';
import '../../../authentication/presentation/state/authentication_store.dart';

class Index extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.yellow.shade700,
        child: StateBuilder<AuthenticationStore>(
          models: [Injector.getAsReactive<AuthenticationStore>()],
          builder: (_, reactiveModel) {
            return reactiveModel.whenConnectionState(
              onIdle: () => buildLoading(),
              onWaiting: () => buildLoading(),
              onData: (store) => buildInitialScreen(context, store.accessToken),
              onError: (_) => buildLoginScreen(context),
            );
          },
          afterInitialBuild: (context, reactiveModel) {
            checkLoginStatus(context);
          },
        ),
      ),
    );
  }

  Widget buildLoginScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Container(
            child: Column(
              children: <Widget>[
                Text(
                  "MonkeyBiz",
                  style: Theme.of(context).textTheme.display1,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "A Mailchimp Application",
                  style: Theme.of(context).textTheme.display2,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          LoginButton(),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildInitialScreen(BuildContext context, AccessToken accessToken) {
    if (accessToken == null) {
      return buildLoginScreen(context);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            accessToken.token,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
          LogoutButton(),
        ],
      );
    }
  }

  void checkLoginStatus(BuildContext context) {
    final reactiveModel = Injector.getAsReactive<AuthenticationStore>();
    reactiveModel.setState(
      (store) => store.checkLoginStatus(),
      onError: (context, error) {
        print(error);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't sign in. Is the device online?"),
          ),
        );
      },
    );
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: FloatingActionButton.extended(
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text('Sign In'),
        ),
        onPressed: () => login(context),
        shape: RoundedRectangleBorder(),
      ),
    );
  }

  void login(BuildContext context) {
    final reactiveModel = Injector.getAsReactive<AuthenticationStore>();
    reactiveModel.setState(
      (store) => store.login(),
      onError: (context, error) {
        print(error);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't sign in. Is the device online?"),
          ),
        );
      },
    );
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: FloatingActionButton.extended(
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text('Sign Out'),
        ),
        onPressed: () => logout(context),
        shape: RoundedRectangleBorder(),
      ),
    );
  }

  void logout(BuildContext context) {
    final reactiveModel = Injector.getAsReactive<AuthenticationStore>();
    reactiveModel.setState(
      (store) => store.logout(),
      onError: (context, error) {
        print(error);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't sign out. Please try again."),
          ),
        );
      },
    );
  }
}
