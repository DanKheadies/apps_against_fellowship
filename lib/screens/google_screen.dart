// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:async';
// import 'dart:convert' show json;

import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;

/// The scopes required by this application.
// #docregion Initialize
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: 'your-client_id.apps.googleusercontent.com',
  scopes: scopes,
);
// #enddocregion Initialize

class GoogleScreen extends StatefulWidget {
  const GoogleScreen({super.key});

  @override
  State<GoogleScreen> createState() => _GoogleScreenState();
}

class _GoogleScreenState extends State<GoogleScreen> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  // final String _contactText = '';

  @override 
  void dispose() {
    
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('google init');

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      print('google sign in listening..');
      // #docregion CanAccessScopes
      // In mobile, being authenticated means being authorized...
      bool isAuthorized = account != null;
      print('isAuthorized: $isAuthorized');
      print(account);
      // However, on web...
      if (kIsWeb && account != null) {
        print('for web..');
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
        print('isAuthorized: $isAuthorized');
      }
      // #enddocregion CanAccessScopes

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });

      // // Now that we know that the user can access the required scopes, the app
      // // can call the REST API.
      // if (isAuthorized) {
      //   unawaited(_handleGetContact(account!));
      // }
    });

    // In the web, _googleSignIn.signInSilently() triggers the One Tap UX.
    //
    // It is recommended by Google Identity Services to render both the One Tap UX
    // and the Google Sign In button together to "reduce friction and improve
    // sign-in rates" ([docs](https://developers.google.com/identity/gsi/web/guides/display-button#html)).
    _googleSignIn.signInSilently();
  }

  // // Calls the People API REST endpoint for the signed-in user to retrieve information.
  // Future<void> _handleGetContact(GoogleSignInAccount user) async {
  //   setState(() {
  //     _contactText = 'Loading contact info...';
  //   });
  //   final http.Response response = await http.get(
  //     Uri.parse('https://people.googleapis.com/v1/people/me/connections'
  //         '?requestMask.includeField=person.names'),
  //     headers: await user.authHeaders,
  //   );
  //   if (response.statusCode != 200) {
  //     setState(() {
  //       _contactText = 'People API gave a ${response.statusCode} '
  //           'response. Check logs for details.';
  //     });
  //     print('People API ${response.statusCode} response: ${response.body}');
  //     return;
  //   }
  //   final Map<String, dynamic> data =
  //       json.decode(response.body) as Map<String, dynamic>;
  //   final String? namedContact = _pickFirstNamedContact(data);
  //   setState(() {
  //     if (namedContact != null) {
  //       _contactText = 'I see you know $namedContact!';
  //     } else {
  //       _contactText = 'No contacts to display.';
  //     }
  //   });
  // }

  // String? _pickFirstNamedContact(Map<String, dynamic> data) {
  //   final List<dynamic>? connections = data['connections'] as List<dynamic>?;
  //   final Map<String, dynamic>? contact = connections?.firstWhere(
  //     (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
  //     orElse: () => null,
  //   ) as Map<String, dynamic>?;
  //   if (contact != null) {
  //     final List<dynamic> names = contact['names'] as List<dynamic>;
  //     final Map<String, dynamic>? name = names.firstWhere(
  //       (dynamic name) =>
  //           (name as Map<Object?, dynamic>)['displayName'] != null,
  //       orElse: () => null,
  //     ) as Map<String, dynamic>?;
  //     if (name != null) {
  //       return name['displayName'] as String?;
  //     }
  //   }
  //   return null;
  // }

  // This is the on-click handler for the Sign In button that is rendered by Flutter.
  //
  // On the web, the on-click handler of the Sign In button is owned by the JS
  // SDK, so this method can be considered mobile only.
  // #docregion SignIn
  Future<void> _handleSignIn() async {
    print('signing in..');
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }
  // #enddocregion SignIn

  // Prompts the user to authorize `scopes`.
  //
  // This action is **required** in platforms that don't perform Authentication
  // and Authorization at the same time (like the web).
  //
  // On the web, this must be called from an user interaction (button click).
  // #docregion RequestScopes
  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    // #enddocregion RequestScopes
    setState(() {
      _isAuthorized = isAuthorized;
    });
    // #docregion RequestScopes
    // if (isAuthorized) {
    //   unawaited(_handleGetContact(_currentUser!));
    // }
    // #enddocregion RequestScopes
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      print(user);
      // The user is Authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(
              user.displayName ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            subtitle: Text(
              user.email,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          Text(
            'Signed in successfully.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          // if (_isAuthorized) ...<Widget>[
          //   // The user has Authorized all required scopes
          //   Text(
          //     _contactText,
          //     style: TextStyle(
          //       color: Theme.of(context).colorScheme.surface,
          //     ),
          //   ),
          //   ElevatedButton(
          //     child: Text(
          //       'REFRESH',
          //       style: TextStyle(
          //         color: Theme.of(context).colorScheme.surface,
          //       ),
          //     ),
          //     onPressed: () => _handleGetContact(user),
          //   ),
          // ],
          if (!_isAuthorized) ...<Widget>[
            // The user has NOT Authorized all required scopes.
            // (Mobile users may never see this button!)
            Text(
              'Additional permissions needed to read your contacts.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            ElevatedButton(
              onPressed: _handleAuthorizeScopes,
              child: Text(
                'REQUEST PERMISSIONS',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ],
          ElevatedButton(
            onPressed: _handleSignOut,
            child: Text(
              'SIGN OUT',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ],
      );
    } else {
      // The user is NOT Authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            'You are not currently signed in.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          // This method is used to separate mobile from web code with conditional exports.
          // See: src/sign_in_button.dart
          buildSignInButton(
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Google Sign In',
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => context.goNamed('welcome'),
        ),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }
}
