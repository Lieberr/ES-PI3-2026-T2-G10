import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'widgets/tabs/overview_tab.dart';
import 'widgets/tabs/structure_tab.dart';
import 'widgets/tabs/questions_tab.dart';

class StartupDetailsPage extends StatefulWidget {
  final Map<String, dynamic> startup;

  const StartupDetailsPage({super.key, required this.startup});

  @override
  State<StartupDetailsPage> createState() => _StartupDetailsPageState();
}

class _StartupDetailsPageState extends State<StartupDetailsPage> {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  Map<String, dynamic> startupCompleta = {};
  bool isInvestor = false;
  bool canTradeTokens = false;
  bool canSendPrivateQuestion = false;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDetalhes();
  }

  Future<void> carregarDetalhes() async {
    try {
      final callable = _functions.httpsCallable('getStartupById');
      final result = await callable.call({'id': widget.startup['id']});

      if (mounted) {
        setState(() {
          startupCompleta = Map<String, dynamic>.from(result.data['startup']);
          isInvestor = result.data['isInvestor'] ?? false;
          canTradeTokens = result.data['canTradeTokens'] ?? false;
          canSendPrivateQuestion =
              result.data['canSendPrivateQuestion'] ?? false;
          carregando = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('ERRO getStartupById: ${e.code} | ${e.message}');
      if (mounted) {
        setState(() {
          // Fallback: usa os dados básicos que vieram da listagem
          startupCompleta = widget.startup;
          carregando = false;
        });
      }
    } catch (e) {
      debugPrint('ERRO GENERICO: $e');
      if (mounted) {
        setState(() {
          startupCompleta = widget.startup;
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final imageUrl =
        startupCompleta['videoDemo'] ?? 'https://picsum.photos/300/200';
    final title = startupCompleta['nome'] ?? '—';
    final description = startupCompleta['descricao'] ?? '';
    final valorTokenNum = startupCompleta['valorToken'] ?? 0;
    final tokenValue = 'R\$ ${_formatarReal(valorTokenNum)}';
    final capitalNum = startupCompleta['capitalAportado'] ?? 0;
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
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
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

              // Badge de investidor
              if (isInvestor)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Você é investidor desta startup',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
                    OverviewTab(startup: startupCompleta),
                    StructureTab(startup: startupCompleta),
                    QuestionsTab(
                      startup: startupCompleta,
                      canSendPrivateQuestion: canSendPrivateQuestion,
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

  String _formatarReal(num valor) {
    final texto = valor.toStringAsFixed(2);
    final partes = texto.split('.');
    final inteira = partes[0];
    final decimal = partes[1];
    final formatada = inteira.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return '$formatada,$decimal';
  }
}
