import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/views/home_view.dart';
import 'core/config/config.dart';
import 'viewmodels/user_viewmodel.dart';

Future main() async {
  await Config.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserViewModel()),
      ],
      child: MaterialApp(
        title: 'Clicker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeView(),
      ),
    );
  }
}