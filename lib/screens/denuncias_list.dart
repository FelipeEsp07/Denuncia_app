import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/api_service.dart';

class DenunciasListScreen extends StatefulWidget {
  const DenunciasListScreen({super.key});

  @override
  State<DenunciasListScreen> createState() => _DenunciasListScreenState();
}

class _DenunciasListScreenState extends State<DenunciasListScreen> {
  late Future<List<Denuncia>> _futureDenuncias;

  @override
  void initState() {
    super.initState();
    _futureDenuncias = ApiService.fetchDenuncias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Denuncias')),
      body: FutureBuilder<List<Denuncia>>(
        future: _futureDenuncias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay denuncias'));
          }

          final denuncias = snapshot.data!;
          return ListView.builder(
            itemCount: denuncias.length,
            itemBuilder: (ctx, i) {
              final d = denuncias[i];
              return ListTile(
                title: Text(d.titulo),
                subtitle: Text('${d.tipo} • ${d.estado}'),
                trailing: Text(d.fecha),
              );
            },
          );
        },
      ),
    );
  }
}
