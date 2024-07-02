import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:app_admin/utils/theme.dart'; // Importa tu archivo de tema

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryLightColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(12),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 80),
                        Icon(Icons.app_registration, size: 100, color: Colors.white),
                        SizedBox(height: 30),
                        Text(
                          "Registro",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                        SizedBox(height: 50),
                        _buildTextField(
                          controller: emailController,
                          hintText: 'Correo Electrónico',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "El correo electrónico no puede estar vacío.";
                            }
                            if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]+").hasMatch(value)) {
                              return "Por favor introduzca una dirección de correo electrónico válida";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: passwordController,
                          hintText: 'Contraseña',
                          obscureText: _isObscure,
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "La contraseña no puede estar vacía";
                            }
                            if (!RegExp(r'^.{6,}$').hasMatch(value)) {
                              return "Por favor introduzca una contraseña válida de al menos 6 caracteres";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: confirmpassController,
                          hintText: 'Confirmar Contraseña',
                          obscureText: _isObscure2,
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure2 ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isObscure2 = !_isObscure2;
                              });
                            },
                          ),
                          validator: (value) {
                            if (confirmpassController.text != passwordController.text) {
                              return "Las contraseñas no coinciden";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildActionButton(
                              text: "Login",
                              color: secondaryColor,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              },
                            ),
                            _buildActionButton(
                              text: "Registro",
                              color: primaryColor,
                              onPressed: () {
                                setState(() {
                                  showProgress = true;
                                });
                                signUp(emailController.text, passwordController.text);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        if (showProgress)
                          CircularProgressIndicator(color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        enabled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      elevation: 5.0,
      height: 40,
      onPressed: onPressed,
      color: color,
      child: Text(
        text,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(email: email, password: password).then((value) => postDetailsToFirestore(email)).catchError((e) {
          print(e);
          setState(() {
            showProgress = false;
          });
        });
      } catch (e) {
        print(e);
        setState(() {
          showProgress = false;
        });
      }
    } else {
      setState(() {
        showProgress = false;
      });
    }
  }

  void postDetailsToFirestore(String email) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = firebaseFirestore.collection('users');
    ref.doc(user!.uid).set({'email': emailController.text, 'rool': 'Socio'});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
