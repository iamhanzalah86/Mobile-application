import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_practice/utils/utils.dart';
import 'package:mvvm_practice/model/auth_view_model.dart';
import 'package:provider/provider.dart';

import '../res/components/round_button.dart';

class Loginview extends StatefulWidget {
  const Loginview({Key? key}) : super(key: key);

  @override
  _LoginviewState createState() => _LoginviewState();
}

class _LoginviewState extends State<Loginview> {
  final ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void dispose(){
    _emailController.dispose();
    _passwordcontroller.dispose();

    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    _obsecurePassword.dispose();


  }
  @override
  Widget build(BuildContext context) {
    final authviewmodel = Provider.of<AuthViewModel>(context);
    final height = MediaQuery.of(context).size.height * 1;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                focusNode: emailFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                onFieldSubmitted: (value) {
                  Utils.fieldFocusChange(context, emailFocusNode, passwordFocusNode);
                },
              ),

              const SizedBox(height: 20),

              /// Password Field with ValueListenableBuilder
              ValueListenableBuilder(
                valueListenable: _obsecurePassword,
                builder: (context, value, child) {
                  return TextFormField(
                    controller: _passwordcontroller,
                    obscureText: value,
                    obscuringCharacter: "*",
                    focusNode: passwordFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_open_outlined),
                      suffixIcon: InkWell(
                        onTap: () {
                          _obsecurePassword.value = !_obsecurePassword.value;
                        },
                        child: Icon(
                          value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: height * .1),
              RoundButton(title: 'Login', loading: authviewmodel.loading,
                onPress: () {
                if(_emailController.text.isEmpty){
                  print('please enter email');
                }
                else if(_passwordcontroller.text.isEmpty){
                  print('please enter password');
                }else if(_passwordcontroller.text.length > 6){
                  print('please enter passwrd more than 6 letters');
                }else{
                  Map data = {
                    'email' : _emailController.text.toString(),
                    'password' : _passwordcontroller.text.toString(),
                  };
                  authviewmodel.loginApi(data, context);
                  print('API HIT');
                }
              },),
            ],
          ),
        ),
      ),
    );
  }
}
