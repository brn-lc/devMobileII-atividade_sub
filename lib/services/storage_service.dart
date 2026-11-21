import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';

class StorageService {
  static const String _veiculoKey = 'veiculo_cadastrado';
  static const String _abastecimentosKey = 'lista_abastecimentos';

  Future<void> salvarVeiculo(Veiculo veiculo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_veiculoKey, jsonEncode(veiculo.toJson()));
  }

  Future<Veiculo?> obterVeiculo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_veiculoKey);
    if (jsonStr == null) return null;
    return Veiculo.fromJson(jsonDecode(jsonStr));
  }

  // Exclui o veículo atual e remove todos os abastecimentos associados
  Future<void> excluirVeiculoEAbastecimentos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_veiculoKey);
    await prefs.remove(_abastecimentosKey);
  }

  Future<List<Abastecimento>> obterAbastecimentos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_abastecimentosKey);
    if (jsonStr == null) return [];

    final List<dynamic> lista = jsonDecode(jsonStr);
    final abastecimentos =
    lista.map((item) => Abastecimento.fromJson(item)).toList();

    // Garante ordenação crescente por quilometragem
    abastecimentos.sort((a, b) => a.quilometragem.compareTo(b.quilometragem));
    return abastecimentos;
  }

  Future<void> adicionarAbastecimento(Abastecimento novo) async {
    final abastecimentos = await obterAbastecimentos();
    abastecimentos.add(novo);
    abastecimentos.sort((a, b) => a.quilometragem.compareTo(b.quilometragem));

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(abastecimentos.map((e) => e.toJson()).toList());
    await prefs.setString(_abastecimentosKey, jsonStr);
  }
}