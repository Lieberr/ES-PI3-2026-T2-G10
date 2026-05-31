// Feito por Leonardo Dionel RA: 25010092
// Feito por Gustavo Lieb Ra: 24023376

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
  List<dynamic> _pontos = [];

  @override
  void initState() {
    super.initState();
    carregarPortfolio();
  }



  List<dynamic> get _pontosDoFiltro {
    if (_pontos.isEmpty) return [];

    final agora = DateTime.now();
    DateTime inicio;

    switch (_filtro) {
      case TimeFilter.daily:
        inicio = DateTime(agora.year, agora.month, agora.day);
        break;
      case TimeFilter.weekly:
        inicio = agora.subtract(const Duration(days: 7));
        break;
      case TimeFilter.monthly:
        inicio = DateTime(agora.year, agora.month - 1, agora.day);
        break;
      case TimeFilter.sixMonths:
        inicio = DateTime(agora.year, agora.month - 6, agora.day);
        break;
      case TimeFilter.ytd:
        inicio = DateTime(agora.year, 1, 1);
        break;
    }

     return _pontos.where((p) {
    final partes = (p['label'] as String).split('/');
    final dia = int.tryParse(partes[0]) ?? 0;
    final mes = int.tryParse(partes[1]) ?? 0;
    final data = DateTime(agora.year, mes, dia);
    return data.isAfter(inicio) || data.isAtSameMomentAs(inicio);
  }).toList();
  }

  Future<void> carregarPortfolio() async {
    try {
      final callable = _functions.httpsCallable('getPortfolio');
      final result = await callable.call();

      //Buscar historico
      final historicoCallable = _functions.httpsCallable('getHistoricoSaldo');
      final historicoresult = await historicoCallable.call();
      final pontos = historicoresult.data['pontos'] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _resumo = Map<String, dynamic>.from(result.data['resumo'] ?? {});
          _itens = List<Map<String, dynamic>>.from(
            (result.data['itens'] ?? []).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          );
          _pontos = pontos;
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
    final pontosDoFiltro = _pontosDoFiltro;

    if (pontosDoFiltro.length < 2) {
      return const Center(
        child: Text(
          'Faça depósitos ou saques para ver o gráfico.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final labels = _labelsEixoX();
    final totalLabels = labels.length;

    final spots = List.generate(
      pontosDoFiltro.length,
      (i) => FlSpot(
        (i / (pontosDoFiltro.length - 1)) * (totalLabels - 1),
        (pontosDoFiltro[i]['saldo'] as num).toDouble(),
      )
    );

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2;

    return LineChart(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: _calcularIntevalor(maxY),
              getTitlesWidget: (value, meta) {
                if(value == meta.max) return const SizedBox();
                
                String label;
                if (value >= 1000) {
                  final k = value / 1000;
                  label = k == k.roundToDouble() ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
                } else {
                  label = 'R\$ ${value.toInt()}';
                }
                return Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              }
            )
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {

                final labels = _labelsEixoX();
                final index = value.toInt();

                if (index < 0 || index >= labels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[index],
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.15)
            )
          )
        ]
      )
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


  static String _formatarReal(num valor) {
    final texto = valor.toStringAsFixed(2);
    final partes = texto.split('.');
    final formatada = partes[0].replaceAll(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      '.',
    );
    return '$formatada,${partes[1]}';
  }

  List<String> _labelsEixoX() {
    switch(_filtro) {
      case TimeFilter.daily:
        return ['00h', '03h', '06h', '09h', '12h', '15h', '18h', '21h', '24h'];
      case TimeFilter.weekly:
        return ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
      case TimeFilter.monthly:
        return ['S1', 'S2', 'S3', 'S4'];
      case TimeFilter.sixMonths:
        final agora = DateTime.now();
        return List.generate(6, (i) {
          final mes = DateTime(agora.year, agora.month - 5 + i);
          const nomes = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
          return nomes[mes.month - 1];
        });
      case TimeFilter.ytd:
        final agora = DateTime.now();
        return List.generate(agora.month, (i) {
          const nomes = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
          return nomes[i];
        });
    }
  }

  double _calcularIntevalor(double maxY) {
  if (maxY <= 50) return 10;
  if (maxY <= 100) return 20;
  if (maxY <= 500) return 100;
  if (maxY <= 1000) return 200;
  if (maxY <= 2000) return 500;
  if (maxY <= 5000) return 1000;
  if (maxY <= 10000) return 2000;
  if (maxY <= 50000) return 10000;
  return 20000;
  }
}
