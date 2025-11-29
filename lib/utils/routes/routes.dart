import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_practice/utils/routes/routes_name.dart';
import 'package:mvvm_practice/view/Login_screen.dart';

import '../../view/home_screen.dart';

class Routes {
  static MaterialPageRoute generateRoute(RouteSettings settings){
    switch(settings.name){
      case RoutesName.home:
    return MaterialPageRoute(builder: (BuildContext context) => HomeScreen());
    case RoutesName.login:
    return MaterialPageRoute(builder: (BuildContext context) => LoginScreen());

    default:
        return MaterialPageRoute(builder: (_){
          return Scaffold(
            body: Center(
                child: Text('No Route Defined') ,),
          );
        });
    }
  }

}