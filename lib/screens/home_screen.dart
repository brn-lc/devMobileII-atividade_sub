import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';
import '../services/storage_service.dart';
import 'cadastro_veiculo_screen.dart';
import 'novo_abastecimento_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = StorageService();
  Veiculo? _veiculo;
  List<Abastecimento> _abastecimentos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    final veiculo = await _storageService.obterVeiculo();
    final abastecimentos = await _storageService.obterAbastecimentos();
    setState(() {
      _veiculo = veiculo;
      _abastecimentos = abastecimentos;
      _carregando = false;
    });
  }

  Future<void> _confirmarExclusaoVeiculo() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Veículo'),
        content: const Text(
          'Tem certeza que deseja excluir o veículo atual? '
              'Todos os abastecimentos registrados para ele também serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir Tudo'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _storageService.excluirVeiculoEAbastecimentos();
      _carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatoData = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Combustível'),
        actions: [
          if (_veiculo != null)
            IconButton(
              tooltip: 'Dashboard e Gráficos',
              icon: const Icon(Icons.insights),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DashboardScreen(abastecimentos: _abastecimentos),
                  ),
                );
              },
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _veiculo == null
          ? _buildSemVeiculo()
          : _buildComVeiculo(formatoMoeda, formatoData),
      floatingActionButton: _veiculo == null
          ? null
          : FloatingActionButton.extended(
        onPressed: () async {
          final ultimaKm = _abastecimentos.isNotEmpty
              ? _abastecimentos.last.quilometragem
              : null;
          final salvou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => NovoAbastecimentoScreen(
                ultimaQuilometragem: ultimaKm,
              ),
            ),
          );
          if (salvou == true) {
            _carregarDados();
          }
        },
        icon: const Icon(Icons.local_gas_station),
        label: const Text('Novo Abastecimento'),
      ),
    );
  }

  Widget _buildSemVeiculo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum veículo cadastrado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre um veículo consultando a BrasilAPI para começar a registrar seus abastecimentos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                final cadastrou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CadastroVeiculoScreen(),
                  ),
                );
                if (cadastrou == true) {
                  _carregarDados();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Veículo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComVeiculo(NumberFormat formatoMoeda, DateFormat formatoData) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_veiculo!.marca} - ${_veiculo!.modelo}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ano: ${_veiculo!.ano}  |  Motor: ${_veiculo!.cilindrada}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Excluir veículo atual',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _confirmarExclusaoVeiculo,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DashboardScreen(abastecimentos: _abastecimentos),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Abrir Dashboard e Gráficos'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Histórico de Abastecimentos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('${_abastecimentos.length} registro(s)'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _abastecimentos.isEmpty
              ? const Center(
            child: Text('Nenhum abastecimento registrado ainda.'),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
            itemCount: _abastecimentos.length,
            itemBuilder: (context, index) {
              final item = _abastecimentos[index];
              final anterior =
              index > 0 ? _abastecimentos[index - 1] : null;
              final consumo = item.calcularConsumoKmL(anterior);
              final custoKm = item.calcularCustoPorKm(anterior);

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}º'),
                  ),
                  title: Text(
                    '${item.tipoCombustivel} • ${formatoMoeda.format(item.valorTotal)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formatoData.format(item.dataHora)} • '
                            '${item.litros.toStringAsFixed(2)} L × ${formatoMoeda.format(item.precoPorLitro)}/L • '
                            '${item.quilometragem.toStringAsFixed(1)} km',
                      ),
                      if (index == 0)
                        const Text(
                          'Referência inicial de quilometragem',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.blueGrey,
                          ),
                        )
                      else
                        Text(
                          'Consumo: ${consumo?.toStringAsFixed(2)} km/L  |  '
                              'Custo: ${formatoMoeda.format(custoKm)}/km',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.teal,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}