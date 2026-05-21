import "package:flutter/material.dart";

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),

      appBar: AppBar(
        title: const Text(
          "Meu Portfólio",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // RESUMO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Valor Total do Portfólio",
                    style: TextStyle(color: Color.fromARGB(255, 88, 88, 88)),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "R\$ 10.250,00",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ), 
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "+ R\$ 450,00 (4.59%)",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          title: "Investido",
                          value: "R\$ 9.800,00",
                          icon: Icons.wallet,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _infoCard(
                          title: "Disponivel",
                          value: "R\$ 10.000,00",
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),

                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            //Grafico
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      "Distribuição do Portfólio",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.blue.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.bar_chart,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //investimentos
            const Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                "Meus Investimentos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

             _investmentCard(
              name: "EcoTech Solutions",
              tokens: "500 tokens",
              investedDate: "Investido em 12/02/2025",
              investedValue: "R\$ 5.250,00",
              profit: "+ R\$ 250,00",
              profitColor: Colors.green,
            ),

            _investmentCard(
              name: "Green Energy AI",
              tokens: "320 tokens",
              investedDate: "Investido em 20/03/2025",
              investedValue: "R\$ 3.200,00",
              profit: "+ R\$ 120,00",
              profitColor: Colors.green,
            ),

            _investmentCard(
              name: "Future Logistics",
              tokens: "180 tokens",
              investedDate: "Investido em 05/04/2025",
              investedValue: "R\$ 1.350,00",
              profit: "- R\$ 30,00",
              profitColor: Colors.red,
            ),

          ],
        ),
      ),
    );
  }

Widget _infoCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ICON + TEXTO
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // VALOR EMBAIXO
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}

  Widget _investmentCard({
    required String name,
    required String tokens,
    required String investedDate,
    required String investedValue,
    required String profit,
    required Color profitColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            tokens,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Text(
            investedDate,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                investedValue,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                profit,
                style: TextStyle(
                  color: profitColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}