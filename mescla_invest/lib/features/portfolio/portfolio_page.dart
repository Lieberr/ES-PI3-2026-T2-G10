// Feito por Leonardo Dionel RA: 25010092

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fl_chart/fl_chart.dart';

enum TimeFilter { daily, weekly, monthly, sixMonths, ytd }

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  TimeFilter _filtro = TimeFilter.monthly;
  Map<String, dynamic> _resumo = {};
  List<Map<String, dynamic>> _itens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    carregarPortfolio();
  }

  Future<void> carregarPortfolio() async {
    try {
      final callable = _functions.httpsCallable('getPortfolio');
      final result = await callable.call();

      if (mounted) {
        setState(() {
          _resumo = Map<String, dynamic>.from(result.data['resumo'] ?? {});
          _itens = List<Map<String, dynamic>>.from(
            (result.data['itens'] ?? []).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          );
          _carregando = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('ERRO getPortfolio: ${e.code} | ${e.message}');
      if (mounted) setState(() => _carregando = false);
    } catch (e) {
      debugPrint('ERRO GENERICO: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAtual = (_resumo['totalAtual'] as num?)?.toDouble() ?? 0;
    final totalInvestido = (_resumo['totalInvestido'] as num?)?.toDouble() ?? 0;
    final variacaoGeral = (_resumo['variacaoGeral'] as num?)?.toDouble() ?? 0;
    final lucro = totalAtual - totalInvestido;
    final positivo = variacaoGeral >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Meu Portfólio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarPortfolio,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // RESUMO GERAL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Valor Total do Portfólio',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'R\$ ${_formatarReal(totalAtual)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: positivo
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${positivo ? '+' : ''}R\$ ${_formatarReal(lucro)} (${variacaoGeral.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                color: positivo ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _infoCard(
                                  title: 'Investido',
                                  value: 'R\$ ${_formatarReal(totalInvestido)}',
                                  icon: Icons.wallet,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _infoCard(
                                  title: 'Ativos',
                                  value: '${_itens.length} startups',
                                  icon: Icons.pie_chart_outline,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // GRÁFICO — filtros visuais, dados mockados por período
                    // (substitua por getHistoricoToken quando integrar)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Distribuição do Portfólio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: TimeFilter.values.map((f) {
                              final sel = f == _filtro;
                              return GestureDetector(
                                onTap: () => setState(() => _filtro = f),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? Colors.blue
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _filtroLabel(f),
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
                          const SizedBox(height: 24),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.1),
                                  Colors.blue.withOpacity(0.02),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildChart(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LISTA DE INVESTIMENTOS REAIS
                    const Text(
                      'Meus Investimentos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (_itens.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Você ainda não possui investimentos.',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                      )
                    else
                      ..._itens.map((item) => _investmentCard(item)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _investmentCard(Map<String, dynamic> item) {
    final nome = item['nomeStartup'] ?? '';
    final quantidade = item['quantidade'] ?? 0;
    final valorInvestido = (item['valorInvestido'] as num?)?.toDouble() ?? 0;
    final valorAtual = (item['valorAtual'] as num?)?.toDouble() ?? 0;
    final variacao = (item['variacao'] as num?)?.toDouble() ?? 0;
    final precoMedio = (item['precoMedio'] as num?)?.toDouble() ?? 0;
    final precoAtual = (item['precoAtual'] as num?)?.toDouble() ?? 0;
    final positivo = variacao >= 0;
    final lucro = valorAtual - valorInvestido;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                  '${positivo ? '+' : ''}${variacao.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: positivo ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$quantidade tokens',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniInfo('Preço médio', 'R\$ ${_formatarReal(precoMedio)}'),
              _miniInfo('Preço atual', 'R\$ ${_formatarReal(precoAtual)}'),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Investido: R\$ ${_formatarReal(valorInvestido)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${positivo ? '+' : ''}R\$ ${_formatarReal(lucro)}',
                style: TextStyle(
                  color: positivo ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final data = _getChartData(_filtro);
    final market = _getMarketData(_filtro);

    return LineChart(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      LineChartData(
        minY: 0,
        maxY: 12,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final labels = _bottomLabels();
                if (value.toInt() >= labels.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[value.toInt()],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 42,
              getTitlesWidget: (value, meta) => Text(
                'R\$ ${value.toInt()}k',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i]),
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.15),
            ),
          ),
          LineChartBarData(
            spots: List.generate(
              market.length,
              (i) => FlSpot(i.toDouble(), market[i]),
            ),
            isCurved: true,
            color: Colors.grey,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  String _filtroLabel(TimeFilter f) {
    switch (f) {
      case TimeFilter.daily:
        return 'Dia';
      case TimeFilter.weekly:
        return 'Semana';
      case TimeFilter.monthly:
        return 'Mes';
      case TimeFilter.sixMonths:
        return '6M';
      case TimeFilter.ytd:
        return 'YTD';
    }
  }

  List<String> _bottomLabels() {
    switch (_filtro) {
      case TimeFilter.daily:
        return ['09h', '11h', '13h', '15h', '18h'];
      case TimeFilter.weekly:
        return ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
      case TimeFilter.monthly:
        return ['S1', 'S2', 'S3', 'S4'];
      case TimeFilter.sixMonths:
        return ['Jan', 'Fev', 'Mar', 'Abr', 'Mai'];
      case TimeFilter.ytd:
        return ['Jan', 'Mar', 'Mai', 'Jul', 'Set'];
    }
  }

  List<double> _getChartData(TimeFilter f) {
    switch (f) {
      case TimeFilter.daily:
        return [9.8, 9.9, 10.0, 10.1, 10.25];
      case TimeFilter.weekly:
        return [9.5, 9.8, 9.7, 10.0, 10.25];
      case TimeFilter.monthly:
        return [8.5, 9.0, 9.8, 10.25];
      case TimeFilter.sixMonths:
        return [7.0, 7.8, 8.5, 9.0, 10.25];
      case TimeFilter.ytd:
        return [6.0, 7.0, 8.0, 9.5, 10.25];
    }
  }

  List<double> _getMarketData(TimeFilter f) {
    switch (f) {
      case TimeFilter.daily:
        return [9.5, 9.7, 9.8, 9.9, 10.0];
      case TimeFilter.weekly:
        return [9.2, 9.4, 9.5, 9.7, 9.9];
      case TimeFilter.monthly:
        return [8.0, 8.4, 8.8, 9.2];
      case TimeFilter.sixMonths:
        return [6.5, 7.0, 7.5, 8.0, 9.0];
      case TimeFilter.ytd:
        return [5.5, 6.5, 7.2, 8.5, 9.3];
    }
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
}
