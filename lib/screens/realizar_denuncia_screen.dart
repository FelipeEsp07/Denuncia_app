import 'package:flutter/material.dart';
import 'dart:io'; // Importación necesaria para usar la clase File
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importar Google Maps
import 'package:facalert/screens/seleccionar_ubicacion_mapa_screen.dart'; // Importar la pantalla del mapa

class RealizarDenunciaScreen extends StatefulWidget {
  const RealizarDenunciaScreen({super.key});

  @override
  State<RealizarDenunciaScreen> createState() => _RealizarDenunciaScreenState();
}

class _RealizarDenunciaScreenState extends State<RealizarDenunciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  String? _clasificacionSeleccionada;
  String? _otraClasificacionSeleccionada;
  final List<File> _imagenesSeleccionadas = [];
  LatLng? _ubicacionSeleccionada; // Nueva variable para almacenar la ubicación seleccionada

  final List<String> _clasificaciones = [
    'Robo',
    'Vandalismo',
    'Acoso',
    'Accidente',
    'Otro',
  ];

  @override
  void dispose() {
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _imagenesSeleccionadas.add(File(imagen.path));
      });
    }
  }

  Future<void> _tomarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() {
        _imagenesSeleccionadas.add(File(foto.path));
      });
    }
  }

  void _eliminarImagen(int index) {
    setState(() {
      _imagenesSeleccionadas.removeAt(index);
    });
  }

  Future<void> _seleccionarUbicacionEnMapa() async {
    final LatLng? ubicacion = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeleccionarUbicacionMapaScreen(
          ubicacionInicial: _ubicacionSeleccionada ?? const LatLng(4.828903865120192, -74.3552112579438),
        ),
      ),
    );

    if (ubicacion != null) {
      setState(() {
        _ubicacionSeleccionada = ubicacion;
        _ubicacionController.text = '${ubicacion.latitude}, ${ubicacion.longitude}';
      });
    }
  }

  void _enviarDenuncia() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_clasificacionSeleccionada == _otraClasificacionSeleccionada) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La clasificación y la otra clasificación no pueden ser iguales.')),
        );
        return;
      }
      // Add logic to submit the report
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denuncia enviada correctamente')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Set back arrow color to white
        title: const Text(
          'Realizar Denuncia',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.category, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Clasificación de la Denuncia',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _clasificacionSeleccionada,
                  items: _clasificaciones
                      .map((clasificacion) => DropdownMenuItem(
                            value: clasificacion,
                            child: Text(clasificacion),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _clasificacionSeleccionada = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Seleccione una clasificación',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Seleccione una clasificación';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.add_circle_outline, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      '¿Hay otra clasificación para la denuncia?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _otraClasificacionSeleccionada,
                  items: _clasificaciones
                      .map((clasificacion) => DropdownMenuItem(
                            value: clasificacion,
                            child: Text(clasificacion),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _otraClasificacionSeleccionada = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Seleccione otra clasificación (opcional)',
                  ),
                  validator: (value) {
                    if (value != null && value == _clasificacionSeleccionada) {
                      return 'La otra clasificación no puede ser igual a la clasificación principal.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.description, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Descripción',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describa lo ocurrido',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Ubicación',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ubicacionController,
                  readOnly: true, // Hacer que el campo sea de solo lectura
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Seleccione la ubicación en el mapa',
                  ),
                  onTap: _seleccionarUbicacionEnMapa, // Abrir el mapa al hacer clic
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La ubicación es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                              SizedBox(width: 8),
                              Text(
                                'Fecha',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _seleccionarFecha,
                            child: Text(
                              _fechaSeleccionada == null
                                  ? 'Seleccionar Fecha'
                                  : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                              style: const TextStyle(color: Color(0xFF2E7D32)), // Cambiar texto al color 0xFF2E7D32
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.access_time, color: Color(0xFF2E7D32)),
                              SizedBox(width: 8),
                              Text(
                                'Hora',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _seleccionarHora,
                            child: Text(
                              _horaSeleccionada == null
                                  ? 'Seleccionar Hora'
                                  : '${_horaSeleccionada!.hour}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Color(0xFF2E7D32)), // Cambiar texto al color 0xFF2E7D32
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.image, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Imágenes (opcional)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _seleccionarImagen,
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                      label: const Text(
                        'Seleccionar Imagen',
                        style: TextStyle(color: Colors.white), // Cambiar texto a blanco
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _tomarFoto,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        'Tomar Foto',
                        style: TextStyle(color: Colors.white), // Cambiar texto a blanco
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_imagenesSeleccionadas.isNotEmpty) ...[
                  const Text(
                    'Nota: Las imágenes no deben mostrar contenido sensible (contenido sensible).',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_imagenesSeleccionadas.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      _imagenesSeleccionadas.length,
                      (index) => Stack(
                        children: [
                          Image.file(
                            _imagenesSeleccionadas[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _eliminarImagen(index),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Nota: Las denuncias realizadas aquí no reemplazan las denuncias formales ante la Fiscalía.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: double.infinity, // Hacer el botón más ancho
                    child: ElevatedButton(
                      onPressed: _enviarDenuncia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16), // Altura del botón
                      ),
                      child: const Text(
                        'Enviar Denuncia',
                        style: TextStyle(color: Colors.white), // Cambiar texto a blanco
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
