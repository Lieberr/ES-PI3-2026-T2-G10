// Feito por Leonardo Dionel RA: 25010092

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
  bool canAccessBalcao = false;
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
          canTradeTokens = result.data['canTradeTokens'] ?? true;
          canAccessBalcao = result.data['canAccessBalcao'] ?? false;
          canSendPrivateQuestion =
              result.data['canSendPrivateQuestion'] ?? false;
          carregando = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('ERRO getStartupById: ${e.code} | ${e.message}');
      if (mounted) {
        setState(() {
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
        (startupCompleta['videoDemo'] != null &&
            startupCompleta['videoDemo'].toString().startsWith(
              'https://picsum',
            ))
        ? startupCompleta['videoDemo']
        : 'https://picsum.photos/seed/${startupCompleta['id']}/300/200';
    final title = startupCompleta['nome'] ?? '—';
    final description = startupCompleta['descricao'] ?? '';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),
        body: SafeArea(
          child: Column(
            children: [
              // HEADER com imagem de fundo
              Container(
                height: 200,
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
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // badge de investidor
              if (isInvestor)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  color: const Color(0xFF2563EB).withOpacity(0.08),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Color(0xFF2563EB)),
                      SizedBox(width: 6),
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

              // TABS
              const TabBar(
                labelColor: Color(0xFF2563EB),
                unselectedLabelColor: Colors.black54,
                indicatorColor: Color(0xFF2563EB),
                tabs: [
                  Tab(text: 'Visão Geral'),
                  Tab(text: 'Estrutura'),
                  Tab(text: 'Perguntas'),
                ],
              ),

              // CONTEÚDO — tudo scrolla dentro do TabBarView
              Expanded(
                child: TabBarView(
                  children: [
                    OverviewTab(
                      startup: startupCompleta,
                      canTradeTokens: canTradeTokens,
                      canAccessBalcao: canAccessBalcao,
                    ),
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
}
