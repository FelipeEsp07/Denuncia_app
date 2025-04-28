import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditUserScreen extends StatefulWidget {
  final Usuario usuario;
  const EditUserScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController _nombreC;
  late TextEditingController _cedulaC;
  late TextEditingController _telefonoC;
  late TextEditingController _direccionC;
  late TextEditingController _emailC;
  bool _isActive = true;
  bool _saving = false;

  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(4.8312, -74.3545);

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    _nombreC = TextEditingController(text: u.nombre);
    _cedulaC = TextEditingController(text: u.cedula);
    _telefonoC = TextEditingController(text: u.telefono);
    _direccionC = TextEditingController(text: u.direccion);
    _emailC = TextEditingController(text: u.email);

    if (u.latitud != null && u.longitud != null) {
      _currentPosition = LatLng(u.latitud!, u.longitud!);
    }
    _isActive = u.isActive;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final token = await _getToken();
      if (token == null) throw 'Sin token de sesión';
      final url = Uri.parse('${Config.apiBase}/usuarios/${widget.usuario.id}');
      final body = {
        'nombre': _nombreC.text,
        'cedula': _cedulaC.text,
        'telefono': _telefonoC.text,
        'direccion': _direccionC.text,
        'email': _emailC.text,
        'latitud': _currentPosition.latitude,
        'longitud': _currentPosition.longitude,
        'is_active': _isActive,
      };
      final res = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado exitosamente')),
        );
        Navigator.pop(context);
      } else {
        final err = jsonDecode(res.body);
        throw 'Error ${res.statusCode}: ${err['error'] ?? res.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green[700]),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Usuario', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        leading: const BackButton(color: Colors.white), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            _buildTextField(controller: _nombreC, label: 'Nombre', icon: Icons.person),
            _buildTextField(
              controller: _cedulaC,
              label: 'Cédula',
              icon: Icons.badge,
              keyboardType: TextInputType.number, // Teclado numérico
            ),
            _buildTextField(
              controller: _telefonoC,
              label: 'Teléfono',
              icon: Icons.phone,
              keyboardType: TextInputType.number, // Teclado numérico
            ),
            _buildTextField(controller: _direccionC, label: 'Dirección', icon: Icons.home),
            _buildTextField(controller: _emailC, label: 'Email', icon: Icons.email),
            const SizedBox(height: 20),
            const Text(
              'Ubicación en el mapa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('user_location'),
                      position: _currentPosition,
                      draggable: true,
                      onDragEnd: (LatLng newPosition) {
                        setState(() {
                          _currentPosition = newPosition;
                        });
                      },
                    ),
                  },
                  onTap: (LatLng newPosition) {
                    setState(() {
                      _currentPosition = newPosition;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Activo', style: TextStyle(fontSize: 16)),
              value: _isActive,
              activeColor: Colors.green,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 20),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Guardar cambios', style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green[700],
                        elevation: 5,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
