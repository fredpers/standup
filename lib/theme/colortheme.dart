import 'dart:ui';


import 'package:flutter/material.dart';

class ColorTheme{
  static const int PINK=1;
  static const int BLUE=2;
  static const int GREEN=3;

  static int currentSelection=1;

   static Color getPrimary(){
    switch(currentSelection){
      case PINK:
        return Colors.pink.shade200;
      case BLUE:
        return Color(0xFF6AA0E1);
      case GREEN:
        return Colors.greenAccent.shade200;
    }
  }

  static Color getSecondary(){
    switch(currentSelection){
      case PINK:
        return Colors.pinkAccent.shade100;
      case BLUE:
        return Color(0xFF4D90DF);
      case GREEN:
        return Colors.green.shade300;
    }
  }
  static Color getPrimaryByChoice(int color){
    switch(color){
      case PINK:
        return Colors.pink.shade200;
      case BLUE:
        return Color(0xFF6AA0E1);
      case GREEN:
        return Colors.greenAccent.shade200;
    }
  }

  static Color getSecondaryByChoice(int color){
    switch(color){
      case PINK:
        return Colors.pinkAccent.shade100;
      case BLUE:
        return Color(0xFF4D90DF);
      case GREEN:
        return Colors.green.shade300;
    }
  }

}
