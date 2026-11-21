class Abastecimento {
  final String id;
  final String tipoCombustivel; // Etanol, Gasolina ou Diesel
  final double precoPorLitro;
  final double quilometragem;
  final double litros;
  final DateTime dataHora;

  Abastecimento({
    required this.id,
    required this.tipoCombustivel,
    required this.precoPorLitro,
    required this.quilometragem,
    required this.litros,
    required this.dataHora,
  });

  // Valor total = preço por litro * quantidade de litros
  double get valorTotal => precoPorLitro * litros;

  // Distância percorrida a partir do abastecimento anterior
  double? calcularDistancia(Abastecimento? anterior) {
    if (anterior == null) return null;
    final distancia = quilometragem - anterior.quilometragem;
    return distancia > 0 ? distancia : null;
  }

  // Consumo em km/L = distância percorrida / litros do abastecimento atual
  double? calcularConsumoKmL(Abastecimento? anterior) {
    final distancia = calcularDistancia(anterior);
    if (distancia == null || litros <= 0) return null;
    return distancia / litros;
  }

  // Custo em R$/km = valor total atual / distância percorrida
  double? calcularCustoPorKm(Abastecimento? anterior) {
    final distancia = calcularDistancia(anterior);
    if (distancia == null || distancia <= 0) return null;
    return valorTotal / distancia;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipoCombustivel': tipoCombustivel,
      'precoPorLitro': precoPorLitro,
      'quilometragem': quilometragem,
      'litros': litros,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory Abastecimento.fromJson(Map<String, dynamic> json) {
    return Abastecimento(
      id: json['id'] as String,
      tipoCombustivel: json['tipoCombustivel'] as String,
      precoPorLitro: (json['precoPorLitro'] as num).toDouble(),
      quilometragem: (json['quilometragem'] as num).toDouble(),
      litros: (json['litros'] as num).toDouble(),
      dataHora: DateTime.parse(json['dataHora'] as String),
    );
  }
}