import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/abastecimento.dart';
import '../services/storage_service.dart';

class NovoAbastecimentoScreen extends StatefulWidget {
  final double? ultimaQuilometragem;

  const NovoAbastecimentoScreen({
    super.key,
    this.ultimaQuilometragem,
  });

  @override
  State<NovoAbastecimentoScreen> createState() =>
      _NovoAbastecimentoScreenState();
}

class _NovoAbastecimentoScreenState extends State<NovoAbastecimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();

  String _tipoCombustivel = 'Gasolina';
  final _precoController = TextEditingController();
  final _kmController = TextEditingController();
  final _litrosController = TextEditingController();
  DateTime _dataHoraSelecionada = DateTime.now();

  double _valorTotalCalculado = 0.0;

  @override
  void initState() {
    super.initState();
    _precoController.addListener(_atualizarValorTotal);
    _litrosController.addListener(_atualizarValorTotal);
  }

  @override
  void dispose() {
    _precoController.dispose();
    _kmController.dispose();
    _litrosController.dispose();
    super.dispose();
  }

  double? _parseNumero(String texto) {
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  void _atualizarValorTotal() {
    final preco = _parseNumero(_precoController.text) ?? 0.0;
    final litros = _parseNumero(_litrosController.text) ?? 0.0;
    setState(() {
      _valorTotalCalculado = preco * litros;
    });
  }

  Future<void> _selecionarDataHora() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataHoraSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (data == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHoraSelecionada),
    );
    if (hora == null) return;

    setState(() {
      _dataHoraSelecionada = DateTime(
        data.year,
        data.month,
        data.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  Future<void> _salvarAbastecimento() async {
    if (!_formKey.currentState!.validate()) return;

    final novo = Abastecimento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tipoCombustivel: _tipoCombustivel,
      precoPorLitro: _parseNumero(_precoController.text)!,
      quilometragem: _parseNumero(_kmController.text)!,
      litros: _parseNumero(_litrosController.text)!,
      dataHora: _dataHoraSelecionada,
    );

    await _storageService.adicionarAbastecimento(novo);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatoData = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Abastecimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível',
                  border: OutlineInputBorder(),
                ),
                initialValue: _tipoCombustivel,
                items: const [
                  DropdownMenuItem(value: 'Gasolina', child: Text('Gasolina')),
                  DropdownMenuItem(value: 'Etanol', child: Text('Etanol')),
                  DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() => _tipoCombustivel = valor);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Preço por Litro (R\$)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = _parseNumero(value ?? '');
                  if (v == null || v <= 0) {
                    return 'Informe um preço por litro válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litrosController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantidade de Litros Abastecidos',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = _parseNumero(value ?? '');
                  if (v == null || v <= 0) {
                    return 'Informe uma quantidade de litros válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kmController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quilometragem Atual (km)',
                  helperText: widget.ultimaQuilometragem != null
                      ? 'Último registro: ${widget.ultimaQuilometragem!.toStringAsFixed(1)} km'
                      : 'Primeiro abastecimento (servirá como referência inicial)',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final km = _parseNumero(value ?? '');
                  if (km == null || km <= 0) {
                    return 'Informe a quilometragem atual';
                  }
                  if (widget.ultimaQuilometragem != null &&
                      km <= widget.ultimaQuilometragem!) {
                    return 'A quilometragem deve ser maior que ${widget.ultimaQuilometragem!.toStringAsFixed(1)} km';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data e Horário do Abastecimento'),
                subtitle: Text(formatoData.format(_dataHoraSelecionada)),
                trailing: const Icon(Icons.edit),
                onTap: _selecionarDataHora,
              ),
              const SizedBox(height: 20),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Valor Total Calculado:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        formatoMoeda.format(_valorTotalCalculado),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvarAbastecimento,
                icon: const Icon(Icons.check),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Salvar Abastecimento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}