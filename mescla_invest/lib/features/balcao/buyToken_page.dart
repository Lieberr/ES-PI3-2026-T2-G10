import 'package:flutter/material.dart';

class BuyTokenPage extends StatefulWidget {
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
  State<BuyTokenPage> createState() => _BuyTokenPageState();
}

class _BuyTokenPageState extends State<BuyTokenPage> {
  final TextEditingController _controller = TextEditingController();

  int quantidade = 0;
  late double precoUnitario;

  @override
  void initState() {
    super.initState();

    // converte "R$ 25,00" ou "25.00" para double
    precoUnitario = double.parse(
      widget.preco
          .replaceAll("R\$", "")
          .replaceAll(".", "")
          .replaceAll(",", ".")
          .trim(),
    );
    
    // 💡 REMOVIDO: O listener do controller saiu daqui para evitar o erro de ciclo de vida.
  }

  double get total => quantidade * precoUnitario;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.imagem,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.preco} por Token",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // INPUT
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              // 💡 A MÁGICA ACONTECE AQUI:
              // Sempre que o texto mudar, atualiza o estado de forma segura.
              onChanged: (valor) {
                setState(() {
                  quantidade = int.tryParse(valor) ?? 0;
                });
              },
              decoration: InputDecoration(
                labelText: "Quantidade de tokens",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CARD DINÂMICO (ATUALIZA EM TEMPO REAL)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quantidade: $quantidade tokens",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Valor unitário: R\$ ${precoUnitario.toStringAsFixed(2)}",
                  ),
                  const Divider(),
                  Text(
                    "Total: R\$ ${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Confirmar compra",
                  style: TextStyle(color: Colors.white), // Adicionado para melhor contraste
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}