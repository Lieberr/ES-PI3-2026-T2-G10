// Feito por Leonardo Dionel RA: 25010092

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // faz o login com email e senha
  Future<UserCredential> login(String email, String senha) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  // desloga o usuário
  Future<void> logout() async {
    await _auth.signOut();
  }

  // retorna o usuário logado atualmente (null se não estiver logado)
  User? get usuarioAtual => _auth.currentUser;
}
