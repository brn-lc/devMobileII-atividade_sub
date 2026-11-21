class Veiculo {
  final String marca;
  final String codigoMarca;
  final String modelo;
  final int ano;
  final String cilindrada;

  Veiculo({
    required this.marca,
    required this.codigoMarca,
    required this.modelo,
    required this.ano,
    required this.cilindrada,
  });

  Map<String, dynamic> toJson() {
    return {
      'marca': marca,
      'codigoMarca': codigoMarca,
      'modelo': modelo,
      'ano': ano,
      'cilindrada': cilindrada,
    };
  }

  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      marca: json['marca'] as String,
      codigoMarca: json['codigoMarca'] as String,
      modelo: json['modelo'] as String,
      ano: json['ano'] as int,
      cilindrada: json['cilindrada'] as String,
    );
  }
}