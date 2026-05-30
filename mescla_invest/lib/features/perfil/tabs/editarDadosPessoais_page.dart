//Feito por Gustavo Lieb RA: 24023376


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDatePage();
}


class _PersonalDatePage extends State<PersonalDataPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
        TextEditingController();

  final TextEditingController emailController =
        TextEditingController();

  final TextEditingController phoneController =
        TextEditingController();
        
  String _cpfMascarado = '';
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  double get _percentualPerfil {
    int total = 0;
    int preenchidos = 0;

    //Cada campo vale 1 ponto
    total += 5;
    if (nameController.text.isNotEmpty) preenchidos++;
    if (emailController.text.isNotEmpty) preenchidos++;
    if(phoneController.text.isNotEmpty) preenchidos++;
    if(_cpfMascarado.isNotEmpty) preenchidos++;
    if(FirebaseAuth.instance.currentUser != null) preenchidos++;

    return preenchidos / total;
  }

  String get _textoPercentual{
    return '${(_percentualPerfil * 100).toInt()}% do perfil completo';
  }

        
  Future<void> _carregarDados() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
    if(uid == null) return;

    final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
    
    if(doc.exists) {
      final data = doc.data()!;
      final cpf = data['cpf'] as String? ?? '';
      final telefone = data['telefone'] as String? ?? '';


      //Formatar Telefone
      String telFomatado = telefone;
      if(telefone.length == 11) {
        telFomatado = 
            '(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}';
      } else if(telefone.length == 10) {
        telFomatado = 
            '(${telefone.substring(0, 2)}) ${telefone.substring(2, 6)}-${telefone.substring(6)}';
      }

      //Formatar CPF
      String cpfMascarado = cpf;
      if(cpf.length == 11) {
        cpfMascarado = 
          '${cpf.substring(0, 3)}.***.***-${cpf.substring(9)}';
      }

      setState(() {
        nameController.text = data['nomeCompleto'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = telFomatado;
        _cpfMascarado = cpfMascarado;
        _carregando = false;
      });

    } else {
      setState(() {
        _carregando = false;
      });
    } 
    } catch (e) {
      print("ERRO AO CARREGAR DADOS: $e");
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Dados Pessoais",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              //CARD PERFIL
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [

                    //Foto
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: 
                            const Color(0xff2453ff).withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 55,
                            color: Color(0xff2453ff),
                          ),
                        ),

              
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      _textoPercentual,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: _percentualPerfil,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xff2453ff),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //Nome

              buildTextField(
                controller: nameController,
                label: "Nome Completo",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 18),

              //Email
              buildTextField(
                controller: emailController,
                label: "E-mail",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 18),

              //Telefone
              buildTextField(
                controller: phoneController,
                label: "Telefone",
                icon: Icons.phone_outlined,
              ),

              const SizedBox(height: 18),

              //CPF
              buildReadOnlyField(
                label: "CPF",
                value: _cpfMascarado,
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 18),

              //Senha
              buildReadOnlyField(
                label: "Senha",
                value:  "********",
                icon: Icons.lock_outline,
                
              ),

              const SizedBox(height: 35),

              //Botao
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Dados atualizados com sucesso",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2453ff),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Salvar Alterações",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          border: InputBorder.none,
          icon: Icon(
            icon,
            color: const Color(0xff2453ff),
          ),
          labelText: label,
        ),
      ),
    );
  }

  Widget buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xff2453ff),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.verified,
            color: Colors.green,
            size: 22,
          )
        ],
      ),
    );
  }
}