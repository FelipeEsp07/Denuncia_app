import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  late final String apiBaseUrl;

  @override
  void initState() {
    super.initState();
    apiBaseUrl = Config.apiBase;
    _fetchProfile();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    final response = await http.get(
      Uri.parse('$apiBaseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final usuario = data['usuario'] as Map<String, dynamic>;
      _nombreController.text = usuario['nombre'] ?? '';
      _correoController.text = usuario['email'] ?? '';
      _telefonoController.text = usuario['telefono'] ?? '';
      _direccionController.text = usuario['direccion'] ?? '';
      _cedulaController.text = usuario['cedula'] ?? '';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfil: ${response.reasonPhrase}')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    final body = json.encode({
      'nombre': _nombreController.text.trim(),
      'email': _correoController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'direccion': _direccionController.text.trim(),
      'cedula': _cedulaController.text.trim(),
    });

    final response = await http.put(
      Uri.parse('$apiBaseUrl/profile/edit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      await prefs.setString('user_nombre', _nombreController.text.trim());
      await prefs.setString('user_email', _correoController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar perfil: ${response.reasonPhrase}')),
      );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese su nombre' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.isEmpty ? 'Ingrese su correo' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Guardando...' : 'Guardar Cambios',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), 
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32), 
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
                    padding: const EdgeInsets.symmetric(vertical: 16), 
                    elevation: 5, 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
