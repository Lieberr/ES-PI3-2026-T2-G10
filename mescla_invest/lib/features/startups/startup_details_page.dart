import 'package:flutter/material.dart';
import 'widgets/tabs/overview_tab.dart';

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
                    TabBarView(children: [
                      const OverviewTab(),
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

                    ]),

                    // ESTRUTURA
                    

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

  Widget infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

       boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6)
          )
       ]
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xff2563eb),
            ),
            const SizedBox(width: 6),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            )
          ],
          
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

  

}

