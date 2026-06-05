import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:optistock/theme/app_theme.dart';
import 'package:optistock/config/app_config.dart';

class ExcelUploadScreen extends StatefulWidget {
  const ExcelUploadScreen({super.key});

  @override
  State<ExcelUploadScreen> createState() => _ExcelUploadScreenState();
}

class _ExcelUploadScreenState extends State<ExcelUploadScreen> {
  String? _fileName;
  bool _isUploading = false;
  String? _statusMessage;
  String _uploadType = 'initial'; // 'initial' or 'history'
  double _uploadProgress = 0;
  final TextEditingController _leadTimeController = TextEditingController(text: '20');

  @override
  void dispose() {
    _leadTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _statusMessage = null;
        _uploadProgress = 0;
      });
      _uploadFile(result.files.single);
    }
  }

  Future<void> _uploadFile(PlatformFile file) async {
    setState(() => _isUploading = true);

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 2),
      ));

      final url = _uploadType == 'initial'
          ? AppConfig.uploadInitialInventoryUrl
          : AppConfig.analyzeInventoryUrl;

      FormData formData;
      if (file.bytes != null) {
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(file.bytes!, filename: file.name),
        });
      } else if (file.path != null) {
        formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path!, filename: file.name),
        });
      } else {
        throw Exception("No se pudo leer el archivo.");
      }

      // Build URL with lead time param for history upload
      final requestUrl = _uploadType == 'history'
          ? '$url?lead_time=${_leadTimeController.text.trim()}'
          : url;

      final response = await dio.post(
        requestUrl,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final count = (data['data'] as List?)?.length ?? 0;
        setState(() {
          _statusMessage = _uploadType == 'initial'
              ? '✓ Se cargaron $count productos al inventario.'
              : '✓ Se analizaron $count referencias. ¡Cálculos actualizados!';
        });
        _showResultsDialog(response.data['data'] as List);
      }
    } on DioException catch (e) {
      String msg = 'Error de conexión con el servidor.';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = 'El servidor tardó demasiado. Verifica que el backend esté corriendo.';
      } else if (e.response != null) {
        msg = 'Error del servidor: ${e.response?.data['detail'] ?? e.message}';
      }
      setState(() => _statusMessage = msg);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });
    }
  }

  void _showResultsDialog(List results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_uploadType == 'initial'
            ? 'Inventario Cargado'
            : 'Resultados del Análisis'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length > 10 ? 10 : results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return ListTile(
                dense: true,
                title: Text('${item['referencia']}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text(_uploadType == 'initial'
                    ? 'Stock Actual: ${item['stock_actual']}'
                    : 'Punto Reorden: ${item['punto_reorden']}  |  Stock Seg.: ${item['stock_seguridad']}'),
              );
            },
          ),
        ),
        actions: [
          if (results.length > 10)
            Text('... y ${results.length - 10} más guardados en Firebase.',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CERRAR')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargar Inventario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Type selector
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'initial',
                    label: Text('Inventario Inicial', style: TextStyle(fontSize: 12))),
                ButtonSegment(
                    value: 'history',
                    label: Text('Historial de Ventas', style: TextStyle(fontSize: 12))),
              ],
              selected: {_uploadType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _uploadType = newSelection.first;
                  _fileName = null;
                  _statusMessage = null;
                });
              },
            ),
            const SizedBox(height: 20),

            // Lead Time field (only for history)
            if (_uploadType == 'history') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppTheme.primaryPurple),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Lead Time (días de entrega del proveedor):',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _leadTimeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                          ),
                        ),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Upload area
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2), width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    _isUploading ? Icons.cloud_sync : Icons.cloud_upload_outlined,
                    size: 72,
                    color: AppTheme.primaryPurple,
                  ),
                  const SizedBox(height: 12),
                  const Text('Sube tu archivo Excel',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Formatos soportados: .xlsx, .xls',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 20),
                  if (_fileName != null)
                    Text(
                      '📎 $_fileName',
                      style: const TextStyle(
                          color: AppTheme.primaryPurple, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  if (_isUploading) ...[
                    const Text('Procesando archivo...', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _uploadProgress > 0 ? _uploadProgress : null,
                        minHeight: 8,
                        backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                      ),
                    ),
                    if (_uploadProgress > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12, color: AppTheme.primaryPurple)),
                      ),
                  ] else
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('SELECCIONAR ARCHIVO'),
                    ),
                ],
              ),
            ),

            // Status message
            if (_statusMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage!.contains('Error') || _statusMessage!.contains('tardó')
                      ? AppTheme.errorRed.withOpacity(0.1)
                      : AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusMessage!.contains('Error') || _statusMessage!.contains('tardó')
                        ? AppTheme.errorRed
                        : AppTheme.successGreen,
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _statusMessage!.contains('Error') || _statusMessage!.contains('tardó')
                        ? AppTheme.errorRed
                        : AppTheme.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Instrucciones',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    const Text('El archivo debe contener las columnas:',
                        style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      _uploadType == 'initial'
                          ? 'Referencia interna, Cantidad a la mano'
                          : 'Producto, Terminado, Transferir',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryPurple),
                      textAlign: TextAlign.center,
                    ),
                    if (_uploadType == 'history') ...[
                      const SizedBox(height: 6),
                      const Text(
                        'La columna "Producto" debe tener la referencia entre corchetes.\nEj: [17211-K79-E00] FILTRO DE AIRE...',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
