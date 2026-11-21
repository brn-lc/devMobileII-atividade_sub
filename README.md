# Controle de Gastos com Combustível

Aplicativo desenvolvido em **Flutter** para a Atividade Substitutiva da Prova 1 da disciplina de **Programação para Dispositivos Móveis II** (Fatec - Prof. Arley).

## 📱 Descrição do Aplicativo
O aplicativo permite cadastrar um veículo consultando marcas e modelos diretamente na tabela FIPE via API pública, registrar os abastecimentos realizados ao longo do tempo e acompanhar indicadores financeiros e de eficiência energética (valor gasto, consumo em km/L e custo por quilômetro em R\$/km) por meio de um dashboard interativo com gráficos de linha.

## 🚀 Instruções para Executar o Projeto

1. Clone este repositório:
   ```bash
   git clone <URL_DO_SEU_REPOSITORIO>
   cd controle_combustivel
   ```

2. Instale as dependências do projeto:
    ```bash
    git clone <URL_DO_SEU_REPOSITORIO>
    cd controle_combustivel
    ```
   
3. Execute o aplicativo (emulador Android, dispositivo físico ou Chrome):
    ```bash
    flutter run
    ```

## 🌐 API Utilizada e Bibliotecas Adotadas
- API Pública: BrasilAPI - Endpoints FIPE
  - Listagem de marcas: ```GET https://brasilapi.com.br/api/fipe/marcas/v1/carros```
  - Listagem de modelos por marca: ```GET https://brasilapi.com.br/api/fipe/veiculos/v1/carros/{codigoMarca}```

- Bibliotecas (pubspec.yaml):
  - [`http`](https://pub.dev/packages/http): Consumo da API REST da BrasilAPI.
  - [`shared_preferences`](https://pub.dev/packages/shared_preferences): Persistência local dos dados do veículo e histórico de abastecimentos no dispositivo.
  - [`fl_chart`](https://pub.dev/packages/fl_chart): Renderização dos gráficos de linha de evolução do consumo (km/L) e do custo por quilômetro (R\$/km).
  - [`intl`](https://pub.dev/packages/intl): Formatação de valores monetários (R\$) e datas (dd/MM/yyyy HH:mm).



## 📸 Capturas de Tela das Principais Funcionalidades
### Cadastro de Veículo (BrasilAPI):
<div align="center">
<img src="screenshots/cadastro_veiculo.png" alt="Cadastro de Veículo (BrasilAPI)" width="300" align="center"/>
</div>

### Tela Principal e Histórico de Abastecimentos:
<div align="center">
<img src="screenshots/historico.png" alt="Tela Principal e Histórico de Abastecimentos" width="300" />
</div>

### Registro de Abastecimento:
<div align="center">
<img src="screenshots/registro_abastecimento.png" alt="Registro de Abastecimento" width="300" />
</div>

### Dashboard e Gráficos de Evolução:
<div align="center">
<img src="screenshots/dashboard.png" alt="Dashboard e Gráficos de Evolução" width="300" />
</div>
