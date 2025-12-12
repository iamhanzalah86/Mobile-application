import 'package:flutter/material.dart';
import 'package:mvvm_practice/model/auth_view_model.dart';
import 'package:mvvm_practice/utils/routes/routes_name.dart';
import 'package:mvvm_practice/utils/routes/routes.dart';
import 'package:provider/provider.dart'; // make sure this exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Fixed class name

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers:[
      ChangeNotifierProvider(create: (_) => AuthViewModel() )
    ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: RoutesName.login, // Fixed typo
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}
