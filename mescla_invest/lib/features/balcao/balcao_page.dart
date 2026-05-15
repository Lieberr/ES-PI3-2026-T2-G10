import 'package:flutter/material.dart';

class BalcaoPage extends StatelessWidget {
  const BalcaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final startups = [
      {
        "nome": "HealthAI",
        "tokens": "12 000 tokens disponíveis",
        "preco": "R\$ 25,00",
        "variacao": "+5.20%",
        "imagem":
            "https://images.unsplash.com/photo-1516321318423-f06f85e504b3",
      },
      {
        "nome": "AgriSmart",
        "tokens": "20 000 tokens disponíveis",
        "preco": "R\$ 15,30",
        "variacao": "+3.80%",
        "imagem":
            "https://images.unsplash.com/photo-1501004318641-b39e6451bec6",
      },
      {
        "nome": "EcoTech Solutions",
        "tokens": "45 000 tokens disponíveis",
        "preco": "R\$ 10,50",
        "variacao": "+2.50%",
        "imagem":
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
      },
      {
        "nome": "FinFlow",
        "tokens": "90 000 tokens disponíveis",
        "preco": "R\$ 5,00",
        "variacao": "+0.50%",
        "imagem":
            "https://images.unsplash.com/photo-1556740749-887f6717d7e4",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              // TÍTULO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Balcão de Tokens',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.swap_vert),
                  ),
                ],
              ),
            

              const SizedBox(height: 20),

              // LISTA
              Expanded(
                child: ListView.builder(
                  itemCount: startups.length,
                  itemBuilder: (context, index) {
                    final startup = startups[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [

                            // TOPO CARD
                            Row(
                              children: [

                                // FOTO
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    startup["imagem"]!,
                                    width: 62,
                                    height: 62,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                // INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        startup["nome"]!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        startup["tokens"]!,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // PREÇO
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [

                                    Text(
                                      startup["preco"]!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        startup["variacao"]!,
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // BOTÕES
                            Row(
                              children: [

                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.shopping_cart_outlined),
                                    label: const Text('Comprar'),

                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.attach_money),
                                    label: const Text('Vender'),

                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.deepOrange,
                                      side: const BorderSide(
                                        color: Colors.deepOrange,
                                        width: 2,
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // NAVBAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            label: 'Startups',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Balcão',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Portfólio',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}