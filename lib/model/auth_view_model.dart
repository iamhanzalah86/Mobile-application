import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_practice/repository/api_service.dart';
import 'package:mvvm_practice/utils/routes/routes_name.dart';
import 'package:mvvm_practice/utils/utils.dart';

class AuthViewModel with ChangeNotifier {
  final _myrepo = AuthRepository();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future<void> loginApi(dynamic data, BuildContext context) async {
    setLoading(true);
    _myrepo.loginApi(data).then((value) {
      Utils.flushBarErrorMessage("login succesfully", context);
      Navigator.pushNamed(context, RoutesName.home);
      if (kDebugMode) {
        setLoading(false);
        print(value.toString());
      }
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        setLoading(false);
        print(error.toString()); // print error, not value
      }
    });
  }
}
