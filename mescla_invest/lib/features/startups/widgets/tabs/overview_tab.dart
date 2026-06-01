// Feito por Leonardo Dionel RA: 25010092

import 'package:flutter/material.dart';
import '../token_history_chart.dart';
import 'buyToken_page.dart';
import 'sellToken_page.dart';
import '/features/balcao/balcao_startup_page.dart';

class OverviewTab extends StatelessWidget {
  final Map<String, dynamic> startup;
  final bool canTradeTokens;
  final bool canAccessBalcao;

  const OverviewTab({
    super.key,
    required this.startup,
    this.canTradeTokens = true,
    this.canAccessBalcao = false,
  });

  @override
  Widget build(BuildContext context) {
    final descricao = startup['descricao'] ?? 'Descrição não disponível';
    final total = (startup['tokensEmitidos'] ?? 0) as num;
    final disponiveis = (startup['tokensDisponiveis'] ?? 0) as num;
    final percentual = total > 0 ? (disponiveis / total * 100) : 0;
    final mentores = (startup['mentores'] ?? <dynamic>[]) as List;
    final valorTokenNum = (startup['valorToken'] as num?)?.toDouble() ?? 0;
    final capitalNum = (startup['capitalAportado'] as num?) ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // gráfico de histórico
        TokenHistoryChart(
          startupId: startup['id'] ?? '',
          valorAtual: valorTokenNum,
        ),

        const SizedBox(height: 16),

        // cards de valor e capital
        Row(
          children: [
            Expanded(
              child: _infoCard(
                Icons.account_balance_wallet_outlined,
                'Valor do Token',
                'R\$ ${_formatarReal(valorTokenNum)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _infoCard(
                Icons.groups_2_outlined,
                'Capital Aportado',
                'R\$ ${_formatarReal(capitalNum)}',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // botões de compra e venda — mercado primário (todos podem)
        if (canTradeTokens) ...[
          const SizedBox(height: 28),
          const Text(
            'Negociar Tokens',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Compre ou venda tokens diretamente com a startup.',
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuyTokenPage(startup: startup),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Comprar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SellTokenPage(startup: startup),
                      ),
                    );
                  },
                  icon: const Icon(Icons.attach_money),
                  label: const Text('Vender'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(245, 73, 0, 1),
                    side: const BorderSide(
                      color: Color.fromRGBO(245, 73, 0, 1),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        const Text(
          'Sumário Executivo',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          descricao,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF4B5563),
          ),
        ),

        const SizedBox(height: 24),

        _tokenCard(total, disponiveis, percentual),

        const SizedBox(height: 20),

        _mentorCard(mentores),

        // botão do balcão — só para investidores
        if (canAccessBalcao) ...[
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BalcaoStartupPage(startup: startup),
                ),
              );
            },
            icon: const Icon(Icons.store_outlined),
            label: const Text('Acessar Balcão de Negociações'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 225, 225, 225)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tokenCard(num total, num disponiveis, num percentual) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 222, 222, 222)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tokens',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          _linhaInfo('Total de Tokens', _formatarMilhar(total)),
          const SizedBox(height: 12),
          _linhaInfo('Tokens Disponíveis', _formatarMilhar(disponiveis)),
          const SizedBox(height: 12),
          _linhaInfo(
            'Percentual Disponível',
            '${percentual.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _mentorCard(List mentores) {
    if (mentores.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 222, 222, 222)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mentores',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          ...mentores.map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F0FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF2563EB),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.toString(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mentor',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaInfo(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  static String _formatarMilhar(num valor) {
    return valor
        .toStringAsFixed(0)
        .replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }

  static String _formatarReal(num valor) {
    final texto = valor.toStringAsFixed(2);
    final partes = texto.split('.');
    final inteira = partes[0];
    final decimal = partes[1];
    final formatada = inteira.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return '$formatada,$decimal';
  }
}
