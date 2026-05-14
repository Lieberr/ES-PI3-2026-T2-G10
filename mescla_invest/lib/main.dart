import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:mescla_invest/features/auth/login_page.dart';
import 'package:mescla_invest/features/auth/cadastro_page.dart';
import 'package:mescla_invest/features/auth/recuperar_senha.dart';
import 'package:mescla_invest/features/startups/widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MesclaInvest',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      initialRoute: '/main',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroPage(),
        '/recuperar-senha': (context) => const RecuperarSenhaPage(),

        // App Principal
        '/main': (context) => const MainNavigation(),
      },
    );
  }
}