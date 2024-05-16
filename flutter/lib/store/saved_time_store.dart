import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedTimeStore extends Cubit<double> {
  SavedTimeStore() : super(0) {
    _initTimeSaved();
  }

  Future<void> increment(double time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeSaved = state + time;
    prefs.setDouble('timeSaved', double.parse(timeSaved.toStringAsFixed(2)));
    emit(timeSaved);
  }

  Future<void> _initTimeSaved() async {
    final perfs = await SharedPreferences.getInstance();
    final timeSaved = perfs.getDouble('timeSaved') ?? 0;
    emit(timeSaved);
  }
}
