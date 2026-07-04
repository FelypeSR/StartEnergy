import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:startenergy/main.dart';

/// Envolve [home] no [ScreenUtilInit] do app (mesma resolução de referência do
/// `main.dart`). Necessário em todo teste que monta widgets do jogo, pois eles
/// usam unidades escaladas (`.r`/`.sp`).
Widget testApp(Widget home) => ScreenUtilInit(
      designSize: StartEnergyApp.designSize,
      minTextAdapt: true,
      builder: (_, __) => MaterialApp(home: home),
    );