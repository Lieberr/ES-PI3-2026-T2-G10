import 'package:flutter/material.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool obscureSenha = true;
  bool obscureConfirmar = true;

  void criarConta() {
    if (_formKey.currentState!.validate()) {
      print("Conta criada!");
      // Aqui você conecta com backend depois
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  String? validarEmail(String? value) {
    if (value == null || value.isEmpty) return "Informe o e-mail";
    if (!value.contains("@")) return "E-mail inválido";
    return null;
  }

  String? validarCPF(String? value) {
    if (value == null || value.isEmpty) return "Informe o CPF";
    if (value.length < 11) return "CPF inválido";
    return null;
  }

  String? validarTelefone(String? value) {
    if (value == null || value.isEmpty) return "Informe o telefone";
    if (value.length < 10) return "Telefone inválido";
    return null;
  }

  String? validarSenha(String? value) {
    if (value == null || value.isEmpty) return "Informe a senha";
    if (value.length < 6) return "Mínimo 6 caracteres";
    return null;
  }

  String? validarConfirmacao(String? value) {
    if (value != senhaController.text) return "Senhas não coincidem";
    return null;
  }

  Widget buildInput({
  required String label,
  required IconData icon,
  required TextEditingController controller,
  String? Function(String?)? validator,
  bool isPassword = false,
  bool obscure = false,
  VoidCallback? toggle,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,

      // 👇 TEXTO DIGITADO
      style: TextStyle(
        color: Colors.black.withOpacity(1),
      ),

      decoration: InputDecoration(
        labelText: label,

        // 👇 LABEL
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.4),
        ),

        // 👇 ÍCONE MAIS SUAVE
        prefixIcon: Icon(
          icon,
          color: Colors.black.withOpacity(0.4),
        ),

        // 👇 ÍCONE DE SENHA
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black.withOpacity(0.4),
                ),
                onPressed: toggle,
              )
            : null,

        filled: true,
        fillColor: Colors.grey[200],

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),

        // 👇 cor quando clica (focus)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromRGBO(21, 93, 252, 1),
            width: 1.5,
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Criar Conta"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cadastre-se",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                "Preencha os dados abaixo para criar sua conta",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              const Text('Nome Completo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14
              )),
              const SizedBox(height: 8),

              buildInput(
                label: "Digite seu nome completo",
                icon: Icons.person,
                controller: nomeController,
                validator: (v) =>
                    v!.isEmpty ? "Informe seu nome" : null,
              ),

              const Text('E-mail',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
              const SizedBox(height: 8),

              buildInput(
                label: "seu@email.com",
                icon: Icons.email,
                controller: emailController,
                validator: validarEmail,
              ),

            const Text('CPF',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
              const SizedBox(height: 8),


              buildInput(
                label: "000.000.000-00",
                icon: Icons.badge,
                controller: cpfController,
                validator: validarCPF,
              ),

              
            const Text('Telefone Celular',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
              const SizedBox(height: 8),

              buildInput(
                label: "(00) 00000-0000",
                icon: Icons.phone,
                controller: telefoneController,
                validator: validarTelefone,
              ),

            const Text('Senha',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
              const SizedBox(height: 8),


              buildInput(
                label: "Senha",
                icon: Icons.lock,
                controller: senhaController,
                validator: validarSenha,
                isPassword: true,
                obscure: obscureSenha,
                toggle: () {
                  setState(() {
                    obscureSenha = !obscureSenha;
                  });
                },
              ),

            const Text('Confirmar Senha',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
              const SizedBox(height: 8),


              buildInput(
                label: "Confirmar senha",
                icon: Icons.lock,
                controller: confirmarSenhaController,
                validator: validarConfirmacao,
                isPassword: true,
                obscure: obscureConfirmar,
                toggle: () {
                  setState(() {
                    obscureConfirmar = !obscureConfirmar;
                  });
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: criarConta,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromRGBO(21, 93, 252, 1), // 👈 só essa parte azul
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Criar conta"),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Já tem uma conta? ",
                      children: [
                        TextSpan(
                          text: "Fazer login",
                          style: TextStyle(color: Color.fromRGBO(21, 93, 252, 1), 
),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}