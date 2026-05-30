//Feito por Gustavo Lieb RA: 24023376


import 'package:flutter/material.dart';

class SellTokenPage extends StatefulWidget {
  final String nome;
  final String preco;
  final String imagem;
  final String disponiveis;

  const SellTokenPage({
    super.key,
    required this.nome,
    required this.preco,
    required this.imagem,
    required this.disponiveis,
  });

  @override
  State<SellTokenPage> createState() => _SellTokenPageState();
}

class _SellTokenPageState extends State<SellTokenPage> {
  final TextEditingController _controller = TextEditingController();

  int quantidade = 0;
  late double precoUnitario;

  @override
  void initState() {
    super.initState();

    precoUnitario = double.parse(
      widget.preco
          .replaceAll("R\$", "")
          .replaceAll(",", ".")
          .trim(),
    );
  }

  double get total => quantidade * precoUnitario;

  double get taxa => total * 0.01;

  double get liquido => total - taxa;

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
        title: const Text("Vender Tokens"),
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
                          color: Color.fromRGBO(245, 73, 0, 1),
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

            // TOKENS DISPONÍVEIS
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
                    "Seus tokens disponíveis",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.disponiveis,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Color.fromRGBO(245, 73, 0, 1),
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

            // CARD RESUMO
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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
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

                  // PREÇO UNITÁRIO
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        "Valor unitário",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      Text(
                        "R\$ ${_formatarReal(precoUnitario)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // TAXA
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        "Taxa",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      Text(
                        "- R\$ ${_formatarReal(taxa)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Divider(color: Colors.grey.shade300),

                  const SizedBox(height: 16),

                  // TOTAL LÍQUIDO
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      const Text(
                        "Você receberá",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "R\$ ${_formatarReal(liquido)}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(245, 73, 0, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // BOTÃO
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 22),

                  backgroundColor:
                      const Color.fromRGBO(245, 73, 0, 1),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: const Text(
                  "Confirmar venda",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarReal(num valor) {
final texto = valor.toStringAsFixed(2);
final partes = texto.split('.');
final inteira = partes[0];
final decimal = partes[1];
final formatada =
inteira.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
return '$formatada,$decimal';
}

}