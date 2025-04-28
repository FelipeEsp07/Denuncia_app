import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/usuario.dart';

class GestUsuariosScreen extends StatelessWidget {
  const GestUsuariosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/gestionUsuarios/registro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Registrar Usuario', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/gestionUsuarios/lista'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Listar Usuarios', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistroUsuarioAdminScreen extends StatefulWidget {
  const RegistroUsuarioAdminScreen({Key? key}) : super(key: key);

  @override
  State<RegistroUsuarioAdminScreen> createState() => _RegistroUsuarioAdminScreenState();
}

class _RegistroUsuarioAdminScreenState extends State<RegistroUsuarioAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _latCtrl = TextEditingController(text: '0.0');
  final _lngCtrl = TextEditingController(text: '0.0');
  int? _selectedRoleId;
  bool _loadingRoles = true;
  bool _saving = false;

  List<Map<String, dynamic>> _roles = [];
  late final String apiBaseUrl;

  @override
  void initState() {
    super.initState();
    apiBaseUrl = Config.apiBase;
    _fetchRoles();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchRoles() async {
    final token = await _getToken();
    if (token == null) return;
    final res = await http.get(
      Uri.parse('$apiBaseUrl/roles'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body)['roles'] as List<dynamic>;
      setState(() {
        _roles = data.cast<Map<String, dynamic>>();
        _loadingRoles = false;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedRoleId == null) return;
    setState(() => _saving = true);
    final token = await _getToken();
    final body = json.encode({
      'nombre': _nombreCtrl.text,
      'email': _emailCtrl.text,
      'cedula': _cedulaCtrl.text,
      'telefono': _telefonoCtrl.text,
      'direccion': _direccionCtrl.text,
      'password': _passwordCtrl.text,
      'latitud': double.parse(_latCtrl.text),
      'longitud': double.parse(_lngCtrl.text),
      'rol_id': _selectedRoleId,
    });
    final res = await http.post(
      Uri.parse('$apiBaseUrl/usuarios'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: body,
    );
    if (res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario creado')));
      _formKey.currentState!.reset();
      setState(() => _selectedRoleId = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${res.body}')));
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Usuario'), backgroundColor: const Color(0xFF2E7D32)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextFormField(controller: _cedulaCtrl, decoration: const InputDecoration(labelText: 'Cédula')),
              TextFormField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
              TextFormField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
              TextFormField(controller: _passwordCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
              if (!_loadingRoles)
                DropdownButtonFormField<int>(
                  value: _selectedRoleId,
                  items: _roles.map((r) => DropdownMenuItem(value: r['id'] as int, child: Text(r['nombre'] as String))).toList(),
                  onChanged: (v) => setState(() => _selectedRoleId = v),
                  decoration: const InputDecoration(labelText: 'Rol'),
                ),
              TextFormField(controller: _latCtrl, decoration: const InputDecoration(labelText: 'Latitud')),
              TextFormField(controller: _lngCtrl, decoration: const InputDecoration(labelText: 'Longitud')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _register,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      if (token == null) throw 'Token no encontrado';
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
      if (token == null) throw 'Token no encontrado';
      final res = await http.delete(
        Uri.parse('$apiBaseUrl/usuarios/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
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
      appBar: AppBar(title: const Text('Lista de Usuarios'), backgroundColor: const Color(0xFF2E7D32)),
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