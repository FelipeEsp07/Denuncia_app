import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/usuario.dart';

class ListaUsuariosScreen extends StatefulWidget {
  const ListaUsuariosScreen({Key? key}) : super(key: key);

  @override
  State<ListaUsuariosScreen> createState() => _ListaUsuariosScreenState();
}

class _ListaUsuariosScreenState extends State<ListaUsuariosScreen> {
  bool _loading = true;
  List<Usuario> _usuarios = [];
  late final String apiBaseUrl;

  @override
  void initState() {
    super.initState();
    apiBaseUrl = Config.apiBase;
    _fetchUsers();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      if (token == null) throw 'No se encontró el token de sesión';
      final res = await http.get(
        Uri.parse('$apiBaseUrl/usuarios'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body)['usuarios'];
        setState(() {
          _usuarios = data.map((e) => Usuario.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        throw 'Error ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pude cargar usuarios: $e')),
      );
    }
  }

  Future<void> _deleteUser(int id) async {
    try {
      final token = await _getToken();
      if (token == null) throw 'No se encontró el token de sesión';
      final res = await http.delete(
        Uri.parse('$apiBaseUrl/usuarios/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
        await _fetchUsers();
      } else {
        throw 'Error ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pude eliminar usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Lista de Usuarios'), backgroundColor: const Color(0xFF2E7D32)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
              ? const Center(child: Text('No hay usuarios para mostrar.'))
              : ListView.builder(
                  itemCount: _usuarios.length,
                  itemBuilder: (context, i) {
                    final u = _usuarios[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      child: ListTile(
                        title: Text(u.nombre),
                        subtitle: Text('${u.email} • ${u.rol?.nombre ?? "Sin rol"}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // TODO: navegar a editar perfil
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(u.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
