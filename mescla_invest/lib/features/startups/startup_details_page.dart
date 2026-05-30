//Feito por Gustavo Lieb RA: 24023376


import 'package:flutter/material.dart';
import 'widgets/tabs/overview_tab.dart';
import 'widgets/tabs/structure_tab.dart';
import 'widgets/tabs/questions_tab.dart';

class StartupDetailsPage extends StatelessWidget {
  final Map<String, dynamic> startup;

  const StartupDetailsPage({
    super.key,
    required this.startup,
  });

  @override
  Widget build(BuildContext context) {

  final imageUrl = startup['videoDemo'] ?? 'https://picsum.photos/300/200';
  final title = startup['title'] ?? startup['nome'] ?? '—';
  final description = startup['description'] ?? startup['descricao'] ?? '';
  final valorTokenNum = startup['valorToken'] ?? startup['tokenValue'] ?? 0;
  final tokenValue = 'R\$ ${_formatarReal(valorTokenNum)}';
  final capitalNum = startup['capitalAportado'] ?? startup['capital'] ?? 0;
  final capital = 'R\$ ${_formatarReal(capitalNum)}';

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
                    image: NetworkImage(imageUrl),
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
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        description,
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
                        tokenValue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: infoCard(
                        Icons.groups_2_outlined,
                        'Capital Aportado',
                        capital,
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
                child: TabBarView(children: [
                   OverviewTab(startup: startup),
                   StructureTab(startup: startup),
                   QuestionsTab(startup: startup),
                ])
              )


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
                color: Colors.black,
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
              color: Colors.black,
            ),
          ),
        ],
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
    final texto = valor.toStringAsFixed(2);
    return texto.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');

  }

}

