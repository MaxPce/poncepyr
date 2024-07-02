
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_screen.dart';
import 'socio_screen.dart';
import 'register.dart';
import 'package:app_admin/utils/theme.dart'; // Importa tu archivo de tema

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryLightColor], // Utiliza las variables de color definidas en tu tema
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.70,
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(12),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 100, color: Colors.white),
                        SizedBox(height: 30),
                        Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: emailController,
                          hintText: 'Email',
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
                          obscureText: _isObscure3,
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure3 ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isObscure3 = !_isObscure3;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "La contraseña no puede estar vacía";
                            }
                            if (value.length < 6) {
                              return "Por favor ingrese una contraseña válida min. 6 caracteres";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 20),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          ),
                          elevation: 5.0,
                          height: 40,
                          onPressed: () {
                            setState(() {
                              visible = true;
                            });
                            signIn(emailController.text, passwordController.text);
                          },
                          color: Colors.white,
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 20,
                              color: darkColor, // Utiliza la variable de color definida en tu tema
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: visible,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      elevation: 5.0,
                      height: 40,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      color: primaryColor, // Utiliza la variable de color definida en tu tema
                      child: Text(
                        "Registro",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
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

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('rool') == "Socio") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Socio()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Administrador()),
          );
        }
      } else {
        print('El documento no existe en la base de datos.');
      }
    });
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        route();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }
  }
}