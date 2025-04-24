import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo: ubicaciones con cantidad de denuncias
    final List<Map<String, dynamic>> denuncias = [
      {'lat': 4.828903865120192, 'lng': -74.3552112579438, 'cantidad': 2},
      {'lat': 4.816438331259444, 'lng': -74.34789419163647, 'cantidad': 10},
      {'lat': 4.830000000000000, 'lng': -74.350000000000000, 'cantidad': 5},
    ];

    // Generar círculos para el mapa de calor
    Set<Circle> heatmapCircles = denuncias.map((denuncia) {
      Color color;
      if (denuncia['cantidad'] < 3) {
        color = Colors.green.withOpacity(0.5); // Verde para pocas denuncias
      } else if (denuncia['cantidad'] < 7) {
        color = Colors.yellow.withOpacity(0.5); // Amarillo para denuncias moderadas
      } else {
        color = Colors.red.withOpacity(0.5); // Rojo para muchas denuncias
      }

      return Circle(
        circleId: CircleId('${denuncia['lat']}_${denuncia['lng']}'),
        center: LatLng(denuncia['lat'], denuncia['lng']),
        radius: 200, // Radio del círculo en metros
        fillColor: color,
        strokeColor: color,
        strokeWidth: 1,
      );
    }).toSet();

    // Datos de ejemplo: parcelas con cantidad de denuncias
    final List<Map<String, dynamic>> parcelas = [
      {
        'id': 'parcela_1',
        'puntos': [
          LatLng(4.828903865120192, -74.3552112579438),
          LatLng(4.829903865120192, -74.3552112579438),
          LatLng(4.829903865120192, -74.3542112579438),
          LatLng(4.828903865120192, -74.3542112579438),
        ],
        'cantidad': 2,
      },
      {
        'id': 'parcela_2',
        'puntos': [
          LatLng(4.816438331259444, -74.34789419163647),
          LatLng(4.817438331259444, -74.34789419163647),
          LatLng(4.817438331259444, -74.34689419163647),
          LatLng(4.816438331259444, -74.34689419163647),
        ],
        'cantidad': 10,
      },
    ];

    // Generar polígonos para las parcelas
    Set<Polygon> parcelasPolygons = parcelas.map((parcela) {
      Color color;
      if (parcela['cantidad'] < 3) {
        color = Colors.green.withOpacity(0.5); // Verde para pocas denuncias
      } else if (parcela['cantidad'] < 7) {
        color = Colors.yellow.withOpacity(0.5); // Amarillo para denuncias moderadas
      } else {
        color = Colors.red.withOpacity(0.5); // Rojo para muchas denuncias
      }

      return Polygon(
        polygonId: PolygonId(parcela['id']),
        points: parcela['puntos'],
        fillColor: color,
        strokeColor: color,
        strokeWidth: 1,
      );
    }).toSet();

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
              leading: const Icon(Icons.home), // Icono de casa
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pushNamed(context, '/'); // Navegar al MainScreen
              },
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
                Navigator.pushNamedAndRemoveUntil(context, '/inicio', (route) => false); // Navigate to InicioScreen
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(4.828903865120192, -74.3552112579438),
                zoom: 15,
              ),
              circles: heatmapCircles, // Agregar los círculos al mapa
              polygons: parcelasPolygons, // Agregar los polígonos al mapa
              onTap: (LatLng latLong) async {
                TextEditingController _textController = TextEditingController();

                String? title = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Agregar marcador"),
                      content: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(hintText: "Nombre del marcador"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(_textController.text),
                          child: const Text("Guardar"),
                        ),
                      ],
                    );
                  },
                );

                if (title != null && title.isNotEmpty) {
                  (context as Element).markNeedsBuild(); // Trigger rebuild
                }
              },
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
