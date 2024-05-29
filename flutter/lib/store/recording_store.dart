import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingStore extends Cubit<List<Map<String, dynamic>>> {
  RecordingStore() : super([]) {
    _initRecordingList();
  }

  Future<void> add(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final history = state;
    final newHistory = [...history, jsonDecode(text)];
    prefs.setStringList(
        'recordingList', newHistory.map((e) => jsonEncode(e)).toList());
    emit(newHistory.cast<Map<String, dynamic>>());
  }

  Future<void> _initRecordingList() async {
    final prefs = await SharedPreferences.getInstance();
    final rawHistory = prefs.getStringList('recordingList') ?? [];
    final history = rawHistory.map((e) => jsonDecode(e)).toList();
    emit(history.cast<Map<String, dynamic>>());
  }

  Future<void> deleteRecording(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = state;
    final newHistory = history.where((element) => element['id'] != id).toList();
    prefs.setStringList(
        'recordingList', newHistory.map((e) => jsonEncode(e)).toList());
    emit(newHistory.cast<Map<String, dynamic>>());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('recordingList');
    emit([]);
  }
}
