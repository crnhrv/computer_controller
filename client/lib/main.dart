// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:windows_controller/widgets/windows_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final darkElevatedButtonTheme = ElevatedButtonThemeData(style: ButtonStyle(
        backgroundColor:
        MaterialStateProperty.all<Color>(Colors.deepOrange)));

    final darkTextButtonTheme = TextButtonThemeData(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith(
                    (state) => state.any(
                        (element) => element == MaterialState.pressed)
                    ? Colors.orange
                    : Colors.white)));

    return MaterialApp(
        title: 'Windows Controller',
        home: const WindowsController(),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark().copyWith(
            elevatedButtonTheme:darkElevatedButtonTheme,
            textButtonTheme: darkTextButtonTheme));
  }
}