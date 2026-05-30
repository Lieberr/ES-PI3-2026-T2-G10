//Feito por Gustavo Lieb RA: 24023376


import 'package:flutter/material.dart';
import 'widgets/startup_card.dart';
import 'startup_details_page.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

 class _HomePageState extends State<HomePage> {
  

  Future<void> carregarStartups() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    final callable = functions.httpsCallable('getStartups');
    final result = await callable();
    final List data = result.data['startups'] ?? [];

    if (mounted) {
      setState(() {
        startups = data.map((e) => Map<String, dynamic>.from(e)).toList();
        carregando = false;
      });
    }
  } catch (e) {
    debugPrint(e.toString());
    if (mounted) {
      setState(() {
        carregando = false;
      });
    }
  }
}

  final FirebaseFunctions functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');



  @override
  void initState() {
    super.initState();
    carregarStartups();
  }

  String filtroSelecionado = 'todos';

  List<Map<String, dynamic>> startups = [];
  bool carregando = true;

  List <Map<String, dynamic>> get startupsFiltradas {
    if (filtroSelecionado == 'todos') return startups;

    return startups
          .where((s) => s['estagio'] == filtroSelecionado)
          .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      color: const Color(0xFFF3F3F3),

      child: SafeArea(
        child: Column(
          children: [

            // HEADER
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    'Startups',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),

                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      size: 24,
                      color: Colors.black87,
                    ),

                    onSelected: (value) {
                      setState(() {
                        filtroSelecionado = value;
                      });
                    },

                    itemBuilder: (context) => [

                      const PopupMenuItem(
                        value: 'todos',
                        child: Text('Todos'),
                      ),

                      const PopupMenuItem(
                        value: 'Em operação',
                        child: Text('Em operação'),
                      ),

                      const PopupMenuItem(
                        value: 'Em expansão',
                        child: Text('Em expansão'),
                      )
                    ],


                  )
                ],
              ),
            ),

            // LISTA
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),



                children: startupsFiltradas.map((s) {
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 14),

                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StartupDetailsPage(
                                startup: s,
                              ),
                            ),
                          );
                        },

                        child: StartupCard(
                          image: 'https://picsum.photos/300/200',
                          title: s['nome'],
                          status: s['estagio'],
                          description: s['descricao'],
                          tokenValue: 'R\$ ${_formatarReal(s['valorToken'] ?? 0)}',
                          capital: 'R\$ ${_formatarReal(s['capitalAportado'] ?? 0)}',
                          tokens: 'R\$ ${_formatarMilhar(s['tokensDisponiveis'] ?? 0)} tokens disponíveis',
                          progress: 0.5,
                          variation: '+0%',
                          positive: true,
                        ),
                      ),
                    );
                }).toList(),


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
  final formatada = inteira.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  return '$formatada,$decimal';
}

String _formatarMilhar(num valor) {
  final texto = valor.toStringAsFixed(0);
  return texto.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
}
}


