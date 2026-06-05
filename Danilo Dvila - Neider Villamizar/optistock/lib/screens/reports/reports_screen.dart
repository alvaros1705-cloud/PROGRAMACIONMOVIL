import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:optistock/theme/app_theme.dart';
import 'package:optistock/config/app_config.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isDownloading = false;
  String? _status;

  Future<void> _downloadReport() async {
    setState(() {
      _isDownloading = true;
      _status = "Generando reporte analítico...";
    });

    try {
      final dio = Dio();
      const url = AppConfig.exportReportUrl;
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/reporte_pedidos_optistock.xlsx";
      
      final response = await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _status = "Descargando: ${(received / total * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );

      if (response.statusCode == 200) {
        setState(() => _status = "Reporte guardado en documentos");
        _showSuccessDialog(filePath);
      }
    } catch (e) {
      setState(() => _status = "Error al descargar: $e");
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  void _showSuccessDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 50),
        content: const Text(
          '¡Reporte de pedidos generado con éxito!\n\n¿Qué deseas hacer ahora?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Share.shareXFiles([XFile(path)], text: 'Reporte de Pedidos OptiStock'),
            child: const Text('COMPARTIR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              OpenFilex.open(path);
            },
            child: const Text('ABRIR EXCEL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Inteligentes')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 100, color: AppTheme.primaryPurple),
            const SizedBox(height: 24),
            const Text(
              'Generador de Pedidos Sugeridos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Este reporte utiliza la teoría de inventario de seguridad para calcular exactamente qué productos comprar y en qué cantidad, optimizando tu capital.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 48),
            _isDownloading
                ? Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(_status ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                : ElevatedButton.icon(
                    onPressed: _downloadReport,
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('DESCARGAR REPORTE EXCEL'),
                  ),
            if (_status != null && !_isDownloading)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  _status!,
                  style: TextStyle(
                    color: _status!.contains('Error') ? AppTheme.errorRed : AppTheme.successGreen,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
