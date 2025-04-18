import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: ClipPath(
                  clipper: ArcClipper(), // Use a custom clipper for the arc
                  child: Container(
                    color: const Color(0xFFF2F1F6),
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center, // Center elements in the Stack
                      children: [
                        Image.asset(
                          'assets/images/sapo.jpg',
                          fit: BoxFit.cover, // Cover the entire background without gray space
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFFF2F1F6).withOpacity(0.8), // Add a semi-transparent white overlay
                          ),
                        ),
                        Align(
                          alignment: Alignment.center, // Center the logo within the Stack
                          child: Image.asset(
                            'assets/images/facalert_logo.png', // Use the actual logo image
                            width: 300, // Adjust the size of the logo for better fit
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add spacing between the arc and the text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Bienvenido a la plataforma de denuncias ciudadanas para Facatativá, Cundinamarca',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0), // Change text color for better contrast
                    fontFamily: 'Verdana',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.4, // Adjust line height for better readability
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomButton(
                        text: 'Iniciar Sesión',
                        onPressed: () {
                          Navigator.pushNamed(context, '/iniciar');
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomButton(
                        text: 'Registrarse',
                        onPressed: () {
                          Navigator.pushNamed(context, '/registro');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
