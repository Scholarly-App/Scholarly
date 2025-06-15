import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class ReelsManager {
  final String baseUrl = '${AppConfig.baseUrl}:5002/generate_reels';

  Future<bool> generateReel({
    required String? id,
    required String path,
    required String script,
    required String character,
    required String font,
    required String textColor,
    required String backgroundColor,
    required String type,
  }) async {
    final Uri url = Uri.parse(baseUrl);

    final Map<String, dynamic> data = {
      'id': id,
      'path': path,
      'script': script,
      'character': character,
      'font': font,
      'text_color': textColor,
      'background_color': backgroundColor,
      'type': type,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Reel Generation Started, You will be notified after completion",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return true;
      } else {
        print('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }

    Fluttertoast.showToast(
      msg: "Unable to start Reels Generation",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
    return false;
  }

  Future<List<String>> getReelsUrls(String path) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}:5003/videos'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "path": path,
        "url": AppConfig.baseUrl,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> links = List<String>.from(data['videos']);
      Fluttertoast.showToast(
          msg: links.isNotEmpty ? "Videos loaded" : "No videos found");
      return links;
    } else {
      throw Exception("Failed to load videos");
    }
  }

  static Future<void> submitFeedback(String feedback) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final feedbackRef = FirebaseDatabase.instance.ref('feedback/$userId').push();

    await feedbackRef.set({
      'feedback': feedback,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
