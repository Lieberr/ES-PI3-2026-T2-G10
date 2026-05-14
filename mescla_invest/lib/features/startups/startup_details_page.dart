import 'package:flutter/material.dart';

class StartupDetailsPage extends StatelessWidget {
  final Map<String, dynamic> startup;

  const StartupDetailsPage({
    super.key,
    required this.startup,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,

      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),

        body: SafeArea(
          child: Column(
            children: [

              // HEADER
              Container(
                height: 240,
                width: double.infinity,

                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(startup['image']),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        startup['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        startup['description'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // INFO CARDS
              Padding(
                padding: const EdgeInsets.all(16),

                child: Row(
                  children: [

                    Expanded(
                      child: infoCard(
                        'Valor do Token',
                        startup['tokenValue'],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: infoCard(
                        'Capital',
                        startup['capital'],
                      ),
                    ),
                  ],
                ),
              ),

              // TABS
              const TabBar(
                labelColor: Color(0xFF2563EB),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF2563EB),

                tabs: [
                  Tab(text: 'Visão Geral'),
                  Tab(text: 'Estrutura'),
                  Tab(text: 'Perguntas'),
                ],
              ),

              // CONTEÚDO
              Expanded(
                child: TabBarView(
                  children: [

                    // VISÃO GERAL
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [

                        const Text(
                          'Sumário Executivo',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'A startup desenvolve soluções tecnológicas inovadoras para transformar o mercado.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFF4B5563),
                          ),
                        ),

                        const SizedBox(height: 24),

                        sectionCard(),
                      ],
                    ),

                    // ESTRUTURA
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: const [

                        Text(
                          'Estrutura',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // PERGUNTAS
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: const [

                        Text(
                          'Perguntas Frequentes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget sectionCard() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'Tokens',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total de Tokens'),
              Text(
                '100 000',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Disponíveis'),
              Text(
                '45 000',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}