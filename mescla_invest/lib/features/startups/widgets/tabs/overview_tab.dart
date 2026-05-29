import 'package:flutter/material.dart';

class OverviewTab extends StatelessWidget {
  final Map<String, dynamic> startup;
  const OverviewTab({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    final descricao = startup['descricao'] ?? startup['description'] ?? 'Descrição não Diponível';
    final total = (startup['tokensEmitidos'] ?? startup['tokens'] ?? 0) as num;
    final disponiveis = (startup['tokensDisponiveis'] ?? 0) as num;
    final percentual = total > 0 ? (disponiveis / total * 100) : 0;
    final mentores = (startup['mentores'] ?? startup['mentors'] ?? <dynamic>[]) as List;

    Widget sectionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 222, 222, 222), width: 1),
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tokens', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total de Tokens'),
            Text('${_formatarMilhar(total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Tokens Disponíveis'),
            Text('${_formatarMilhar(disponiveis)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Percentual Disponível'),
            Text('${percentual.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }

  Widget mentorCard() {
    return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromARGB(255, 222, 222, 222), width: 1),
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,6))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mentores', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        ...mentores.map((m) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: Color(0xFFE8F0FE), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, color: Color(0xFF2563EB), size: 28),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.toString(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Mentor', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              ]),
            ],
          ),
        )).toList(),
      ],
    ),
);
}


    return ListView(
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

                        Text(
                          descricao,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFF4B5563),
                          ),
                        ),

                        const SizedBox(height: 24),

                        sectionCard(),

                        const SizedBox(height: 20),

                        mentorCard(),
                      ],
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

