import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'C.R.U.D. API',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CrudPage(),
    );
  }
}

class CrudPage extends StatefulWidget {
  const CrudPage({super.key});

  @override
  _CrudPageState createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  final _idController = TextEditingController(text: "0");
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();

  List<Map<String, dynamic>> _data = [];

  // Função para buscar dados (GET)
  Future<void> _getData() async {
  try {
    final response = await http.get(
      Uri.parse('https://b011-2804-18-159-f498-c64-3d10-5a5b-43f7.ngrok-free.app/api/testeApi.php/cliente/list'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',  // Cabeçalho para aceitar resposta JSON
      },
    );
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        _data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      throw Exception('Erro ao carregar os dados.');
    }
  } catch (e) {
    print('Erro: $e');
  }
}

  // Função para criar novo dado (POST)
  Future<void> _postData() async {
    try {
      final response = await http.post(
        Uri.parse('https://b011-2804-18-159-f498-c64-3d10-5a5b-43f7.ngrok-free.app/api/testeApi.php/cliente'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': _nomeController.text,
          'categoria': _categoriaController.text,
        }),
      );

      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Erro ao adicionar.')),
      );
      _getData();
    } catch (e) {
      print('Erro: $e');
    }
  }

  // Função para atualizar dado (PUT)
  Future<void> _updateData() async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://b011-2804-18-159-f498-c64-3d10-5a5b-43f7.ngrok-free.app/api/testeApi.php/cliente/${_idController.text}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': _nomeController.text,
          'categoria': _categoriaController.text,
        }),
      );

      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Erro ao atualizar.')),
      );
      _getData();
    } catch (e) {
      print('Erro: $e');
    }
  }

  // Função para excluir dado (DELETE)
  Future<void> _deleteData() async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://b011-2804-18-159-f498-c64-3d10-5a5b-43f7.ngrok-free.app/api/testeApi.php/cliente/${_idController.text}'),
        headers: {'Content-Type': 'application/json'},
      );

      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Erro ao excluir.')),
      );
      _getData();
    } catch (e) {
      print('Erro: $e');
    }
  }

  // Selecionar uma linha
  void _selectRow(Map<String, dynamic> item) {
    setState(() {
      _idController.text = item['id'].toString();
      _nomeController.text = item['nome'];
      _categoriaController.text = item['categoria'];
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('C.R.U.D. padrão API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Id'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoriaController,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _getData, child: const Text('GET')),
                ElevatedButton(onPressed: _postData, child: const Text('POST')),
                ElevatedButton(onPressed: _updateData, child: const Text('PUT')),
                ElevatedButton(onPressed: _deleteData, child: const Text('DELETE')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final item = _data[index];
                  return GestureDetector(
                    onTap: () => _selectRow(item),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(item['nome']),
                        subtitle: Text('Categoria: ${item['categoria']}'),
                        trailing: Text('ID: ${item['id']}'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}