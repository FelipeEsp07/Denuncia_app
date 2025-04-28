import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../config.dart';
import '../models/registration_admin_request.dart';

class Role {
  final int id;
  final String nombre;

  Role({required this.id, required this.nombre});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}

class RegistroAdminScreen extends StatefulWidget {
  const RegistroAdminScreen({super.key});

  @override
  State<RegistroAdminScreen> createState() => _RegistroAdminScreenState();
}

class _RegistroAdminScreenState extends State<RegistroAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'nombre': TextEditingController(),
    'cedula': TextEditingController(),
    'telefono': TextEditingController(),
    'direccion': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };
  int? _selectedRoleId;
  bool _isLoading = false;
  bool _isFetchingRoles = true;
  List<Role> _roles = [];
  final Dio _dio = Dio(BaseOptions(baseUrl: Config.apiBase));

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchRoles() async {
    setState(() => _isFetchingRoles = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    try {
      final response = await _dio.get(
        '/roles',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rolesJson = data['roles'] as List<dynamic>;
        setState(() {
          _roles = rolesJson.map((e) => Role.fromJson(e)).toList();
        });
      }
    } catch (e) {
      _showMessage('Error al cargar roles: $e');
    } finally {
      setState(() => _isFetchingRoles = false);
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() != true || _isLoading) return;
    if (_selectedRoleId == null) {
      _showMessage('Debes seleccionar un rol.');
      return;
    }

    final pwd = _controllers['password']!.text.trim();
    final confirm = _controllers['confirmPassword']!.text.trim();
    if (pwd != confirm) {
      _showMessage('Las contraseñas no coinciden.');
      return;
    }

    // Construimos el request incluyendo latitud y longitud = 0.0
    final request = RegistrationAdminRequest(
      nombre: _controllers['nombre']!.text.trim(),
      cedula: _controllers['cedula']!.text.trim(),
      telefono: _controllers['telefono']!.text.trim(),
      direccion: _controllers['direccion']!.text.trim(),
      email: _controllers['email']!.text.trim(),
      password: pwd,
      rolId: _selectedRoleId!,
      latitud: 0.0,
      longitud: 0.0,
    );

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    try {
      final response = await _dio.post(
        '/usuarios',
        data: request.toJson(),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showMessage('Usuario registrado exitosamente.', success: true);
        Navigator.pop(context);
      } else {
        final msg = response.data['error'] ??
            response.data['detail'] ??
            'Error: ${response.statusCode}';
        _showMessage(msg);
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool success = false}) {
    final color = success ? Colors.green : Colors.red;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    });
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese $fieldName.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese el correo.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo válido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese la contraseña.';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Encabezado
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F1F6).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'Registrar Usuario',
                            style: TextStyle(
                                fontFamily: 'Verdana',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.15),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Formulario de registro para nuevos usuarios.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Verdana',
                                fontSize: 14,
                                letterSpacing: 0.15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Formulario
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _controllers['nombre']!,
                            label: 'Nombre',
                            icon: Icons.person,
                            validator: (v) => _validateField(v, 'el nombre'),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _controllers['cedula']!,
                            label: 'Cédula',
                            icon: Icons.badge,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                _validateField(v, 'la cédula'),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _controllers['telefono']!,
                            label: 'Teléfono',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                _validateField(v, 'el teléfono'),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _controllers['direccion']!,
                            label: 'Dirección',
                            icon: Icons.home,
                            validator: (v) =>
                                _validateField(v, 'la dirección'),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _controllers['email']!,
                            label: 'Correo Electrónico',
                            icon: Icons.email,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _controllers['password']!,
                            label: 'Contraseña',
                            icon: Icons.lock,
                            isPassword: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _controllers['confirmPassword']!,
                            label: 'Confirmar Contraseña',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 24),

                          _isFetchingRoles
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<int>(
                                  value: _selectedRoleId,
                                  hint: const Text('Seleccionar Rol'),
                                  decoration: InputDecoration(
                                    prefixIcon:
                                        const Icon(Icons.admin_panel_settings),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  items: _roles.map((role) {
                                    return DropdownMenuItem<int>(
                                      value: role.id,
                                      child: Text(role.nombre),
                                    );
                                  }).toList(),
                                  onChanged: (value) =>
                                      setState(() => _selectedRoleId = value),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Seleccione un rol.';
                                    }
                                    return null;
                                  },
                                ),
                          const SizedBox(height: 32),

                         CustomButton(
                            text: 'Crear Cuenta',
                            onPressed: () {
                              if (_isLoading) return;
                              _register();
                            },
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            textColor: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
