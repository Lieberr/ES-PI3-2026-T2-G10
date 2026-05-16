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

            Container(
              width: double.infinity,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Seu saldo disponível",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "R\$ ",
                        style: const TextStyle(
                          fontSize: 30,
                          color: Color(0xFF2962FF),
                          fontWeight: FontWeight.bold,
                        ),
                      )
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

            SizedBox(height: 5),

            Text(
              "Disponíveis: ${widget.disponiveis} ",
              style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 121, 121, 121),
              fontWeight: FontWeight.bold,
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
                children: [
                  // QUANTIDADE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quantidade",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      Text(
                        "$quantidade tokens",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // VALOR UNITÁRIO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Valor unitário",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      Text(
                        "R\$ ${precoUnitario.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Divider(color: Colors.grey.shade300),

                  const SizedBox(height: 16),

                  // TOTAL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "R\$ ${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
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
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  backgroundColor: Color.fromRGBO(21, 93, 252, 1),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
                ),
                child: const Text(
                  "Confirmar compra",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500), // Adicionado para melhor contraste
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}