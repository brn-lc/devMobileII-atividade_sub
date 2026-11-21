import 'dart:convert';
import 'package:http/http.dart' as http;

class MarcaFipe {
  final String nome;
  final String valor;

  MarcaFipe({required this.nome, required this.valor});

  factory MarcaFipe.fromJson(Map<String, dynamic> json) {
    return MarcaFipe(
      nome: json['nome'].toString(),
      valor: json['valor'].toString(),
    );
  }
}

class BrasilApiService {
  static const String _baseUrl = 'https://brasilapi.com.br/api/fipe';

  Future<List<MarcaFipe>> listarMarcas() async {
    final uri = Uri.parse('$_baseUrl/marcas/v1/carros');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);
      final marcas = dados.map((json) => MarcaFipe.fromJson(json)).toList();
      marcas.sort((a, b) => a.nome.compareTo(b.nome));
      return marcas;
    } else {
      throw Exception('Falha ao carregar marcas da BrasilAPI.');
    }
  }

  Future<List<String>> listarModelosPorMarca(String codigoMarca) async {
    final uri = Uri.parse('$_baseUrl/veiculos/v1/carros/$codigoMarca');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);
      final modelos = dados
          .map((item) => item['modelo'].toString())
          .toSet()
          .toList();
      modelos.sort();
      return modelos;
    } else {
      throw Exception('Falha ao carregar modelos para a marca selecionada.');
    }
  }
}