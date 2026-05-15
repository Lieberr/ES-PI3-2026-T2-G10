import 'package:flutter/material.dart';

class BuyTokenPage extends StatelessWidget {
  final String nome;
  final String preco;
  final String imagem;
  final String disponiveis;

  const BuyTokenPage({
    super.key,
    required this.nome,
    required this.preco,
    required this.imagem,
    required this.disponiveis,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Comprar Tokens"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // CARD INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imagem,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nome,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),

                      const SizedBox(height: 4),

                      Text(disponiveis,
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PREÇO
            Text(
              "Preço por token",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            Text(
              preco,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // INPUT
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantidade de tokens",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOTÃO FINAL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.blue,
                ),
                child: const Text("Confirmar compra"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}