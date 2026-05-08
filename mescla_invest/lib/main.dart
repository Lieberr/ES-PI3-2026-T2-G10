import 'package:flutter/material.dart';
import 'package:mescla_invest/pages/login_page.dart';
import 'package:mescla_invest/pages/cadastro_page.dart';
import 'package:mescla_invest/pages/recuperar_senha.dart';

import 'package:mescla_invest/widgets/main_navigation.dart';

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
      initialRoute: '/main',

      // Rotas do app
      routes: {
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroPage(),
        '/recuperar-senha': (context) => const RecuperarSenhaPage(),
        
        //App Principal
        '/main': (context) => const MainNavigation(),
        
      },
    );
  }
}