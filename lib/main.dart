import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() => runApp(const ControlGastosApp());

class ControlGastosApp extends StatelessWidget {
  const ControlGastosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Gastos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ControlGastosScreen(),
    );
  }
}

class ControlGastosScreen extends StatefulWidget {
  const ControlGastosScreen({Key? key}) : super(key: key);

  @override
  State<ControlGastosScreen> createState() => _ControlGastosScreenState();
}

class _ControlGastosScreenState extends State<ControlGastosScreen> {
  double presupuestoTotal = 0.0;
  double gastosTotales = 0.0;
  List<Map<String, dynamic>> listaDeGastos = [];

  final TextEditingController _presupuestoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imagenFactura;

  void _definirPresupuesto() {
    setState(() {
      presupuestoTotal = double.tryParse(_presupuestoController.text) ?? 0.0;
    });
  }

  Future<void> _seleccionarImagen() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagenFactura = File(image.path);
      });
    }
  }

  void _agregarGasto() {
    final descripcion = _descripcionController.text;
    final monto = double.tryParse(_montoController.text) ?? 0.0;
    final fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

    if (descripcion.isNotEmpty && monto > 0) {
      if ((presupuestoTotal - gastosTotales) >= monto) {
        setState(() {
          gastosTotales += monto;
          listaDeGastos.add({
            'descripcion': descripcion,
            'monto': monto,
            'fecha': fecha,
            'imagen': _imagenFactura,
          });
          // Limpiar campos después de registrar
          _descripcionController.clear();
          _montoController.clear();
          _imagenFactura = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El monto ingresado supera el saldo restante.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa una descripción y un monto válido.'),
        ),
      );
    }
  }

  void _reiniciarPresupuesto() {
    setState(() {
      presupuestoTotal = 0.0;
      gastosTotales = 0.0;
      listaDeGastos.clear();
      _presupuestoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double saldoRestante = presupuestoTotal - gastosTotales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Gastos del Hogar'),
        actions: [
          if (presupuestoTotal > 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reiniciarPresupuesto,
              tooltip: 'Reiniciar Presupuesto',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (presupuestoTotal == 0.0) ...[
              const Text(
                'Configura tu presupuesto inicial',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _presupuestoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Monto Fijo de Gastos',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _definirPresupuesto,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Comenzar'),
              ),
            ] else ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Presupuesto Inicial'),
                          Text(
                            '\$${presupuestoTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Saldo Restante'),
                          Text(
                            '\$${saldoRestante.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: saldoRestante >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Registrar Nuevo Gasto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Descripción corta',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Monto',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _seleccionarImagen,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capturar Factura'),
                  ),
                  const SizedBox(width: 15),
                  if (_imagenFactura != null)
                    const Text('Factura lista', style: TextStyle(color: Colors.green))
                  else
                    const Text('Sin factura', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agregarGasto,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Agregar Registro'),
              ),
              const SizedBox(height: 25),
              const Text(
                'Historial de Compras',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              listaDeGastos.isEmpty
                  ? const Text('Aún no hay registros de gastos.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listaDeGastos.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        final gasto = listaDeGastos[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long, color: Colors.blue),
                            title: Text(gasto['descripcion']),
                            subtitle: Text(gasto['fecha']),
                            trailing: Text(
                              '-\$${(gasto['monto'] as double).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
