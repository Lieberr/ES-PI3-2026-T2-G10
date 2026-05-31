//Feito por Gustavo Lieb RA: 24023376

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {

  final TextEditingController emailController = TextEditingController();
  bool carregando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // Ícone
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color.fromARGB(106, 155, 203, 243),
              child: const Icon(
                Icons.lock,
                size: 40,
                color: Color.fromRGBO(21, 93, 252, 1)
              ),
            ),

            const SizedBox(height: 30),

            // Título
            const Text(
              'Esqueceu sua senha?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Descrição
            const Text(
              'Não se preocupe! Digite seu e-mail abaixo e enviaremos instruções para redefinir sua senha.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(188, 0, 0, 0),
              ),
            ),

            const SizedBox(height: 30),

            // Campo de email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(
                  color: Colors.black.withOpacity(0.5)
                ),
                hintText: 'seu@email.com',
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.3)
                ),
                prefixIcon: const Icon(Icons.email),
                prefixIconColor: Colors.black.withOpacity(0.2),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botão
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: carregando ? null : recuperarSenha,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromRGBO(21, 93, 252, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: carregando
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Enviar instruções',
                        style: TextStyle(fontSize: 16),
                      )
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> recuperarSenha() async {
    try {
      final email = emailController.text.trim();

      if(email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Digite seu email."),
          )
        );
        return;
      }

      setState(() {
        carregando = true;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Email de recuperação enviado com sucesso."
          )
        )
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = "Erro ao recuperar senha.";

      if(e.code == 'user-not-found') {
        mensagem = "Nenhum usuario encontrado com esse email.";
      } else if(e.code == 'invalid-email') {
        mensagem = "Email inválido";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }
}