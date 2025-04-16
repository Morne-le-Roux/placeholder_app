import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/widgets/buttons/large_rounded_button.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/usecases/validate_email.dart';
import 'package:placeholder/features/auth/usecases/validate_password.dart';
import 'package:placeholder/features/auth/views/choose_user.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:placeholder/core/usecases/snack.dart';

import '../../../core/constants/constants.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  AuthCubit get authCubit => context.read<AuthCubit>();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordFocusNode2 = FocusNode();

  String _email = "";
  String _password = "";
  String _password2 = "";

  bool _register = false;

  bool _isLoading = false;

  bool _isValid = false;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                Text(_register ? "Register" : "Login",
                    style: Constants.textStyles.title),
                Gap(20),
                TextFormField(
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    initialValue: _email,
                    validator: (value) {
                      String? error = validateEmail(value);
                      setState(() => _isValid = false);
                      if (error == null) setState(() => _isValid = true);
                      return error;
                    },
                    onChanged: (value) => setState(() => _email = value),
                    onEditingComplete: () => _passwordFocusNode.requestFocus(),
                    decoration: InputDecoration(label: Text("Email")),
                    focusNode: _emailFocusNode),
                TextFormField(
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    initialValue: _password,
                    obscureText: true,
                    validator: (value) {
                      String? error = validatePassword(value);
                      setState(() => _isValid = false);
                      if (error == null) setState(() => _isValid = true);
                      return error;
                    },
                    onChanged: (value) => setState(() => _password = value),
                    onEditingComplete: () => _register
                        ? _passwordFocusNode2.requestFocus()
                        : _passwordFocusNode.unfocus(),
                    decoration: InputDecoration(label: Text("Password")),
                    focusNode: _passwordFocusNode),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _register
                      ? TextFormField(
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          initialValue: _password2,
                          obscureText: true,
                          validator: (value) {
                            String? error = value!.isEmpty
                                ? "Password is required"
                                : _password != _password2
                                    ? "Passwords do not match"
                                    : null;
                            setState(() => _isValid = false);
                            if (error == null) setState(() => _isValid = true);
                            return error;
                          },
                          onChanged: (value) =>
                              setState(() => _password2 = value),
                          onEditingComplete: () =>
                              _passwordFocusNode2.unfocus(),
                          decoration:
                              InputDecoration(label: Text("Confirm Password")),
                          focusNode: _passwordFocusNode2)
                      : const SizedBox.shrink(),
                ),
                Gap(5),
                LargeRoundedButton(
                  text: _register ? "Register" : "Login",
                  isLoading: _isLoading,
                  isValid: _isValid,
                  onPressed: () async {
                    try {
                      setState(() => _isLoading = true);
                      if (_register) {
                        await authCubit.register(_email, _password);
                      } else {
                        await authCubit.login(_email, _password);
                      }
                      setState(() => _isLoading = false);
                      Nav.pushAndPop(context, ChooseUser());
                    } catch (e) {
                      snack(context, e.toString());
                      setState(() => _isLoading = false);
                    }
                  },
                ),
                GestureDetector(
                  onTap: () => setState(() => _register = !_register),
                  child: Text(
                      "${_register ? "Already a member?" : "Not a member?"} ${_register ? "Login instead." : "Register instead."}"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
