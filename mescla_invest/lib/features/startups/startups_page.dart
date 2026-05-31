import 'package:flutter/material.dart';
import 'widgets/startup_card.dart';
import 'startup_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String filtroSelecionado = 'todos';

  final List<Map<String, dynamic>> startups = [
    {
      'image':
          'https://images.unsplash.com/photo-1497436072909-60f360e1d4b1?q=80&w=400',
      'title': 'EcoTech Solutions',
      'status': 'Em operação',
      'description': 'Plataforma de gestão sustentável para empresas',
      'tokenValue': 'R\$ 10.50',
      'capital': 'R\$ 250k',
      'tokens': '45 000 tokens disponíveis',
      'progress': 0.58,
      'variation': '+ 2.5%',
      'positive': true,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1516549655169-df83a0774514?q=80&w=400',
      'title': 'HealthAI',
      'status': 'Em expansão',
      'description': 'Inteligência artificial para diagnósticos médicos',
      'tokenValue': 'R\$ 25.00',
      'capital': 'R\$ 800k',
      'tokens': '12 000 tokens disponíveis',
      'progress': 0.82,
      'variation': '+ 5.2%',
      'positive': true,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=400',
      'title': 'EduTech Brasil',
      'status': 'Nova',
      'description': 'Plataforma de educação personalizada com IA',
      'tokenValue': 'R\$ 8.75',
      'capital': 'R\$ 180k',
      'tokens': '35 000 tokens disponíveis',
      'progress': 0.47,
      'variation': '- 1.2%',
      'positive': false,
    },
  ];

  List<Map<String, dynamic>> get startupsFiltradas {
    if (filtroSelecionado == 'todos') return startups;

    return startups.where((s) => s['status'] == filtroSelecionado).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
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
                      const PopupMenuItem(value: 'todos', child: Text('Todos')),

                      const PopupMenuItem(
                        value: 'Nova',
                        child: Text('Nova (Ideia recentemente publicada)'),
                      ),

                      const PopupMenuItem(
                        value: 'Em operação',
                        child: Text('Em operação'),
                      ),

                      const PopupMenuItem(
                        value: 'Em expansão',
                        child: Text('Em expansão'),
                      ),
                    ],
                  ),
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
                            builder: (_) => StartupDetailsPage(startup: s),
                          ),
                        );
                      },

                      child: StartupCard(
                        image: s['image'],
                        title: s['title'],
                        status: s['status'],
                        description: s['description'],
                        tokenValue: s['tokenValue'],
                        capital: s['capital'],
                        tokens: s['tokens'],
                        progress: s['progress'],
                        variation: s['variation'],
                        positive: s['positive'],
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
}
