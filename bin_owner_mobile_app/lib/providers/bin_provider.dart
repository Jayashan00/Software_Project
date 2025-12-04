import 'package:flutter/foundation.dart';

class BinProvider extends ChangeNotifier {
  String? _binId;

  String? get binId => _binId;

  void setBinId(String id) {
    _binId = id;
    notifyListeners(); // Notify UI or listeners if needed
  }

  void clearBinId() {
    _binId = null;
    notifyListeners();
  }
}
