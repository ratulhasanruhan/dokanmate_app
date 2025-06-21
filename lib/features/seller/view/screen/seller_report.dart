import 'package:dokanmate_app/features/dashboard/controller/invoice_controller.dart';
import 'package:dokanmate_app/features/seller/controller/seller_controller.dart';
import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../dashboard/model/InvoiceModel.dart';

class SellerReportPage extends StatelessWidget {
  SellerReportPage({super.key});

  final SellerController sellerController = Get.find<SellerController>();
  final InvoiceController invoiceController = Get.find<InvoiceController>();

  List<_SellerReportData> _aggregateSellerData(List<SellerModel> sellers, List<Invoice> invoices) {
    final Map<String, _SellerReportData> dataMap = {
      for (var s in sellers)
        s.id: _SellerReportData(
          seller: s,
          total: 0,
          paid: 0,
          due: 0,
        )
    };
    for (var inv in invoices) {
      if (dataMap.containsKey(inv.sellerId)) {
        dataMap[inv.sellerId]!.total += inv.totalAmount;
        dataMap[inv.sellerId]!.paid += inv.amountPaid;
        dataMap[inv.sellerId]!.due += inv.amountDue;
      }
    }
    return dataMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ক্রেতা রিপোর্ট'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        final sellers = sellerController.sellers;
        final invoices = invoiceController.invoices;
        if (sellers.isEmpty) {
          return Center(child: Text('কোনো ক্রেতা নেই', style: TextStyle(fontSize: 16)));
        }
        final data = _aggregateSellerData(sellers, invoices);
        if (data.every((d) => d.total == 0)) {
          return Center(child: Text('কোনো ক্রেতার বিক্রয় নেই', style: TextStyle(fontSize: 16)));
        }
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('ক্রেতা অনুযায়ী বিক্রয় (৳)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: _SellerBarChart(data: data),
            ),
            SizedBox(height: 32),
            Text('বিস্তারিত টেবিল', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            _SellerReportTable(data: data),
          ],
        );
      }),
    );
  }
}

class _SellerReportData {
  final SellerModel seller;
  double total;
  double paid;
  double due;
  _SellerReportData({required this.seller, required this.total, required this.paid, required this.due});
}

class _SellerBarChart extends StatelessWidget {
  final List<_SellerReportData> data;
  const _SellerBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: d.total, color: Colors.blue, width: 10),
            BarChartRodData(toY: d.paid, color: Colors.green, width: 10),
            BarChartRodData(toY: d.due, color: Colors.red, width: 10),
          ],
        ),
      );
    }
    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return Container();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data[idx].seller.name.length > 5
                        ? data[idx].seller.name.substring(0, 5) + '...'
                        : data[idx].seller.name,
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
        groupsSpace: 16,
        maxY: data.map((d) => d.total).fold(0.0, (a, b) => a > b ? a : b) * 1.2 + 1,
      ),
    );
  }
}

class _SellerReportTable extends StatelessWidget {
  final List<_SellerReportData> data;
  const _SellerReportTable({required this.data});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('নাম')),
        DataColumn(label: Text('মোট')),
        DataColumn(label: Text('পরিশোধ')),
        DataColumn(label: Text('বাকি')),
      ],
      rows: data.map((d) {
        return DataRow(cells: [
          DataCell(Text(d.seller.name)),
          DataCell(Text('৳${d.total.toStringAsFixed(0)}')),
          DataCell(Text('৳${d.paid.toStringAsFixed(0)}')),
          DataCell(Text('৳${d.due.toStringAsFixed(0)}')),
        ]);
      }).toList(),
    );
  }
} 