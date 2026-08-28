import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'abastecimento.dart';

class GerenciarAbastecimentos {
  static const String chave = 'abastecimentos';

  Future<List<Abastecimento>> listar() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(chave);

    if (dados == null) {
      return [];
    }

    final lista = jsonDecode(dados) as List;

    return lista.map((item) => Abastecimento.fromMap(item)).toList();
  }

  Future<void> adicionar(Abastecimento abastecimento) async {
    final lista = await listar();

    lista.add(abastecimento);

    await _salvar(lista);
  }

  Future<void> atualizar(int indice, Abastecimento abastecimento) async {
    final lista = await listar();

    lista[indice] = abastecimento;

    await _salvar(lista);
  }

  Future<void> excluir(int indice) async {
    final lista = await listar();

    lista.removeAt(indice);

    await _salvar(lista);
  }

  Future<void> _salvar(List<Abastecimento> lista) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = jsonEncode(lista.map((item) => item.toMap()).toList());

    await prefs.setString(chave, dados);
  }
}
