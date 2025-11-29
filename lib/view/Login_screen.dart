import "package:flutter/material.dart";
import "package:mvvm_practice/utils/routes/routes_name.dart";
import "package:mvvm_practice/utils/utils.dart";
import "package:mvvm_practice/view/home_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: InkWell(
          onTap: (){
          //  Navigator.pushNamed(context, RoutesName.home);
            Utils.toastMessage("rand");
          },
        child: Text("Click"),
        )),
    );
  }
}
