import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GraficosScreen extends StatefulWidget {
  @override
  _GraficosScreenState createState() => _GraficosScreenState();
}

class _GraficosScreenState extends State<GraficosScreen> {
  int totalPeticiones = 0;
  int totalQuejas = 0;
  int totalVivencias = 0;
  int totalReclamos = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() async {
    int peticionesCount = await _getCountFromFirestore('peticiones');
    int quejasCount = await _getCountFromFirestore('quejas');
    int vivenciasCount = await _getCountFromFirestore('vivencias');
    int reclamosCount = await _getCountFromFirestore('reclamos');

    setState(() {
      totalPeticiones = peticionesCount;
      totalQuejas = quejasCount;
      totalVivencias = vivenciasCount;
      totalReclamos = reclamosCount;
    });
  }

  Future<int> _getCountFromFirestore(String collection) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas de Solicitudes'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCircularChart(),
              SizedBox(height: 20),
              _buildColumnChart(),
              SizedBox(height: 20),
              _buildStackedColumnChart(),
              SizedBox(height: 20),
              _buildAreaChart(),
              SizedBox(height: 20),
              _buildLineChart(),
              SizedBox(height: 20),
              _buildRadialBarChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularChart() {
    return SfCircularChart(
      title: ChartTitle(text: 'Total de Solicitudes por Tipo'),
      legend: Legend(isVisible: true),
      series: <CircularSeries>[
        PieSeries<SolicitudCountData, String>(
          dataSource: [
            SolicitudCountData('Peticiones', totalPeticiones),
            SolicitudCountData('Quejas', totalQuejas),
            SolicitudCountData('Vivencias', totalVivencias),
            SolicitudCountData('Reclamos', totalReclamos),
          ],
          xValueMapper: (SolicitudCountData data, _) => data.tipo,
          yValueMapper: (SolicitudCountData data, _) => data.count,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ],
    );
  }

  Widget _buildColumnChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Estadísticas de Solicitudes por Tipo'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        ColumnSeries<SolicitudCountData, String>(
          dataSource: [
            SolicitudCountData('Peticiones', totalPeticiones),
            SolicitudCountData('Quejas', totalQuejas),
            SolicitudCountData('Vivencias', totalVivencias),
            SolicitudCountData('Reclamos', totalReclamos),
          ],
          xValueMapper: (SolicitudCountData data, _) => data.tipo,
          yValueMapper: (SolicitudCountData data, _) => data.count,
          name: 'Solicitudes',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildStackedColumnChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Solicitudes Apiladas por Tipo'),
      legend: Legend(isVisible: true),
      series: <ChartSeries>[
        StackedColumnSeries<SolicitudCountData, String>(
          dataSource: [
            SolicitudCountData('Peticiones', totalPeticiones),
            SolicitudCountData('Quejas', totalQuejas),
            SolicitudCountData('Vivencias', totalVivencias),
            SolicitudCountData('Reclamos', totalReclamos),
          ],
          xValueMapper: (SolicitudCountData data, _) => data.tipo,
          yValueMapper: (SolicitudCountData data, _) => data.count,
          name: 'Solicitudes',
        ),
      ],
    );
  }

  Widget _buildAreaChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Tendencia Acumulativa de Solicitudes'),
      legend: Legend(isVisible: true),
      series: <ChartSeries>[
        AreaSeries<SolicitudCountData, String>(
          dataSource: [
            SolicitudCountData('Peticiones', totalPeticiones),
            SolicitudCountData('Quejas', totalQuejas),
            SolicitudCountData('Vivencias', totalVivencias),
            SolicitudCountData('Reclamos', totalReclamos),
          ],
          xValueMapper: (SolicitudCountData data, _) => data.tipo,
          yValueMapper: (SolicitudCountData data, _) => data.count,
          name: 'Solicitudes',
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Tendencia de Solicitudes por Tipo'),
      legend: Legend(isVisible: true),
      series: <ChartSeries>[
        LineSeries<SolicitudCountData, String>(
          dataSource: [
            SolicitudCountData('Peticiones', totalPeticiones),
            SolicitudCountData('Quejas', totalQuejas),
            SolicitudCountData('Vivencias', totalVivencias),
            SolicitudCountData('Reclamos', totalReclamos),
          ],
          xValueMapper: (SolicitudCountData data, _) => data.tipo,
          yValueMapper: (SolicitudCountData data, _) => data.count,
          name: 'Solicitudes',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildRadialBarChart() {
    return SfCircularChart(
      title: ChartTitle(text: 'Distribución de Solicitudes por Tipo'),
      legend: Legend(isVisible: true),
      series: <CircularSeries>[
        RadialBarSeries<SolicitudCountData, String>(
          dataSource: [
            SolicitudCountData('Peticiones', totalPeticiones),
            SolicitudCountData('Quejas', totalQuejas),
            SolicitudCountData('Vivencias', totalVivencias),
            SolicitudCountData('Reclamos', totalReclamos),
          ],
          xValueMapper: (SolicitudCountData data, _) => data.tipo,
          yValueMapper: (SolicitudCountData data, _) => data.count,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}

class SolicitudCountData {
  final String tipo;
  final int count;

  SolicitudCountData(this.tipo, this.count);

  @override
  String toString() {
    return 'SolicitudCountData{tipo: $tipo, count: $count}';
  }
}
