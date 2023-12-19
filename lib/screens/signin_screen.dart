import 'package:firebase_auth/firebase_auth.dart';


import 'package:app_admin/reusable_widgets/reusable_widget.dart';


import 'package:app_admin/screens/home_screen.dart';


import 'package:app_admin/screens/reset_password.dart';


import 'package:app_admin/screens/signup_screen.dart';


import 'package:app_admin/utils/color_utils.dart';


import 'package:flutter/material.dart';


class SignInScreen extends StatefulWidget {

  const SignInScreen({super.key});


  @override

  _SignInScreenState createState() => _SignInScreenState();

}


class _SignInScreenState extends State<SignInScreen> {

  TextEditingController _passwordTextController = TextEditingController();


  TextEditingController _emailTextController = TextEditingController();


  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        width: MediaQuery.of(context).size.width,

        height: MediaQuery.of(context).size.height,

        decoration: BoxDecoration(

            gradient: LinearGradient(colors: [

          hexStringToColor("CB2B93"),

          hexStringToColor("9546C4"),

          hexStringToColor("5E61F4")

        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),

        child: SingleChildScrollView(

          child: Padding(

            padding: EdgeInsets.fromLTRB(

                20, MediaQuery.of(context).size.height * 0.2, 20, 0),

            child: Column(

              children: <Widget>[

                logoWidget("images/logo1.png"),

                const SizedBox(

                  height: 30,

                ),

                reusableTextField("Ingrese su correo", Icons.person_outline,

                    false, _emailTextController),

                const SizedBox(

                  height: 20,

                ),

                reusableTextField("Ingrese su contraseña", Icons.lock_outline,

                    true, _passwordTextController),

                const SizedBox(

                  height: 5,

                ),

                forgetPassword(context),

                firebaseUIButton(context, "Ingresar", () {

                  FirebaseAuth.instance

                      .signInWithEmailAndPassword(

                          email: _emailTextController.text,

                          password: _passwordTextController.text)

                      .then((value) {

                    Navigator.push(context,

                        MaterialPageRoute(builder: (context) => HomeScreen()));

                  }).onError((error, stackTrace) {

                    print("Error ${error.toString()}");

                  });

                }),

                signUpOption()

              ],

            ),

          ),

        ),

      ),

    );

  }


  Row signUpOption() {

    return Row(

      mainAxisAlignment: MainAxisAlignment.center,

      children: [

        const Text("¿No tienes una cuenta?",

            style: TextStyle(color: Colors.white70)),

        GestureDetector(

          onTap: () {

            Navigator.push(context,

                MaterialPageRoute(builder: (context) => SignUpScreen()));

          },

          child: const Text(

            " Registrarse",

            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),

          ),

        )

      ],

    );

  }


  Widget forgetPassword(BuildContext context) {

    return Container(

      width: MediaQuery.of(context).size.width,

      height: 35,

      alignment: Alignment.bottomRight,

      child: TextButton(

        child: const Text(

          "Olvidaste tu contraseña?",

          style: TextStyle(color: Colors.white70),

          textAlign: TextAlign.right,

        ),

        onPressed: () => Navigator.push(

            context, MaterialPageRoute(builder: (context) => ResetPassword())),

      ),

    );

  }

}

