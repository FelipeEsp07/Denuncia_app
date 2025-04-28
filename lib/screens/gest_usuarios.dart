import 'package:flutter/material.dart';

class GestUsuariosScreen extends StatelessWidget {
  const GestUsuariosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(color: Colors.white), 
        ),
        backgroundColor: const Color(0xFF2E7D32),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/gestionUsuarios/registro');
                },
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white24,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person_add, color: Colors.white, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'Registrar\nUsuario',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/gestionUsuarios/lista');
                },
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white24,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.format_list_bulleted, color: Colors.white, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'Listar\nUsuarios',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
