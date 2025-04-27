// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'screens/inicio_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/iniciar_screen.dart';
import 'screens/main_screen.dart';               // <<-- Importa tu MainScreen
import 'screens/perfil_screen.dart';
import 'screens/realizar_denuncia_screen.dart';
import 'screens/ver_denuncias_screen.dart';
import 'screens/moderador_denuncias_screen.dart';
import 'screens/vista_administrador_screen.dart';
import 'screens/supervisar_denuncias_screen.dart';
import 'screens/gestionar_usuarios_screen.dart';
import 'screens/generar_informes_screen.dart';
import 'screens/seleccionar_ubicacion_mapa_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FacAlert',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

      initialRoute: '/inicio',
      routes: {
        '/': (context) => const IniciarScreen(),
        '/inicio': (context) => const InicioScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/iniciar': (context) => const IniciarScreen(),

        // Pantallas autenticadas
        '/main': (context) => const MainScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/misDenuncias': (context) => const VerDenunciasScreen(),
        '/realizar_denuncia': (context) => const RealizarDenunciaScreen(),
        '/vistaModerador': (context) => const ModeradorDenunciasScreen(),
        '/vistaAdministrador': (context) => const VistaAdministradorScreen(),
        '/supervisarDenuncias': (context) => const SupervisarDenunciasScreen(),
        '/gestionarUsuarios': (context) => const GestionarUsuariosScreen(),
        '/generarInformes': (context) => const GenerarInformesScreen(),
        '/seleccionarUbicacionMapa': (context) =>
            const SeleccionarUbicacionMapaScreen(
              ubicacionInicial: LatLng(4.828903865120192, -74.3552112579438),
            ),
      },
    );
  }
}
