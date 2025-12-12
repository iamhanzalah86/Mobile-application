import 'package:flutter/material.dart';

import '../utils/utils.dart';
class Email extends StatefulWidget {
  const Email({super.key});

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
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