import 'package:flutter/material.dart';
import 'package:mescla_invest/features/balcao/sellToken_page.dart';
import 'buyToken_page.dart';

class BalcaoPage extends StatefulWidget {
  const BalcaoPage({super.key});

  @override
  State<BalcaoPage> createState() => _BalcaoPageState();
}

class _BalcaoPageState extends State<BalcaoPage> {
  final TextEditingController _searchController = TextEditingController();

  String search = "";
  bool orderAsc = true;



  final List<Map<String, dynamic>> startups = [
    {
      "nome": "HealthAI",
      "tokens": "12 000 tokens disponíveis",
      "preco": 25.00,
      "variacao": "+5.20%",
      "imagem":
          "https://images.unsplash.com/photo-1516321318423-f06f85e504b3",
    },
    {
      "nome": "AgriSmart",
      "tokens": "20 000 tokens disponíveis",
      "preco": 15.30,
      "variacao": "+3.80%",
      "imagem":
          "https://images.unsplash.com/photo-1501004318641-b39e6451bec6",
    },
    {
      "nome": "EcoTech Solutions",
      "tokens": "45 000 tokens disponíveis",
      "preco": 10.50,
      "variacao": "+2.50%",
      "imagem":
          "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
    },
    {
      "nome": "FinFlow",
      "tokens": "90 000 tokens disponíveis",
      "preco": 5.00,
      "variacao": "+0.50%",
      "imagem":
          "https://images.unsplash.com/photo-1556740749-887f6717d7e4",
    },
  ];

  @override
  void initState() {
    super.initState();

    sortStartups();
  }

    // Funcao para ordenar 
  void sortStartups() {
    startups.sort((a, b) {
      final priceA = a["preco"] as double;
      final priceB = b["preco"] as double;

      return orderAsc
            ? priceA.compareTo(priceB)
            : priceB.compareTo(priceA);
    });
  }

  @override
  Widget build(BuildContext context) {

    final filteredStartups = startups.where((startup) {
      final nome = startup["nome"].toString().toLowerCase();
      return nome.contains(search.toLowerCase());
    }).toList();

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
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(1000, 80, 0, 0),
                        items: [
                          PopupMenuItem(
                            value: "asc",
                            child: Row(
                              children: const [
                                Icon(Icons.arrow_upward),
                                SizedBox(width: 10),
                                Text("Menor preço -> Maior"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "desc",
                            child: Row(
                              children: const [
                                Icon(Icons.arrow_downward),
                                SizedBox(width: 10),
                                Text("Maior preço -> Menor"),
                              ],
                            ),
                          ),
                        ],
                      ).then((value) {
                        if (value == "asc") {
                          setState(() {
                            orderAsc = true;
                            sortStartups();
                          });
                        } else if (value == "desc") {
                          setState(() {
                            orderAsc = false;
                            sortStartups();
                          });
                        }
                      });
                    },
                    icon: const Icon(Icons.swap_vert),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 🔎 INPUT DE BUSCA
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Buscar startup...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LISTA
              Expanded(
                child: ListView.builder(
                  itemCount: filteredStartups.length,
                  itemBuilder: (context, index) {
                    final startup = filteredStartups[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
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
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    startup["imagem"] as String,
                                    width: 62,
                                    height: 62,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        startup["nome"] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        startup["tokens"] as String,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "R\$ ${(startup["preco"] as double).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        startup["variacao"] as String,
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
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BuyTokenPage(
                                            nome: startup["nome"] as String,
                                            preco:
                                                "R\$ ${(startup["preco"] as double).toStringAsFixed(2)}",
                                            imagem:
                                                startup["imagem"] as String,
                                            disponiveis:
                                                startup["tokens"] as String,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons
                                        .shopping_cart_outlined),
                                    label: const Text('Comprar'),

                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Color.fromRGBO(21, 93, 252, 1),
                                      side: const BorderSide(color: Color.fromRGBO(21, 93, 252, 1), width: 1),
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      )
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SellTokenPage(
                                            nome: startup["nome"] as String,
                                            preco:
                                                "R\$ ${(startup["preco"] as double).toStringAsFixed(2)}",
                                            imagem:
                                                startup["imagem"] as String,
                                            disponiveis:
                                                startup["tokens"] as String,
                                          ),
                                        ),
                                      );
                                    },
                                    icon:
                                        const Icon(Icons.attach_money),
                                    label: const Text('Vender'),

                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color.fromRGBO(245, 73, 0, 1),
                                      side: const BorderSide(
                                        color: Color.fromRGBO(245, 73, 0, 1),
                                        width: 1,
                                      ),                    
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      )
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
    );
  }
}