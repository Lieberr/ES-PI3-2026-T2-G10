import 'package:flutter/material.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDatePage();
}


class _PersonalDatePage extends State<PersonalDataPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
        TextEditingController(text: "Gustavo Lieb");

  final TextEditingController emailController =
        TextEditingController(text: "gustavoliebfigueira@gmail.com");

  final TextEditingController phoneController =
        TextEditingController(text: "(19) 99999-9999");

  final TextEditingController passwordController = 
        TextEditingController(text: "12345678");


  @override
  Widget build(BuildContext context) {
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

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xff2453ff),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "65% do perfil completo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: 0.65,
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
                value: "123.***.***-90",
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 18),

              //Senha
              buildTextField(
                controller: passwordController,
                label: "Senha",
                icon: Icons.lock_outline,
                obscureText: true,
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