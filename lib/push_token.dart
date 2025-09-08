// lib/push_tokens.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> registerFcmTokenForUser(String uid) async {
  // Ask permission (Android 13+/iOS)
  await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) return;

  final tokensRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('tokens')
      .doc(token);

  await tokensRef.set({
    'token': token,
    'platform': Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web',
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  // Keep Firestore updated when the token changes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    FirebaseFirestore.instance
        .collection('users').doc(uid).collection('tokens').doc(newToken)
        .set({
          'token': newToken,
          'platform': Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  });
}