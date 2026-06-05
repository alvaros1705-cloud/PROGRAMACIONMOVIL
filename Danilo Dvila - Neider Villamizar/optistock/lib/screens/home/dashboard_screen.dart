import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:optistock/theme/app_theme.dart';
import 'package:optistock/services/firebase_service.dart';
import 'package:optistock/services/auth_service.dart';
import 'package:optistock/models/product.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard OptiStock'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline_rounded)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryPurple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.inventory_2_rounded, size: 50, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text('OptiStock', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('v1.0.0', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: const Text('Inventario General'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inventory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file_rounded),
              title: const Text('Cargar Excel'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/upload');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Reportes Inteligentes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/reports');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppTheme.errorRed),
              title: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.errorRed)),
              onTap: () async {
                final authService = AuthService();
                await authService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firebaseService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          
          // Calculate metrics
          final totalStock = products.fold(0, (sum, p) => sum + p.stockActual);
          final outOfStock = products.where((p) => p.stockActual == 0).length;
          final critical = products.where((p) => p.stockActual <= p.puntoReorden && p.stockActual > 0).length;
          final lowStock = products.where((p) => p.stockActual <= p.stockSeguridad && p.stockActual > 0).length;

          return RefreshIndicator(
            onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Resumen de Inventario'),
                  const SizedBox(height: 16),
                  _buildStatsGrid(totalStock, outOfStock, critical, lowStock),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tendencia de Ventas'),
                  const SizedBox(height: 16),
                  _buildSalesChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Productos Críticos/Bajo Stock'),
                  const SizedBox(height: 16),
                  _buildCriticalProductsList(products.where((p) => p.stockActual <= p.puntoReorden).toList()),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/upload'),
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add_to_photos_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.textMain,
      ),
    );
  }

  Widget _buildStatsGrid(int total, int out, int crit, int low) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Stock Total', total.toString(), Icons.inventory_2, AppTheme.primaryPurple),
        _buildStatCard('Agotados', out.toString(), Icons.error_outline, AppTheme.errorRed),
        _buildStatCard('En Reorden', crit.toString(), Icons.shopping_cart_outlined, AppTheme.warningOrange),
        _buildStatCard('Bajo Stock', low.toString(), Icons.trending_down, Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title, 
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 4),
                    FlSpot(2, 2),
                    FlSpot(3, 5),
                    FlSpot(4, 3.5),
                    FlSpot(5, 6),
                  ],
                  isCurved: true,
                  color: AppTheme.primaryPurple,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalProductsList(List<Product> criticalProducts) {
    if (criticalProducts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No hay productos críticos en este momento')),
        ),
      );
    }

    return Column(
      children: criticalProducts.take(5).map((product) {
        final isOutOfStock = product.stockActual == 0;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (isOutOfStock ? AppTheme.errorRed : AppTheme.warningOrange).withOpacity(0.1),
              child: Icon(
                isOutOfStock ? Icons.dangerous : Icons.priority_high, 
                color: isOutOfStock ? AppTheme.errorRed : AppTheme.warningOrange
              ),
            ),
            title: Text(product.referencia),
            subtitle: Text('Stock: ${product.stockActual} | PR: ${product.puntoReorden.toInt()}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isOutOfStock ? 'AGOTADO' : 'CRÍTICO', 
                  style: TextStyle(
                    color: isOutOfStock ? AppTheme.errorRed : AppTheme.warningOrange, 
                    fontWeight: FontWeight.bold,
                    fontSize: 10
                  )
                ),
                const Icon(Icons.arrow_forward_ios, size: 10),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
