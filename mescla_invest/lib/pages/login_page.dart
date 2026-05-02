import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Ícone
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.rocket, color: Colors.white, size: 32),
              ),

              const SizedBox(height: 24),

              const Text(
                "Bem-vindo ao",
                style: TextStyle(fontSize: 18),
              ),

              const Text(
                "MesclaInvest",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Faça login para continuar",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // Email
              const Text("E-mail",
               style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
              const SizedBox(height: 8),

              TextField(
                decoration: InputDecoration(
                  hintText: "seu@email.com",
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.4)
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.black.withOpacity(0.4),

                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Senha
              const Text("Senha",
               style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
              const SizedBox(height: 8),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Digite sua senha",
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.4)
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.black.withOpacity(0.4),
                    ),
                  suffixIcon: const Icon(Icons.visibility_outlined),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Acao aqui
                  },
                  child: const Text(
                    "Esqueci minha senha",
                    style: TextStyle(
                      color: Color.fromARGB(255, 6, 64, 255),
                    ),
                  ),
                ),
                ),

              const SizedBox(height: 18),

              // Botão
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(21, 93, 252, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Entrar"),
                ),
              ),

              const SizedBox(height: 20),

              

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Não tem uma conta? ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Cadastre-se",
                        style: const TextStyle(
                          color: Color.fromRGBO(21, 93, 252, 1),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/cadastro');
                          },
                          mouseCursor: SystemMouseCursors.click,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}