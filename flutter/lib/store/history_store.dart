import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryStore extends Cubit<List<Map<String, dynamic>>> {
  HistoryStore() : super([]) {
    _initHistory();
  }

  Future<void> add(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final history = state;
    final newHistory = [...history, jsonDecode(text)];
    prefs.setStringList(
        'history', newHistory.map((e) => jsonEncode(e)).toList());
    emit(newHistory.cast<Map<String, dynamic>>());
  }

  Future<void> update(String id,String key,String data) async {
    final prefs = await SharedPreferences.getInstance();
    final history = state;
    final newHistory = history.map((e) {
      if (e['id'] == id) {
        e[key] = data;
      }
      return e;
    }).toList();
    prefs.setStringList(
        'history', newHistory.map((e) => jsonEncode(e)).toList());
    emit(newHistory.cast<Map<String, dynamic>>());
  }

  Future<void> _initHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawHistory = prefs.getStringList('history') ?? [];
    final history = rawHistory.map((e) => jsonDecode(e)).toList();
    emit(history.cast<Map<String, dynamic>>());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('history');
    emit([]);
  }
}
