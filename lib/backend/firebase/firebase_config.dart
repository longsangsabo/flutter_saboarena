import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyC8vLzrGQYgrCQyCW-H9yG6DMOCtZK2aWc",
            authDomain: "sabo-arena-udw348.firebaseapp.com",
            projectId: "sabo-arena-udw348",
            storageBucket: "sabo-arena-udw348.firebasestorage.app",
            messagingSenderId: "4294602803",
            appId: "1:4294602803:web:936d7621e4da8443127346"));
  } else {
    await Firebase.initializeApp();
  }
}
