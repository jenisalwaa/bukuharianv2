import 'package:bukuharianv2/pages/homepage.dart';
import 'package:bukuharianv2/models/diary_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  //inisialisasi isar database untuk diary
  WidgetsFlutterBinding.ensureInitialized();
  await DiaryDatabase.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => DiaryDatabase(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}
