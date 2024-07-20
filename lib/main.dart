import 'package:flutter/material.dart';
import 'package:gatherly/data/models/data_stall.dart';
import 'package:gatherly/data/models/stall_detail.dart';
import 'package:gatherly/presentation/screens/splash_page.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Hive.registerAdapter(StallDetailAdapter());
  Hive.registerAdapter(DataStallAdapter());

  await Hive.openBox<StallDetail>('stalls');
  await Hive.openBox<DataStall>('mediaBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        home: const SplashPage(),
      );
    });
  }
}
