import 'package:flutter/material.dart';
import 'package:mescla_invest/pages/login_page.dart';
import 'package:mescla_invest/pages/cadastro_page.dart';
import 'package:mescla_invest/pages/recuperar_senha.dart';
import 'package:mescla_invest/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroPage(),
        '/recuperar-senha': (context) => const RecuperarSenhaPage(),
      },
    );
  }
}
