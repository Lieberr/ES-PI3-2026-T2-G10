import 'package:flutter/material.dart';
import 'widgets/tabs/overview_tab.dart';
import 'widgets/tabs/structure_tab.dart';
import 'widgets/tabs/questions_tab.dart';

class StartupDetailsPage extends StatelessWidget {
  final Map<String, dynamic> startup;

  const StartupDetailsPage({super.key, required this.startup});

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

                        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        Icons.account_balance_wallet_outlined,
                        'Valor do Token',
                        startup['tokenValue'],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: infoCard(
                        Icons.groups_2_outlined,
                        'Capital Aportado',
                        startup['capital'],
                      ),
                    ),
                  ],
                ),
              ),

              // TABS
              const TabBar(
                labelColor: Color(0xFF2563EB),
                unselectedLabelColor: Colors.black,
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
                    const OverviewTab(),
                    const StructureTab(),
                    QuestionsTab(startupId: startup['id']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 225, 225, 225),
          width: 1,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xff2563eb)),
              const SizedBox(width: 6),

              Text(title, style: const TextStyle(color: Colors.black)),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
