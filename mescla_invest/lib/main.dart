import 'package:flutter/material.dart';
import 'package:mescla_invest/pages/login_page.dart';
import 'package:mescla_invest/pages/cadastro_page.dart';

void main() {
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

      // Tela inicial
      initialRoute: '/',

      // Rotas do app
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroPage(),
      },
    );
  }
}