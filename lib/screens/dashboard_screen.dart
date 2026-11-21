import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/abastecimento.dart';

class DashboardScreen extends StatelessWidget {
  final List<Abastecimento> abastecimentos;

  const DashboardScreen({super.key, required this.abastecimentos});

  @override
  Widget build(BuildContext context) {
    final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatoData = DateFormat('dd/MM');

    // Pontos para os gráficos (a partir do 2º abastecimento, índice >= 1)
    final List<FlSpot> spotsConsumo = [];
    final List<FlSpot> spotsCustoKm = [];

    for (int i = 1; i < abastecimentos.length; i++) {
      final atual = abastecimentos[i];
      final anterior = abastecimentos[i - 1];
      final consumo = atual.calcularConsumoKmL(anterior);
      final custoKm = atual.calcularCustoPorKm(anterior);

      if (consumo != null) {
        spotsConsumo.add(FlSpot(i.toDouble() + 1, consumo));
      }
      if (custoKm != null) {
        spotsCustoKm.add(FlSpot(i.toDouble() + 1, custoKm));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard e Gráficos')),
      body: abastecimentos.isEmpty
          ? const Center(
              child: Text('Nenhum abastecimento registrado para exibir dados.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (abastecimentos.length < 2)
                  Card(
                    color: Colors.amber.shade100,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'O 1º abastecimento serve como referência inicial de quilometragem. '
                        'Registre pelo menos um 2º abastecimento para visualizar os gráficos de evolução de consumo (km/L) e custo (R\$/km).',
                      ),
                    ),
                  )
                else ...[
                  const Text(
                    'Evolução do Consumo (km/L)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildLineChartCard(
                    spots: spotsConsumo,
                    corLinha: Colors.green,
                    unidade: 'km/L',
                    casasDecimais: 1,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Evolução do Custo por Quilômetro (R\$/km)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildLineChartCard(
                    spots: spotsCustoKm,
                    corLinha: Colors.deepOrange,
                    unidade: 'R\$/km',
                    casasDecimais: 2,
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Indicadores por Abastecimento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(abastecimentos.length, (index) {
                  final item = abastecimentos[index];
                  final anterior = index > 0 ? abastecimentos[index - 1] : null;
                  final distancia = item.calcularDistancia(anterior);
                  final consumo = item.calcularConsumoKmL(anterior);
                  final custoKm = item.calcularCustoPorKm(anterior);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}º')),
                      title: Text(
                        '${formatoData.format(item.dataHora)} - ${item.tipoCombustivel} (${formatoMoeda.format(item.valorTotal)})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: index == 0
                          ? Text(
                              'Odômetro: ${item.quilometragem.toStringAsFixed(1)} km\n'
                              'Referência inicial (sem indicadores de km/L ou R\$/km)',
                            )
                          : Text(
                              'Distância percorrida: ${distancia?.toStringAsFixed(1)} km\n'
                              'Consumo: ${consumo?.toStringAsFixed(2)} km/L  |  '
                              'Custo: ${formatoMoeda.format(custoKm)}/km',
                            ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildLineChartCard({
    required List<FlSpot> spots,
    required Color corLinha,
    required String unidade,
    int casasDecimais = 1,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 24, 24, 16),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Text(
                          value.toStringAsFixed(casasDecimais),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Nº do Abastecimento'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          '${value.toInt()}º',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: corLinha,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: corLinha.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
