import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'abastecimento.dart';
import 'gerenciar_abastecimentos.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool modoEscuro = false;
  bool entrou = false;

  void trocarTema() {
    setState(() {
      modoEscuro = !modoEscuro;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Abastecimentos',
      themeMode: modoEscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: entrou
          ? HomePage(onTrocarTema: trocarTema)
          : SplashPage(
              onEntrar: () {
                setState(() {
                  entrou = true;
                });
              },
              onTrocarTema: trocarTema,
            ),
    );
  }
}

class SplashPage extends StatelessWidget {
  final VoidCallback onEntrar;
  final VoidCallback onTrocarTema;

  const SplashPage({
    super.key,
    required this.onEntrar,
    required this.onTrocarTema,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_gas_station, size: 100, color: Colors.red),

              const SizedBox(height: 25),

              const Text(
                'Abastece Fácil',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                'Controle seus abastecimentos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),

              const SizedBox(height: 40),

              OutlinedButton.icon(
                onPressed: onTrocarTema,
                icon: const Icon(Icons.dark_mode),
                label: const Text('Trocar tema'),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onEntrar,
                  child: const Text('ENTRAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onTrocarTema;

  const HomePage({super.key, required this.onTrocarTema});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GerenciarAbastecimentos gerenciar = GerenciarAbastecimentos();

  List<Abastecimento> abastecimentos = [];

  @override
  void initState() {
    super.initState();
    carregarAbastecimentos();
  }

  Future<void> carregarAbastecimentos() async {
    final lista = await gerenciar.listar();

    setState(() {
      abastecimentos = lista;
    });
  }

  Future<void> excluirAbastecimento(int indice) async {
    await gerenciar.excluir(indice);
    await carregarAbastecimentos();
  }

  double calcularPrecoMedio() {
    if (abastecimentos.isEmpty) {
      return 0;
    }

    double totalLitros = 0;
    double totalValor = 0;

    for (final abastecimento in abastecimentos) {
      totalLitros += abastecimento.litros;
      totalValor += abastecimento.valorPago;
    }

    if (totalLitros == 0) {
      return 0;
    }

    return totalValor / totalLitros;
  }

  double calcularConsumoMedio() {
    if (abastecimentos.length < 2) {
      return 0;
    }

    final lista = List<Abastecimento>.from(abastecimentos);

    lista.sort((a, b) => a.quilometragem.compareTo(b.quilometragem));

    double totalConsumo = 0;
    int quantidade = 0;

    for (int i = 1; i < lista.length; i++) {
      final distancia = lista[i].quilometragem - lista[i - 1].quilometragem;

      if (distancia > 0 && lista[i].litros > 0) {
        final consumo = distancia / lista[i].litros;

        totalConsumo += consumo;
        quantidade++;
      }
    }

    if (quantidade == 0) {
      return 0;
    }

    return totalConsumo / quantidade;
  }

  Future<void> abrirCadastro() async {
    final resultado = await showDialog<Abastecimento>(
      context: context,
      builder: (context) {
        return const AbastecimentoModal();
      },
    );

    if (resultado != null) {
      await gerenciar.adicionar(resultado);
      await carregarAbastecimentos();
    }
  }

  Future<void> abrirEdicao(int indice) async {
    final resultado = await showDialog<Abastecimento>(
      context: context,
      builder: (context) {
        return AbastecimentoModal(abastecimento: abastecimentos[indice]);
      },
    );

    if (resultado != null) {
      await gerenciar.atualizar(indice, resultado);
      await carregarAbastecimentos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final precoMedio = calcularPrecoMedio();
    final consumoMedio = calcularConsumoMedio();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abastecimentos'),
        actions: [
          IconButton(
            onPressed: widget.onTrocarTema,
            icon: const Icon(Icons.dark_mode),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: abrirCadastro,
        child: const Icon(Icons.add),
      ),

      body: abastecimentos.isEmpty
          ? const Center(
              child: Text(
                'Nenhum abastecimento cadastrado.',
                style: TextStyle(fontSize: 17),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.attach_money,
                                  size: 30,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Preço médio/L',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'R\$ ${precoMedio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.speed,
                                  size: 30,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Consumo médio',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${consumoMedio.toStringAsFixed(2)} km/L',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Histórico',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: abastecimentos.length,
                    itemBuilder: (context, indice) {
                      final abastecimento = abastecimentos[indice];

                      return Card(
                        child: ListTile(
                          onTap: () => abrirEdicao(indice),

                          leading: const CircleAvatar(
                            child: Icon(Icons.local_gas_station),
                          ),

                          title: Text(
                            abastecimento.combustivel,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data: ${abastecimento.data}'),
                              Text(
                                'Litros: ${abastecimento.litros.toStringAsFixed(2)} L',
                              ),
                              Text(
                                'Valor: R\$ ${abastecimento.valorPago.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Quilometragem: ${abastecimento.quilometragem.toStringAsFixed(0)} km',
                              ),
                            ],
                          ),

                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              mostrarConfirmacaoExclusao(indice);
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Comparativo dos abastecimentos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(text: 'Abastecimentos'),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Valor pago (R\$)'),
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<Abastecimento, String>(
                          dataSource: abastecimentos,
                          xValueMapper:
                              (Abastecimento abastecimento, int index) =>
                                  '${index + 1}',
                          yValueMapper: (Abastecimento abastecimento, _) =>
                              abastecimento.valorPago,
                          name: 'Valor pago',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void mostrarConfirmacaoExclusao(int indice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir abastecimento'),
          content: const Text('Deseja realmente excluir este abastecimento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await excluirAbastecimento(indice);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}

class AbastecimentoModal extends StatefulWidget {
  final Abastecimento? abastecimento;

  const AbastecimentoModal({super.key, this.abastecimento});

  @override
  State<AbastecimentoModal> createState() => _AbastecimentoModalState();
}

class _AbastecimentoModalState extends State<AbastecimentoModal> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController dataController;
  late TextEditingController litrosController;
  late TextEditingController valorController;
  late TextEditingController quilometragemController;

  String combustivel = 'Gasolina';

  @override
  void initState() {
    super.initState();

    final abastecimento = widget.abastecimento;

    dataController = TextEditingController(text: abastecimento?.data ?? '');

    litrosController = TextEditingController(
      text: abastecimento?.litros.toString() ?? '',
    );

    valorController = TextEditingController(
      text: abastecimento?.valorPago.toString() ?? '',
    );

    quilometragemController = TextEditingController(
      text: abastecimento?.quilometragem.toString() ?? '',
    );

    if (abastecimento != null) {
      combustivel = abastecimento.combustivel;
    }
  }

  @override
  void dispose() {
    dataController.dispose();
    litrosController.dispose();
    valorController.dispose();
    quilometragemController.dispose();

    super.dispose();
  }

  void salvar() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final abastecimento = Abastecimento(
      data: dataController.text,
      combustivel: combustivel,
      litros: double.parse(litrosController.text.replaceAll(',', '.')),
      valorPago: double.parse(valorController.text.replaceAll(',', '.')),
      quilometragem: double.parse(
        quilometragemController.text.replaceAll(',', '.'),
      ),
    );

    Navigator.pop(context, abastecimento);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.abastecimento != null;

    return AlertDialog(
      title: Text(editando ? 'Editar abastecimento' : 'Novo abastecimento'),

      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: dataController,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  hintText: 'Ex: 26/08/2026',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Informe a data';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: combustivel,
                decoration: const InputDecoration(
                  labelText: 'Combustível',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Gasolina', child: Text('Gasolina')),
                  DropdownMenuItem(value: 'Etanol', child: Text('Etanol')),
                  DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                  DropdownMenuItem(value: 'GNV', child: Text('GNV')),
                ],
                onChanged: (valor) {
                  setState(() {
                    combustivel = valor!;
                  });
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: litrosController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Litros',
                  suffixText: 'L',
                  border: OutlineInputBorder(),
                ),
                validator: validarNumero,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor pago',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: validarNumero,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: quilometragemController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quilometragem',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
                ),
                validator: validarNumero,
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),

        ElevatedButton(
          onPressed: salvar,
          child: Text(editando ? 'Salvar' : 'Cadastrar'),
        ),
      ],
    );
  }

  String? validarNumero(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Informe um valor';
    }

    final numero = double.tryParse(valor.replaceAll(',', '.'));

    if (numero == null || numero <= 0) {
      return 'Digite um valor válido';
    }

    return null;
  }
}
