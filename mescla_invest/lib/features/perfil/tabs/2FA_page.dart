//Feito por Gustavo Lieb RA: 24023376


import 'package:flutter/material.dart';

class Email2FAPage extends StatefulWidget {
  const Email2FAPage({super.key});

  @override
  State<Email2FAPage> createState() => _Email2FaPageState();
}

class _Email2FaPageState extends State<Email2FAPage> {
  final TextEditingController codeController = TextEditingController();

  bool codeSent = false;
  bool isVerified = false;

  String fakeCode = "123456"; //Simulacao

  void SendCode() {
    setState(() {
      codeSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Código enviado para seu e-mail"),
      ),
    );

    //Aqui trocar para backend real depois
    print("Codigo enviado: $fakeCode");
  }

  void verifyCode() {
    if(codeController.text == fakeCode) {
      setState(() {
        isVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("2FA ativado com sucesso"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Código Inválido"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),

      appBar: AppBar(
        title: const Text(
          "Autenticação 2FA",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.email_outlined,
              size: 80,
              color: Color(0xff2453ff),
            ),

            const SizedBox(height: 15),

            const Text(
              "Proteção por e-mail",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enviaremos um código de verificação "
              "para seu e-mail cadastrado.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            //Botao de enviar codigo

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: codeSent ? null : SendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xaff2453ff),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(16),
                  ),
                ),
                child: Text(
                  codeSent
                    ? "Código enviado"
                    : "Enviar código",
                ),
              ),
            ),

            const SizedBox(height: 20),

            //Input codigo
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Digite o código recebido",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xff2453ff),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //Botao verificar

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: codeSent ? verifyCode : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(16),
                  ),
                ),
                child: const Text("Verificar código"),
              ),
            ),

            const SizedBox(height: 30),

            if (isVerified)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "2FA ativado com sucesso!",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}