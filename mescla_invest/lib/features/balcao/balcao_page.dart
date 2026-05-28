import 'package:flutter/material.dart';
import 'package:mescla_invest/features/balcao/sellToken_page.dart';
import 'buyToken_page.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BalcaoPage extends StatefulWidget {
  const BalcaoPage({super.key});

  @override
  State<BalcaoPage> createState() => _BalcaoPageState();
}

class _BalcaoPageState extends State<BalcaoPage> {
  final TextEditingController _searchController = TextEditingController();

  String search = "";
  bool orderAsc = true;
  String sortMode = 'price';


  final FirebaseFunctions functions = 
        FirebaseFunctions.instanceFor(region: 'southamerica-east1');
  
  List<Map<String, dynamic>> startups = [];
  bool carregando = true;

  Future<void> carregarStartups() async {
    try{
      final user = FirebaseAuth.instance.currentUser;
      if(user == null) {
        if(mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final callable = functions.httpsCallable('getStartups');
      final result = await callable();
      final List data = result.data['startups'] ?? [];

      if(mounted) {
        setState(() {
          startups = 
            data.map((e) => Map<String, dynamic>.from(e)).toList();
            sortStartups();
            carregando = false;
        });

      }
    } catch(e) {
      debugPrint('Erro ao carregar startups: $e');
      if(mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    carregarStartups();
  }

    // Funcao para ordenar 
      void sortStartups() {
      startups.sort((a, b) {
        if (sortMode == "price") {
          final priceA = a["valorToken"] as double;
          final priceB = b["valorToken"] as double;

          return orderAsc
              ? priceA.compareTo(priceB)
              : priceB.compareTo(priceA);
        }

        if (sortMode == "high") {
          return parseVariacao(b["variacao"])
              .compareTo(parseVariacao(a["variacao"]));
        }

        if (sortMode == "low") {
          return parseVariacao(a["variacao"])
              .compareTo(parseVariacao(b["variacao"]));
        }

        return 0;
      });
    }

  // Variacao do token
  double parseVariacao(String v) {
    return double.parse(
      v.replaceAll('%', '').replaceAll('+', '').trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
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
                      showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(1000, 80, 0, 0),
                        items: [
                          PopupMenuItem(
                            value: "price_asc",
                            child: Row(
                              children: const [
                                Icon(Icons.arrow_upward),
                                SizedBox(width: 10),
                                Text("Menor preço -> Maior"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "price_desc",
                            child: Row(
                              children: const [
                                Icon(Icons.arrow_downward),
                                SizedBox(width: 10),
                                Text("Maior preço -> Menor"),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),

                          const PopupMenuItem(
                            value: "high",
                            child: Row(
                              children: [
                                Icon(Icons.trending_up),
                                SizedBox(width: 10),
                                Text("Maior alta")
                              ],
                            ),
                          ),

                          const PopupMenuItem(
                            value: "low",
                            child: Row(
                              children: [
                                Icon(Icons.trending_down),
                                SizedBox(width: 10),
                                Text("Maior queda"),
                              ],
                            ),
                          ),
                          
                        ],
                      ).then((value) {
                        if (value == "price_asc") {
                          setState(() {
                            orderAsc = true;
                            sortStartups();
                          });
                        } else if (value == "price_desc") {
                          setState(() {
                            orderAsc = false;
                            sortStartups();
                          });
                        } else if (value == "high") {
                          setState(() {
                            sortMode = "high";
                            sortStartups();
                          });
                        }
                        else if (value == "low") {
                          setState(() {
                            sortMode = "low";
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
                                    (startup["imagem"] as String?) ?? 'https://picsum.photos/300/200',
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
                                        '${_formatarMilhar(startup['tokensDisponiveis'] ?? 0)} tokens disponíveis',
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
                                        "R\$ ${_formatarReal(startup['valorToken'] ?? 0)}",                                      style: const TextStyle(
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
                                        (startup['variacao'] as String?) ?? '+0%',
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
                                                "R\$ ${_formatarReal(startup['valorToken'] ?? 0)}",
                                            imagem:
                                                (startup["imagem"] as String?) ?? 'https://picsum.photos/300/200',

                                            disponiveis:
                                                '${_formatarMilhar(startup['tokensDisponiveis'] ?? 0)} tokens disponíveis',
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
                                                 "R\$ ${_formatarReal(startup['valorToken'] ?? 0)}",
                                            imagem:
                                                  (startup["imagem"] as String?) ?? 'https://picsum.photos/300/200',
                                            disponiveis:
                                                  '${_formatarMilhar(startup['tokensDisponiveis'] ?? 0)} tokens disponíveis',
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
  String _formatarReal(num valor) {
  final texto = valor.toStringAsFixed(2);
  final partes = texto.split('.');
  final inteira = partes[0];
  final decimal = partes[1];
  final formatada = inteira.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  return '$formatada,$decimal';
}

String _formatarMilhar(num valor) {
  final texto = valor.toStringAsFixed(0);
  return texto.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
}

}