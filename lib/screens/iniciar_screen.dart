import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class IniciarScreen extends StatelessWidget {
  const IniciarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false, // Disable top padding to remove the white line
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView( // Allow scrolling when the keyboard appears
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus(); // Dismiss the keyboard when tapping outside
                    },
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45, // Increase height to push the image up
                              child: ClipPath(
                                clipper: ArcClipper(),
                                child: Container(
                                  color: const Color(0xFFF2F1F6),
                                  width: double.infinity,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        top: -50, // Move the image further up
                                        child: Image.asset(
                                          'assets/images/iglesia.jpg',
                                          fit: BoxFit.cover,
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height * 0.5,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          color: const Color(0xFFF2F1F6).withOpacity(0.8),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          'assets/images/facalert_logo.png',
                                          width: 300,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40), // Increased spacing above the text
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Text(
                                  'Inicia sesión para continuar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontFamily: 'Verdana',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30), // Increased spacing above the first text field
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: CustomTextField(
                                label: 'Correo Electrónico',
                                controller: TextEditingController(),
                                icon: Icons.email,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El correo es obligatorio.';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Ingrese un correo válido.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20), // Increased spacing between text fields
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: CustomTextField(
                                label: 'Contraseña',
                                controller: TextEditingController(),
                                icon: Icons.lock,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'La contraseña es obligatoria.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 30), // Increased spacing above the button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: CustomButton(
                                text: 'Iniciar Sesión',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/'); // Navigate to MainScreen
                                },
                              ),
                            ),
                            const SizedBox(height: 30), // Increased spacing above the link
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/registro');
                              },
                              child: const Text(
                                '¿No tienes cuenta? Crea una aquí',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 2, 76, 13),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30), // Increased spacing below the link
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30); // Lower the arc by reducing the height offset
    path.quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 30); // Adjust the curve
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
