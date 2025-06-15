import 'package:dokanmate_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          appName,
        ),
      ),
    );
  }
}
