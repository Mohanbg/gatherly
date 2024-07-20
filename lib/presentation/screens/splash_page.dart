import 'package:flutter/material.dart';
import 'package:gatherly/data/models/stall_detail.dart';
import 'package:gatherly/presentation/bloc/home_bloc.dart';
import 'package:gatherly/presentation/screens/home_page.dart';

import 'package:hive/hive.dart';
import 'package:sizer/sizer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  Future<void> _initializeApp() async {
    await _clearHiveDB();
    await storeDataInHive();
  }

  Future<void> _clearHiveDB() async {
    var box = await Hive.openBox<StallDetail>('stalls');
    await box.clear();
  }

  Future<void> storeDataInHive() async {
    await Hive.openBox<StallDetail>('stalls');

    homeBloc.addStall(StallDetail(
        date: 'July 11 - July 12, 2024',
        title: 'TechTrends',
        description: 'TechTrends Technologies',
        imageUrl: 'assets/images/techexpo.jpg'));

    homeBloc.addStall(StallDetail(
        date: 'Jun 24 - Jun 25, 2024',
        title: 'Bean Bliss',
        description: 'Coffee House',
        imageUrl: 'assets/images/art.jpg'));

    homeBloc.addStall(StallDetail(
        date: 'July 11 - July 12, 2024',
        title: 'Artisan Alley',
        description: 'Art World',
        imageUrl: 'assets/images/bean.jpg'));

    homeBloc.addStall(StallDetail(
        date: 'Aug 22 - Aug 23, 2024',
        title: 'Decor Delight',
        description: 'Decor Constructions',
        imageUrl: 'assets/images/decor.jpg'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -15.h,
            left: -15.h,
            child: Container(
              height: 50.h,
              width: 60.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20.h),
              ),
            ),
          ),
          Positioned(
            bottom: -15.h,
            right: -15.h,
            child: Container(
              height: 50.h,
              width: 60.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20.h),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'GATHERLY',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
