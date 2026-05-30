//Feito por Gustavo Lieb RA: 24023376


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mescla_invest/features/auth/login_page.dart';
import 'package:mescla_invest/features/auth/cadastro_page.dart';
import 'package:mescla_invest/features/auth/recuperar_senha.dart';
import 'package:mescla_invest/widgets/main_navigation.dart';
import 'package:mescla_invest/features/perfil/tabs/sacar_page.dart';
import 'package:mescla_invest/features/perfil/tabs/depositar_page.dart';


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

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if(snapshot.hasData) {
            return const MainNavigation();
          }

          return const LoginScreen();
        },
      ),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroPage(),
        '/recuperar-senha': (context) => const RecuperarSenhaPage(),
        '/depositar': (context) => const DepositarPage(),
        //'/sacar': (context) => const SacarPage(),

        '/main': (context) => const MainNavigation(),
      },
    );
  }
}
