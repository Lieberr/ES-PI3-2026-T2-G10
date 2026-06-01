//Feito por Gustavo Lieb RA: 24023376

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) digits = digits.substring(0, 11);

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) digits = digits.substring(0, 11);

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) formatted += '(';
      if (i == 2) formatted += ') ';
      if (i == 7) formatted += '-';
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
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
  bool _carregando = false;

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

  Future<void> criarConta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_carregando) return;
    setState(() => _carregando = true);

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('cadastrarUsuario');

      final result = await callable.call({
        'nomeCompleto': nomeController.text.trim(),
        'email': emailController.text.trim(),
        'cpf': cpfController.text.trim(),
        'telefone': telefoneController.text.trim(),
        'senha': senhaController.text,
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text,
      );

      // log pra confirmar que funcionou
      print('CADASTRO OK: ${result.data}');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseFunctionsException catch (e) {
      // log completo do erro da function
      print(
        'ERRO FUNCTIONS: code=${e.code} | message=${e.message} | details=${e.details}',
      );

      String mensagem = 'Erro ao criar conta. Tente novamente.';
      if (e.code == 'already-exists') {
        mensagem = e.message ?? 'CPF ou e-mail já cadastrado.';
      } else if (e.code == 'invalid-argument') {
        mensagem = e.message ?? 'Dados inválidos. Verifique e tente novamente.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensagem)));
      }
    } catch (e) {
      // captura qualquer outro erro inesperado
      print('ERRO GENERICO: $e');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro inesperado: $e')));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

String? validarEmail(String? value) {
  if (value == null || value.isEmpty) return "Informe o e-mail";
  final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
  if (!regex.hasMatch(value)) return "E-mail inválido";
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
  if (value.length < 8) return "Mínimo 8 caracteres";
  if (!value.contains(RegExp(r'[A-Z]'))) return "Use ao menos uma letra maiúscula";
  if (!value.contains(RegExp(r'[0-9]'))) return "Use ao menos um número";
  if (!value.contains(RegExp(r'[^A-Za-z0-9]'))) return "Use ao menos um caractere especial";
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
    List<TextInputFormatter> inputFormatters = const [],
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscure,
        inputFormatters: inputFormatters,
        style: TextStyle(color: Colors.black.withOpacity(1)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.4)),
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

              const Text(
                'Nome Completo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              buildInput(
                label: "Digite seu nome completo",
                icon: Icons.person,
                controller: nomeController,
                validator: (v) => v!.isEmpty ? "Informe seu nome" : null,
              ),

              const Text(
                'E-mail',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              buildInput(
                label: "seu@email.com",
                icon: Icons.email,
                controller: emailController,
                validator: validarEmail,
              ),

              const Text(
                'CPF',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              buildInput(
                label: "000.000.000-00",
                icon: Icons.badge,
                controller: cpfController,
                validator: validarCPF,
                inputFormatters: [CpfInputFormatter()]
              ),

              const Text(
                'Telefone Celular',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              buildInput(
                label: "(00) 00000-0000",
                icon: Icons.phone,
                controller: telefoneController,
                validator: validarTelefone,
                inputFormatters: [TelefoneInputFormatter()],
              ),

              const Text(
                'Senha',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              buildInput(
                label: "Senha",
                icon: Icons.lock,
                controller: senhaController,
                validator: validarSenha,
                isPassword: true,
                obscure: obscureSenha,
                toggle: () => setState(() => obscureSenha = !obscureSenha),
              ),

              const Text(
                'Confirmar Senha',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              buildInput(
                label: "Confirmar senha",
                icon: Icons.lock,
                controller: confirmarSenhaController,
                validator: validarConfirmacao,
                isPassword: true,
                obscure: obscureConfirmar,
                toggle: () =>
                    setState(() => obscureConfirmar = !obscureConfirmar),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _carregando ? null : criarConta,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(21, 93, 252, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text("Criar conta"),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text.rich(
                    TextSpan(
                      text: "Já tem uma conta? ",
                      children: [
                        TextSpan(
                          text: "Fazer login",
                          style: TextStyle(
                            color: Color.fromRGBO(21, 93, 252, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
