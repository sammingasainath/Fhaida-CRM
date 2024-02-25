import 'package:crmapp/signup.dart';
import 'package:flutter/material.dart';
import 'splash_widget.dart';
import 'home_widget.dart'; // Replace with the correct import path for your HomeWidget
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Don't forget to add the firebase_auth package to your pubspec.yaml

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseAuth.instance.signOut();
  runApp(
    MaterialApp(
        title: 'AmyR- Automate my Retail',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HomePage();
            }
            return SignUpWidget();
          },
        )),
  );
}
