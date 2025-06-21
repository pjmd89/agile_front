String loadingNotifier= r'''import 'package:flutter/material.dart';
class LoadingNotifier extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;
  
  Future <void> setLoading(bool loading, {bool notify = true}) async{
    _loading = loading;
    if(notify) notifyListeners();
  }
}''';