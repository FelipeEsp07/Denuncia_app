import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gestion_roles_screen.dart'; 
import 'gest_usuarios.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<void> _loadingFuture;
  String _nombre = '';
  String _email = '';
  String _role = 'usuario';
  double? _userLat;
  double? _userLng;

  CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(4.8176, -74.3542),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    _nombre = prefs.getString('user_nombre')?.trim() ?? '';
    _email = prefs.getString('user_email')?.trim() ?? '';
    _role = prefs.getString('user_rol')?.trim().toLowerCase() ?? 'usuario';
    _userLat = prefs.getDouble('user_latitud');
    _userLng = prefs.getDouble('user_longitud');

    if (_userLat != null && _userLng != null) {
      _initialCamera = CameraPosition(
        target: LatLng(_userLat!, _userLng!),
        zoom: 16,
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/iniciar', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF2E7D32),
            title: Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Mapa de Denuncias', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          drawer: _buildDrawer(),
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: GoogleMap(
                  initialCameraPosition: _initialCamera,
                  markers: _createMarkers(),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    if (_userLat != null && _userLng != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(_userLat!, _userLng!),
                          16,
                        ),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Opciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (_role == 'usuario') ...[
                        _buildRoleButton(
                          icon: Icons.report,
                          label: 'Reportar un Problema',
                          onPressed: () => Navigator.pushNamed(context, '/realizar_denuncia'),
                        ),
                      ] else if (_role == 'moderador') ...[
                        _buildRoleButton(
                          icon: Icons.admin_panel_settings,
                          label: 'Vista Moderador',
                          onPressed: () => Navigator.pushNamed(context, '/vistaModerador'),
                        ),
                      ] else if (_role == 'administrador') ...[
                        _buildRoleButton(
                          icon: Icons.admin_panel_settings,
                          label: 'Vista Administrador',
                          onPressed: () => Navigator.pushNamed(context, '/vistaAdministrador'),
                        ),
                        const SizedBox(height: 12),
                        _buildRoleButton(
                          icon: Icons.settings,
                          label: 'Gestión de Roles',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GestionRolesScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildRoleButton(
                          icon: Icons.group,
                          label: 'Gestión de Usuarios',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GestUsuariosScreen()),
                            );
                          },
                        ),
                      ] else ...[
                        Center(child: Text('Rol desconocido: $_role')),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Set<Marker> _createMarkers() {
    final markers = <Marker>{};
    if (_userLat != null && _userLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('home_marker'),
          position: LatLng(_userLat!, _userLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Tu hogar',
            snippet: 'Ubicación guardada',
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF2E7D32), size: 40),
            ),
            accountName: Text(_nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail: Text(_email, style: const TextStyle(fontSize: 14)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () => Navigator.pushReplacementNamed(context, '/main'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Ver mi Perfil'),
            onTap: () => Navigator.pushNamed(context, '/perfil'),
          ),
          if (_role == 'usuario' || _role == 'administrador') ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Mis Denuncias'),
            onTap: () => Navigator.pushNamed(context, '/misDenuncias'),
          ),
          if (_role == 'moderador' || _role == 'administrador') ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Aprobar Denuncias'),
            onTap: () => Navigator.pushNamed(context, '/aprobarDenuncias'),
          ),
          if (_role == 'administrador') ...[
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Gestión de Usuarios'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GestUsuariosScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Gestión de Roles'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GestionRolesScreen()),
              ),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildRoleButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 56),
      ),
    );
  }
}
