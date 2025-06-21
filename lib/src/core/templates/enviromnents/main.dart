String environment = '''import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:agile_front/infraestructure/env_enum.dart';
class Environment{
  static EnvEnum get env {
    const String currentEnvStr = String.fromEnvironment("env");
    EnvEnum currentEnv = envEnumSet(currentEnvStr);
    return currentEnv;
  }
  static String get backendApiUrl {
    const String mobile = String.fromEnvironment("mobileApiURL");
    const String web = String.fromEnvironment("webApiURL");
    const String desktop = String.fromEnvironment("desktopApiURL");
    if(kIsWeb){
      return web;
    }
    if (Platform.isAndroid || Platform.isIOS){
      return mobile;
    }
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows){
      return desktop;
    }
    return "Undefined Platform";
  }

  static String get backendApiUrlWS {
    const String mobile = String.fromEnvironment("mobileWsURL");
    const String web = String.fromEnvironment("webWsURL");
    const String desktop = String.fromEnvironment("desktopWsURL");
    if(kIsWeb){
      return web;
    }
    if (Platform.isAndroid || Platform.isIOS){
      return mobile;
    }
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows){
      return desktop;
    }
    return "Undefined Platform";
  }
}''';