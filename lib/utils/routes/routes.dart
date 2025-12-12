import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_practice/utils/routes/routes_name.dart';
//import 'package:mvvm_practice/view/Authenticate.dart';
//import 'package:mvvm_practice/view/Email.dart';
import 'package:mvvm_practice/view/loginview.dart';
import 'package:mvvm_practice/view/home_screen.dart';
class Routes {
  static MaterialPageRoute generateRoute(RouteSettings settings){
    switch(settings.name){
      case RoutesName.home:
        return MaterialPageRoute(builder: (BuildContext context) => HomeScreen());
      case RoutesName.login:
        return MaterialPageRoute(builder: (BuildContext context) => Loginview());
      case RoutesName.Email:
        //return MaterialPageRoute(builder: (BuildContext context) => Email());
      case RoutesName.authenticate:
        //return MaterialPageRoute(builder: (BuildContext context) => Authenticate());

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