import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF2696F3); // #2696f3
const Color primaryLightColor = Color(0xFF82C4F9); // #82c4f9
const Color darkColor = Color(0xFF30546C); // #30546c
const Color secondaryColor = Color(0xFF7C949C); // #7c949c
const Color accentColor = Color(0xFFBAC0C7); // #bac0c7
const Color backgroundColor = Color.fromARGB(255, 252, 253, 253); // #243c44

final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  appBarTheme: AppBarTheme(
    color: primaryColor,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: backgroundColor,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    shadowColor: Colors.grey.withOpacity(0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
  textTheme: TextTheme(
    headline1: TextStyle(color: darkColor),
    headline6: TextStyle(color: secondaryColor),
    bodyText1: TextStyle(color: darkColor),
    bodyText2: TextStyle(color: secondaryColor),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
    background: backgroundColor,
    surface: Colors.white,
  ),
);
