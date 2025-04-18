import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Back arrow color set to white
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white), // Text color set to white
        ),
        backgroundColor: const Color(0xFF2E7D32), // Custom app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Nombre del Usuario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Información Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('Correo Electrónico'),
              subtitle: Text('usuario@correo.com'),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text('Teléfono'),
              subtitle: Text('+123 456 7890'),
            ),
            const ListTile(
              leading: Icon(Icons.home),
              title: Text('Dirección'),
              subtitle: Text('Calle Falsa 123, Ciudad'),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/editarPerfil'); // Navigate to edit profile
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Ensure text color is white
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32), // Custom button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Increased padding
                  elevation: 5, // Add shadow for depth
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
