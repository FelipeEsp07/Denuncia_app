import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../config.dart';

class IniciarScreen extends StatefulWidget {
  const IniciarScreen({super.key});

  @override
  State<IniciarScreen> createState() => _IniciarScreenState();
}

class _IniciarScreenState extends State<IniciarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final Dio _dio = Dio(BaseOptions(baseUrl: Config.apiBase));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTokenIntoDio();
  }

  Future<void> _loadTokenIntoDio() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final resp = await _dio.post(
        '/login',
        data: {
          'email': _emailCtl.text.trim(),
          'password': _passCtl.text,
        },
      );

      final token = resp.data['token'] as String?;
      final userJson = resp.data['usuario'] as Map<String, dynamic>;

      if (token == null) {
        _showError('No se recibió token de autenticación.');
        return;
      }

      // Guardar token y datos de usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await prefs.setString('user_nombre', userJson['nombre'] as String);
      await prefs.setString('user_email', userJson['email'] as String);

      final rol = userJson['rol'] as String?;
      if (rol != null && rol.isNotEmpty) {
        await prefs.setString('user_rol', rol.toLowerCase()); 
      } else {
        await prefs.setString('user_rol', 'usuario');
      }

      final lat = userJson['latitud'] as num?;
      final lng = userJson['longitud'] as num?;
      if (lat != null && lng != null) {
        await prefs.setDouble('user_latitud', lat.toDouble());
        await prefs.setDouble('user_longitud', lng.toDouble());
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido, ${userJson['nombre']}!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/main');
      
    } on DioError catch (e) {
      String msg = 'Error de conexión, inténtalo más tarde.';
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        msg = (e.response!.data as Map<String, dynamic>)['error'] 
              as String? ?? msg;
      }
      _showError(msg);

    } catch (_) {
      _showError('Error inesperado.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'El correo es obligatorio.';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Correo inválido.';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña es obligatoria.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: ClipPath(
                        clipper: ArcClipper(),
                        child: Container(
                          color: const Color(0xFFF2F1F6),
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: -50,
                                child: Image.asset(
                                  'assets/images/iglesia.jpg',
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  color: const Color(0xFFF2F1F6).withOpacity(0.8),
                                ),
                              ),
                              Image.asset(
                                'assets/images/facalert_logo.png',
                                width: 300,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Inicia sesión para continuar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Verdana',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _emailCtl,
                              label: 'Correo Electrónico',
                              icon: Icons.email,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passCtl,
                              label: 'Contraseña',
                              icon: Icons.lock,
                              isPassword: true,
                              validator: _validatePassword,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/registro'),
                      child: const Text(
                        '¿No tienes cuenta? Crea una aquí',
                        style: TextStyle(
                          color: Color.fromARGB(255, 2, 76, 13),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          CustomButton(
                            text: _isLoading ? 'Ingresando…' : 'Iniciar Sesión',
                            onPressed: () {
                              if (_isLoading) return;
                              _login();
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            textColor: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                          ),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
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

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
