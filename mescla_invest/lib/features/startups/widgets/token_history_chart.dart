// Feito por Leonardo Dionel RA: 25010092

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fl_chart/fl_chart.dart';

class TokenHistoryChart extends StatefulWidget {
  final String startupId;
  final double valorAtual;

  const TokenHistoryChart({
    super.key,
    required this.startupId,
    required this.valorAtual,
  });

  @override
  State<TokenHistoryChart> createState() => _TokenHistoryChartState();
}

class _TokenHistoryChartState extends State<TokenHistoryChart> {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  String _periodo = 'mensal';
  Map<String, dynamic> _variacoes = {};
  List<Map<String, dynamic>> _historico = [];
  bool _carregando = true;

  final _periodos = [
    {'label': 'Dia', 'value': 'diario'},
    {'label': 'Semana', 'value': 'semanal'},
    {'label': 'Mês', 'value': 'mensal'},
    {'label': '6M', 'value': 'seisMeses'},
    {'label': 'YTD', 'value': 'ytd'},
  ];

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    try {
      final callable = _functions.httpsCallable('getHistoricoToken');
      final result = await callable.call({'startupId': widget.startupId});

      if (mounted) {
        setState(() {
          _variacoes = Map<String, dynamic>.from(
            result.data['variacoes'] ?? {},
          );
          _historico = List<Map<String, dynamic>>.from(
            (result.data['historicoGrafico'] ?? []).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          );
          _carregando = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('ERRO getHistoricoToken: ${e.code} | ${e.message}');
      if (mounted) setState(() => _carregando = false);
    } catch (e) {
      debugPrint('ERRO GENERICO: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  // Filtra os pontos do gráfico pelo período selecionado
  List<Map<String, dynamic>> get _pontosFiltrados {
    if (_historico.isEmpty) return [];

    final agora = DateTime.now();
    DateTime inicio;

    switch (_periodo) {
      case 'diario':
        inicio = agora.subtract(const Duration(days: 1));
        break;
      case 'semanal':
        inicio = agora.subtract(const Duration(days: 7));
        break;
      case 'mensal':
        inicio = agora.subtract(const Duration(days: 30));
        break;
      case 'seisMeses':
        inicio = agora.subtract(const Duration(days: 180));
        break;
      case 'ytd':
        inicio = DateTime(agora.year, 1, 1);
        break;
      default:
        inicio = agora.subtract(const Duration(days: 30));
    }

    return _historico.where((p) {
      final data = DateTime.tryParse(p['data'] ?? '');
      return data != null && data.isAfter(inicio);
    }).toList();
  }

  double get _variacaoPeriodo {
    final v = _variacoes[_periodo];
    return (v as num?)?.toDouble() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final positivo = _variacaoPeriodo >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÍTULO + VARIAÇÃO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Histórico do Token',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (!_carregando)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: positivo
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${positivo ? '+' : ''}${_variacaoPeriodo.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: positivo ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // FILTROS DE PERÍODO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _periodos.map((p) {
              final sel = p['value'] == _periodo;
              return GestureDetector(
                onTap: () => setState(() => _periodo = p['value']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF2563EB) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p['label']!,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // GRÁFICO
          if (_carregando)
            const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_pontosFiltrados.isEmpty)
            const SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  'Sem dados para este período.',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            )
          else
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2563EB).withOpacity(0.1),
                    const Color(0xFF2563EB).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _buildChart(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final pontos = _pontosFiltrados;
    if (pontos.isEmpty) return const SizedBox();

    final valores = pontos
        .map((p) => (p['valorToken'] as num?)?.toDouble() ?? 0)
        .toList();

    final minY = (valores.reduce((a, b) => a < b ? a : b) * 0.95);
    final maxY = (valores.reduce((a, b) => a > b ? a : b) * 1.05);

    return LineChart(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 3,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) => Text(
                'R\$ ${value.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              valores.length,
              (i) => FlSpot(i.toDouble(), valores[i]),
            ),
            isCurved: true,
            color: const Color(0xFF2563EB),
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2563EB).withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}
