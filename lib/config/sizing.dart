import 'package:flutter/material.dart';

class Sizing {
  static double getContentArea(BuildContext context) =>
      MediaQuery.of(context).size.height -
      (kBottomNavigationBarHeight + kToolbarHeight);
}
