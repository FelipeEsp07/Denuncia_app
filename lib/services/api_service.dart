import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/denuncia.dart';

class ApiService {
  static Future<List<Denuncia>> fetchDenuncias() async {
    final uri = Uri.parse('${Config.apiBase}/denuncias/');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((j) => Denuncia.fromJson(j)).toList();
    } else {
      throw Exception('Error al cargar denuncias: ${response.statusCode}');
    }
  }

  static Future<Denuncia> createDenuncia(Denuncia d) async {
    final uri = Uri.parse('${Config.apiBase}/denuncias/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(d.toJson()),
    );
    if (response.statusCode == 201) {
      return Denuncia.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear denuncia: ${response.statusCode}');
    }
  }
}
