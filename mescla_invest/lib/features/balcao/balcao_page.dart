//Feito por Gustavo Lieb RA: 24023376


import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'balcao_startup_page.dart';

class BalcaoPage extends StatefulWidget {
  const BalcaoPage({super.key});

  @override
  State<BalcaoPage> createState() => _BalcaoPageState();
}

class _BalcaoPageState extends State<BalcaoPage> {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _startups = [];
  String _busca = '';
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    carregarStartups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> carregarStartups() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final callable = _functions.httpsCallable('getStartups');
      final result = await callable();
      final List data = result.data['startups'] ?? [];

      if (mounted) {
        setState(() {
          _startups = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _carregando = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar startups: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<Map<String, dynamic>> get _startupsFiltradas {
    if (_busca.isEmpty) return _startups;
    return _startups
        .where(
          (s) =>
              s['nome'].toString().toLowerCase().contains(_busca.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                'Balcão de Tokens',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _busca = v),
                decoration: InputDecoration(
                  hintText: 'Buscar startup...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: _startupsFiltradas.length,
                  itemBuilder: (context, index) {
                    final startup = _startupsFiltradas[index];
                    return _StartupCard(
                      startup: startup,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BalcaoStartupPage(startup: startup),
                          ),
                        );
                        // Recarrega ao voltar para refletir mudanças
                        carregarStartups();
                      },
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

class _StartupCard extends StatelessWidget {
  final Map<String, dynamic> startup;
  final VoidCallback onTap;

  const _StartupCard({required this.startup, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  startup['imagem'] ?? 'https://picsum.photos/300/200',
                  width: 62,
                  height: 62,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startup['nome'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${_formatarReal(startup['valorToken'] ?? 0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatarReal(num valor) {
    final texto = valor.toStringAsFixed(2);
    final partes = texto.split('.');
    final formatada = partes[0].replaceAll(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      '.',
    );
    return '$formatada,${partes[1]}';
  }

  static String _formatarMilhar(num valor) {
    return valor
        .toStringAsFixed(0)
        .replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}
