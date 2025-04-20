import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
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

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      final password = _controllers['password']!.text.trim();
      final confirmPassword = _controllers['confirmPassword']!.text.trim();

      if (password != confirmPassword) {
        _showMessage('Las contraseñas no coinciden.');
        return;
      }

      _showMessage('Cuenta creada exitosamente.', success: true);

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showMessage(String message, {bool success = false}) {
    final color = success ? Colors.green : Colors.red;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
          ),
        );
      }
    });
  }

  List<Widget> _buildFormFields() {
    return [
      CustomTextField(
        controller: _controllers['nombre']!,
        label: 'Nombre',
        icon: Icons.person,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El nombre es obligatorio.';
          }
          if (value.length < 3) {
            return 'El nombre debe tener al menos 3 caracteres.';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _controllers['cedula']!,
        label: 'Cédula',
        icon: Icons.badge,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'La cédula es obligatoria.';
          }
          if (!RegExp(r'^\d+$').hasMatch(value)) {
            return 'La cédula debe contener solo números.';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _controllers['telefono']!,
        label: 'Teléfono',
        icon: Icons.phone,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El teléfono es obligatorio.';
          }
          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
            return 'El teléfono debe tener 10 dígitos.';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _controllers['direccion']!,
        label: 'Dirección',
        icon: Icons.home,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'La dirección es obligatoria.';
          }
          if (!RegExp(r'^[a-zA-Z0-9\s,.-]+$').hasMatch(value)) {
            return 'Ingrese una dirección válida.';
          }
          if (value.length < 5) {
            return 'La dirección debe tener al menos 5 caracteres.';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _controllers['email']!,
        label: 'Correo Electrónico',
        icon: Icons.email,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El correo electrónico es obligatorio.';
          }
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Ingrese un correo electrónico válido.';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _controllers['password']!,
        label: 'Contraseña',
        icon: Icons.lock,
        isPassword: true, // Always obscure the password
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'La contraseña es obligatoria.';
          }
          if (value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres.';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _controllers['confirmPassword']!,
        label: 'Confirmar Contraseña',
        icon: Icons.lock_outline,
        isPassword: true, // Always obscure the password
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Debe confirmar la contraseña.';
          }
          return null;
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Prevent content from overlapping system UI
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height, // Ensure full screen height
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F1F6).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Verdana',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Por favor, completa los campos para registrarte.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontFamily: 'Verdana',
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ..._buildFormFields(),
                            const SizedBox(height: 32),
                            CustomButton(
                              text: 'Crear Cuenta',
                              onPressed: _register,
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Volver',
                              onPressed: () {
                                final args = ModalRoute.of(context)?.settings.arguments as Map?;
                                if (args != null && args['from'] == 'iniciar') {
                                  Navigator.pushNamed(context, '/iniciar'); // Navigate back to iniciar sesión
                                } else {
                                  Navigator.pushNamed(context, '/inicio'); // Default to inicio
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}