import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the default back arrow
        title: Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white), // Menu icon
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Open the drawer
                },
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Mapa de Denuncias',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)), // Set text color to white
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32), // Custom app bar color
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32), // Header background color
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Color(0xFF2E7D32)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Usuario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'usuario@correo.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ver mi Perfil'),
              onTap: () {
                Navigator.pushNamed(context, '/perfil'); // Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Mis Denuncias'),
              onTap: () {
                Navigator.pushNamed(context, '/misDenuncias'); // Corrected route to VerDenunciasScreen
              },
            ),
            ListTile(
              leading: const Icon(Icons.poll),
              title: const Text('Encuestas'),
              onTap: () {
                Navigator.pushNamed(context, '/encuestas'); // Navigate to surveys
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              onTap: () {
                Navigator.pushNamed(context, '/notificaciones'); // Navigate to notifications
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Log out
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300], // Placeholder color for the map
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey, width: 1.0),
              ),
              child: const Center(
                child: Text(
                  'Mapa Placeholder',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Opciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/realizar_denuncia'); // Navigate to RealizarDenunciaScreen
                    },
                    icon: const Icon(
                      Icons.report,
                      color: Colors.red, // Cambiar icono a color rojo
                      size: 24, // Aumentar tamaño del icono
                    ),
                    label: const Text(
                      'Reportar un Problema',
                      style: TextStyle(color: Colors.white), // Cambiar texto a blanco
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bordes redondeados
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20), // Aumentar altura del botón
                      minimumSize: const Size(double.infinity, 56), // Hacer el botón más grande
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/vistaModerador'); // Corrected route to VistaModeradorScreen
                    },
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.blue, // Icono azul para moderador
                      size: 24,
                    ),
                    label: const Text(
                      'Vista Moderador',
                      style: TextStyle(color: Colors.white), // Texto blanco
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bordes redondeados
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/vistaAdministrador'); // Navigate to VistaAdministradorScreen
                    },
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.orange, // Icono naranja para administrador
                      size: 24,
                    ),
                    label: const Text(
                      'Vista Administrador',
                      style: TextStyle(color: Colors.white), // Texto blanco
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bordes redondeados
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
