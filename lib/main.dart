import 'package:flutter/material.dart';
import 'screens/inicio_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/iniciar_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/main_screen.dart';
import 'screens/realizar_denuncia_screen.dart';
import 'screens/ver_denuncias_screen.dart';
import 'screens/detalle_denuncia_screen.dart';
import 'screens/moderador_denuncias_screen.dart';
import 'screens/vista_administrador_screen.dart';
import 'screens/supervisar_denuncias_screen.dart';
import 'screens/gestionar_usuarios_screen.dart';
import 'screens/generar_informes_screen.dart';

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
      initialRoute: '/inicio', // Set initial route to InicioScreen
      routes: {
        '/': (context) => const MainScreen(),
        '/inicio': (context) => const InicioScreen(), // Route for InicioScreen
        '/misDenuncias': (context) => const VerDenunciasScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/iniciar': (context) => const IniciarScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/realizar_denuncia': (context) => const RealizarDenunciaScreen(),
        '/vistaModerador': (context) => const ModeradorDenunciasScreen(),
        '/vistaAdministrador': (context) => const VistaAdministradorScreen(),
        '/supervisarDenuncias': (context) => const SupervisarDenunciasScreen(),
        '/gestionarUsuarios': (context) => const GestionarUsuariosScreen(),
        '/generarInformes': (context) => const GenerarInformesScreen(),
      },
    );
  }
}