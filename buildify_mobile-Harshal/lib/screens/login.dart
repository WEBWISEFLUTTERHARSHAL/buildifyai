import 'package:Buildify_AI/screens/home.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalButton.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  double? width;
  double? height;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> isVisible = ValueNotifier(false);
  ValueNotifier<bool> toRemember = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              gradient: const LinearGradient(
                colors: [headerGradient1, headerGradient2],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, -7),
                ),
              ]),
        ),
        toolbarHeight: 45,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
              margin: const EdgeInsets.fromLTRB(
                25,
                10,
                25,
                20,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 20,
              ),
              child: const Text(
                strings.loginHeader,
                style: TextStyle(
                  fontFamily: strings.fontPoppins,
                  color: white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              )),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.loginHello,
                      style: TextStyle(
                          fontSize: 20,
                          color: black,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      strings.loginWelcome,
                      style: TextStyle(
                          fontSize: 14,
                          color: black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return strings.loginEmailError;
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        fontFamily: strings.fontPoppins,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 15),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 1,
                            color: loginTextfieldBorder,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        hintText: strings.loginEmailHint,
                        hintStyle: const TextStyle(
                          fontFamily: strings.fontPoppins,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: lightGrey,
                        ),
                        prefixIcon: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: ImageIcon(
                            AssetImage(images.emailIcon),
                            size: 20,
                            color: lightGrey,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          maxWidth: 70,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ValueListenableBuilder(
                      valueListenable: isVisible,
                      builder: (context, isVisibleValue, child) {
                        return TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return strings.loginPassError;
                            }
                            return null;
                          },
                          obscureText: !isVisibleValue,
                          controller: passwordController,
                          style: const TextStyle(
                            fontFamily: strings.fontPoppins,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 1,
                                color: loginTextfieldBorder,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            hintText: strings.loginPasswordHint,
                            hintStyle: const TextStyle(
                              fontFamily: strings.fontPoppins,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: lightGrey,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: ImageIcon(
                                AssetImage(images.passwordIcon),
                                size: 20,
                                color: lightGrey,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              maxWidth: 70,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: IconButton(
                                onPressed: () {
                                  isVisible.value = !isVisible.value;
                                },
                                icon: Icon(
                                  isVisibleValue
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: lightGrey,
                                ),
                                splashRadius: 0.1,
                                visualDensity: VisualDensity(
                                  horizontal: -4,
                                  vertical: -4,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            strings.loginForgotPass,
                            style: TextStyle(
                              fontSize: 10,
                              color: lightGreyTheme,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: toRemember,
                    builder: (context, toRememberVal, child) {
                      return Checkbox(
                        value: toRememberVal,
                        onChanged: (value) {
                          toRemember.value = value!;
                        },
                        activeColor: darkBlueTheme,
                        focusColor: darkGreyTheme,
                        side: const BorderSide(
                          color: lightGrey,
                        ),
                      );
                    },
                  ),
                  const Text(
                    strings.loginRememberMe,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: lightGreyTheme,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (context, value, child) {
                    return GeneralButton(
                      onPressed: () async {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          return;
                        }
                        isLoading.value = true;
                        var responseMessage = await loginPostAPI(
                          emailController.text,
                          passwordController.text,
                          toRemember.value,
                        );
                        isLoading.value = false;
                        if (responseMessage != "OK") {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return GeneralPopUp(
                                message: responseMessage,
                              );
                            },
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Home(),
                            ),
                          );
                        }
                      },
                      text: isLoading.value ? "" : strings.loginButton,
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: width,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      strings.loginOr,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: lightGreyTheme),
                    ),
                    Text(
                      strings.loginContinueWith,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: lightGreyTheme),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  socialmediabutton(strings.loginGoogle, images.googleIcon),
                  const SizedBox(
                    width: 10,
                  ),
                  socialmediabutton(strings.loginApple, images.appleIcon),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  socialmediabutton(strings.facebook, images.facebookIcon),
                  const SizedBox(
                    width: 10,
                  ),
                  socialmediabutton(strings.instagram, images.instagramIcon),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded socialmediabutton(String text, String icon) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: white,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 0),
              color: Colors.black.withOpacity(0.25),
              blurRadius: 2,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 20,
              width: 20,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
