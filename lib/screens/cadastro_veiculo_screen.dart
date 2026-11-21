import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../services/brasil_api_service.dart';
import '../services/storage_service.dart';

class CadastroVeiculoScreen extends StatefulWidget {
  const CadastroVeiculoScreen({super.key});

  @override
  State<CadastroVeiculoScreen> createState() => _CadastroVeiculoScreenState();
}

class _CadastroVeiculoScreenState extends State<CadastroVeiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = BrasilApiService();
  final _storageService = StorageService();

  final _anoController = TextEditingController();
  final _cilindradaController = TextEditingController();

  List<MarcaFipe> _marcas = [];
  List<String> _modelos = [];

  MarcaFipe? _marcaSelecionada;
  String? _modeloSelecionado;

  bool _carregandoMarcas = true;
  bool _carregandoModelos = false;
  String? _erroApi;

  @override
  void initState() {
    super.initState();
    _carregarMarcas();
  }

  @override
  void dispose() {
    _anoController.dispose();
    _cilindradaController.dispose();
    super.dispose();
  }

  Future<void> _carregarMarcas() async {
    setState(() {
      _carregandoMarcas = true;
      _erroApi = null;
    });
    try {
      final marcas = await _apiService.listarMarcas();
      setState(() {
        _marcas = marcas;
        _carregandoMarcas = false;
      });
    } catch (e) {
      setState(() {
        _erroApi = 'Erro ao consultar marcas na BrasilAPI. Verifique a internet.';
        _carregandoMarcas = false;
      });
    }
  }

  Future<void> _carregarModelos(String codigoMarca) async {
    setState(() {
      _carregandoModelos = true;
      _modelos = [];
      _modeloSelecionado = null;
      _erroApi = null;
    });
    try {
      final modelos = await _apiService.listarModelosPorMarca(codigoMarca);
      setState(() {
        _modelos = modelos;
        _carregandoModelos = false;
      });
    } catch (e) {
      setState(() {
        _erroApi = 'Erro ao consultar modelos da marca selecionada.';
        _carregandoModelos = false;
      });
    }
  }

  Future<void> _salvarVeiculo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_marcaSelecionada == null || _modeloSelecionado == null) return;

    final veiculo = Veiculo(
      marca: _marcaSelecionada!.nome,
      codigoMarca: _marcaSelecionada!.valor,
      modelo: _modeloSelecionado!,
      ano: int.parse(_anoController.text.trim()),
      cilindrada: _cilindradaController.text.trim(),
    );

    await _storageService.salvarVeiculo(veiculo);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Veículo'),
      ),
      body: _carregandoMarcas
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_erroApi != null) ...[
                Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_erroApi!)),
                        TextButton(
                          onPressed: _carregarMarcas,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<MarcaFipe>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Marca (BrasilAPI)',
                  border: OutlineInputBorder(),
                ),
                initialValue: _marcaSelecionada,
                items: _marcas
                    .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.nome, overflow: TextOverflow.ellipsis),
                ))
                    .toList(),
                onChanged: (novaMarca) {
                  setState(() {
                    _marcaSelecionada = novaMarca;
                  });
                  if (novaMarca != null) {
                    _carregarModelos(novaMarca.valor);
                  }
                },
                validator: (value) =>
                value == null ? 'Selecione uma marca' : null,
              ),
              const SizedBox(height: 16),
              if (_carregandoModelos)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Modelo (BrasilAPI)',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _modeloSelecionado,
                  items: _modelos
                      .map((modelo) => DropdownMenuItem(
                    value: modelo,
                    child: Text(
                      modelo,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
                      .toList(),
                  onChanged: _modelos.isEmpty
                      ? null
                      : (novoModelo) {
                    setState(() {
                      _modeloSelecionado = novoModelo;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Selecione um modelo' : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _anoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ano do Veículo (ex: 2020)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o ano';
                  }
                  final ano = int.tryParse(value.trim());
                  if (ano == null || ano < 1900 || ano > 2027) {
                    return 'Informe um ano válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cilindradaController,
                decoration: const InputDecoration(
                  labelText: 'Cilindrada do Motor (ex: 1.0, 1.8, 2.0)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty
                    ? 'Informe a cilindrada do motor'
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvarVeiculo,
                icon: const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Salvar Veículo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}