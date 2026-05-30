//Feito por Gustavo Lieb RA: 24023376


import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';

enum TimeFilter {
  daily,
  weekly,
  monthly,
  sixMonths,
  ytd,
}

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}



class _PortfolioPageState extends State<PortfolioPage> {
  
  TimeFilter selectedFilter = TimeFilter.monthly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),

      appBar: AppBar(
        title: const Text(
          "Meu Portfólio",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // RESUMO
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
                    "Valor Total do Portfólio",
                    style: TextStyle(color: Color.fromARGB(255, 88, 88, 88)),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "R\$ 10.250,00",
                    style: TextStyle(
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
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "+ R\$ 450,00 (4.59%)",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          title: "Investido",
                          value: "R\$ 9.800,00",
                          icon: Icons.wallet,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _infoCard(
                          title: "Disponivel",
                          value: "R\$ 10.000,00",
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),

                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            //Grafico
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      "Distribuição do Portfólio",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //Filtros
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: TimeFilter.values.map((filter) {

                      final isSelected = filter == selectedFilter;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12)
                          ),

                          child: Text(
                            _filterLabel(filter),

                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
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

            //investimentos
            const Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                "Meus Investimentos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

             _investmentCard(
              name: "EcoTech Solutions",
              tokens: "500 tokens",
              investedDate: "Investido em 12/02/2025",
              investedValue: "R\$ 5.250,00",
              profit: "+ R\$ 250,00",
              profitColor: Colors.green,
            ),

            _investmentCard(
              name: "Green Energy AI",
              tokens: "320 tokens",
              investedDate: "Investido em 20/03/2025",
              investedValue: "R\$ 3.200,00",
              profit: "+ R\$ 120,00",
              profitColor: Colors.green,
            ),

            _investmentCard(
              name: "Future Logistics",
              tokens: "180 tokens",
              investedDate: "Investido em 05/04/2025",
              investedValue: "R\$ 1.350,00",
              profit: "- R\$ 30,00",
              profitColor: Colors.red,
            ),

          ],
        ),
      ),
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
        // ICON + TEXTO
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

        // VALOR EMBAIXO
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}

  Widget _investmentCard({
    required String name,
    required String tokens,
    required String investedDate,
    required String investedValue,
    required String profit,
    required Color profitColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            tokens,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Text(
            investedDate,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                investedValue,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                profit,
                style: TextStyle(
                  color: profitColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildChart() {
    final data = _getChartData(selectedFilter);
    final marketData = _getMarketData(selectedFilter);

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

        borderData: FlBorderData(
          show: false,
        ),

        titlesData: FlTitlesData(

          //TOPO
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          //Direita
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          //EIXO X
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),


          //EIXO Y

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 42,

              getTitlesWidget: (value, meta) {
                return Text(
                  "R\$ ${value.toInt()}k",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),

        lineBarsData: [

            // SUA CARTEIRA
            LineChartBarData(
              spots: List.generate(
                data.length,
                (i) => FlSpot(i.toDouble(), data[i]),
              ),

              isCurved: true,
              color: Colors.blue,
              barWidth: 4,

              dotData: FlDotData(
                show: true,
              ),

              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.15),
              ),
            ),

            // MERCADO
            LineChartBarData(
              spots: List.generate(
                marketData.length,
                (i) => FlSpot(i.toDouble(), marketData[i]),
              ),

              isCurved: true,
              color: Colors.grey,
              barWidth: 3,

              dotData: FlDotData(
                show: false,
              ),
            ),
          ],
      ),
    );
  }

  List<String> _bottomLabels() {
  switch (selectedFilter) {

    case TimeFilter.daily:
      return ["09h", "11h", "13h", "15h", "18h"];

    case TimeFilter.weekly:
      return ["Seg", "Ter", "Qua", "Qui", "Sex"];

    case TimeFilter.monthly:
      return ["S1", "S2", "S3", "S4"];

    case TimeFilter.sixMonths:
      return ["Jan", "Fev", "Mar", "Abr", "Mai"];

    case TimeFilter.ytd:
      return ["Jan", "Mar", "Mai", "Jul", "Set"];
  }
}

  String _filterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
      return "Dia";

      case TimeFilter.weekly:
      return "Semana";

      case TimeFilter.monthly:
      return "Mes";

      case TimeFilter.sixMonths:
      return "6M";

      case TimeFilter.ytd:
      return "YTD";
    }
  }

  List<double> _getChartData(TimeFilter filter) {
  switch (filter) {
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

List<double> _getMarketData(TimeFilter filter) {
  switch (filter) {
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
}
