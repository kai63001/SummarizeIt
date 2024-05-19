// ignore_for_file: file_names

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceIdStore extends Cubit<String> {
  DeviceIdStore() : super('') {
    initDeviceId();
  }

  Future<void> setDeviceId(String deviceId) async {
    emit(deviceId);
  }

  Future<void> initDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'none';
    }
    emit(deviceId);
  }
}
