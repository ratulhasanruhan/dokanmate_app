import 'dart:io';
import 'dart:typed_data';
import 'package:dokanmate_app/features/dashboard/controller/invoice_controller.dart';
import 'package:dokanmate_app/features/seller/controller/seller_controller.dart';
import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../dashboard/model/InvoiceModel.dart';

class ExportController extends GetxController {
  final SellerController sellerController = Get.find<SellerController>();
  final InvoiceController invoiceController = Get.find<InvoiceController>();

  final RxBool isExporting = false.obs;
  final RxString exportStatus = ''.obs;

  // Custom fonts for Bengali support
  pw.Font? _bengaliFont;
  pw.Font? _bengaliFontBold;

  @override
  void onInit() {
    super.onInit();
    _loadCustomFonts();
  }

  // Load custom Bengali fonts
  Future<void> _loadCustomFonts() async {
    try {
      final ByteData regularFontData = await rootBundle.load('assets/fonts/Li Ador Noirrit Regular.ttf');
      final ByteData boldFontData = await rootBundle.load('assets/fonts/Li Ador Noirrit Bold.ttf');
      
      _bengaliFont = pw.Font.ttf(regularFontData);
      _bengaliFontBold = pw.Font.ttf(boldFontData);
    } catch (e) {
      print('Error loading custom fonts: $e');
      // Fallback to default fonts if custom fonts fail to load
    }
  }

  // Load logo from assets
  Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      print('Logo not found: $e');
      return null;
    }
  }

  // Request storage permission
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we don't need storage permissions for Downloads folder
      if (await _isAndroid13OrHigher()) {
        return true;
      }
      
      // For older Android versions, request storage permission
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  // Check if Android version is 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt >= 33;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // Get export directory
  Future<Directory> _getExportDirectory() async {
    if (Platform.isAndroid) {
      // For Android 13+, use the Downloads directory directly
      if (await _isAndroid13OrHigher()) {
        return Directory('/storage/emulated/0/Download');
      }
      
      // For older versions, try to get the Downloads directory
      try {
        final downloadsDir = await getExternalStorageDirectory();
        if (downloadsDir != null) {
          return downloadsDir;
        }
      } catch (e) {
        print('Error getting external storage directory: $e');
      }
      
      // Fallback to Downloads folder
      return Directory('/storage/emulated/0/Download');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  // Build watermark
  pw.Widget _buildWatermark() {
    return pw.Center(
      child: pw.Transform.rotate(
        angle: -0.5,
        child: pw.Text(
          'DokanMate',
          style: pw.TextStyle(
            font: _bengaliFontBold ?? pw.Font.helveticaBold(),
            fontSize: 60,
            color: PdfColors.grey.shade(0.1),
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Export all sellers to PDF
  Future<void> exportSellers() async {
    if (!await _requestPermission()) {
      Get.snackbar('ত্রুটি', 'স্টোরেজ অনুমতি প্রয়োজন');
      return;
    }

    try {
      isExporting.value = true;
      exportStatus.value = 'ক্রেতাদের তথ্য প্রস্তুত হচ্ছে...';

      final pdf = pw.Document();
      final logo = await _loadLogo();

      // Add pages
      pdf.addPage(
        pw.MultiPage(
          margin: pw.EdgeInsets.all(20),
          header: (context) => _buildHeader(context, logo, 'ক্রেতাদের তালিকা'),
          footer: (context) => _buildFooter(context),
          build: (context) => _buildSellersContent(context),
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            theme: pw.ThemeData.withFont(
              base: _bengaliFont ?? pw.Font.helvetica(),
              bold: _bengaliFontBold ?? pw.Font.helveticaBold(),
            ),
          ),
        ),
      );

      // Save PDF
      exportStatus.value = 'পিডিএফ সংরক্ষণ হচ্ছে...';
      final directory = await _getExportDirectory();
      final file = File('${directory.path}/ক্রেতাদের_তালিকা_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      isExporting.value = false;
      exportStatus.value = '';

      // Share file
      await Share.shareXFiles([XFile(file.path)], text: 'ক্রেতাদের তালিকা');

      Get.snackbar('সফল', 'ক্রেতাদের তালিকা এক্সপোর্ট হয়েছে', backgroundColor: Colors.green[100]);
    } catch (e) {
      isExporting.value = false;
      exportStatus.value = '';
      Get.snackbar('ত্রুটি', 'এক্সপোর্ট করতে সমস্যা হয়েছে: $e');
    }
  }

  // Export all invoices to PDF
  Future<void> exportInvoices() async {
    if (!await _requestPermission()) {
      Get.snackbar('ত্রুটি', 'স্টোরেজ অনুমতি প্রয়োজন');
      return;
    }

    try {
      isExporting.value = true;
      exportStatus.value = 'বিলের তথ্য প্রস্তুত হচ্ছে...';

      final pdf = pw.Document();
      final logo = await _loadLogo();

      // Add pages
      pdf.addPage(
        pw.MultiPage(
          margin: pw.EdgeInsets.all(20),
          header: (context) => _buildHeader(context, logo, 'বিলের তালিকা'),
          footer: (context) => _buildFooter(context),
          build: (context) => _buildInvoicesContent(context),
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            theme: pw.ThemeData.withFont(
              base: _bengaliFont ?? pw.Font.helvetica(),
              bold: _bengaliFontBold ?? pw.Font.helveticaBold(),
            ),
          ),
        ),
      );

      // Save PDF
      exportStatus.value = 'পিডিএফ সংরক্ষণ হচ্ছে...';
      final directory = await _getExportDirectory();
      final file = File('${directory.path}/বিলের_তালিকা_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      isExporting.value = false;
      exportStatus.value = '';

      // Share file
      await Share.shareXFiles([XFile(file.path)], text: 'বিলের তালিকা');

      Get.snackbar('সফল', 'বিলের তালিকা এক্সপোর্ট হয়েছে', backgroundColor: Colors.green[100]);
    } catch (e) {
      isExporting.value = false;
      exportStatus.value = '';
      Get.snackbar('ত্রুটি', 'এক্সপোর্ট করতে সমস্যা হয়েছে: $e');
    }
  }

  // Export all data (sellers + invoices) to PDF
  Future<void> exportAllData() async {
    if (!await _requestPermission()) {
      Get.snackbar('ত্রুটি', 'স্টোরেজ অনুমতি প্রয়োজন');
      return;
    }

    try {
      isExporting.value = true;
      exportStatus.value = 'সম্পূর্ণ ডাটা প্রস্তুত হচ্ছে...';

      final pdf = pw.Document();
      final logo = await _loadLogo();

      // Add pages
      pdf.addPage(
        pw.MultiPage(
          margin: pw.EdgeInsets.all(20),
          header: (context) => _buildHeader(context, logo, 'সম্পূর্ণ ডাটা রিপোর্ট'),
          footer: (context) => _buildFooter(context),
          build: (context) => [
            _buildSummaryContent(context),
            ..._buildSellersContent(context),
            ..._buildInvoicesContent(context),
          ],
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            theme: pw.ThemeData.withFont(
              base: _bengaliFont ?? pw.Font.helvetica(),
              bold: _bengaliFontBold ?? pw.Font.helveticaBold(),
            ),
          ),
        ),
      );

      // Save PDF
      exportStatus.value = 'পিডিএফ সংরক্ষণ হচ্ছে...';
      final directory = await _getExportDirectory();
      final file = File('${directory.path}/সম্পূর্ণ_ডাটা_রিপোর্ট_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      isExporting.value = false;
      exportStatus.value = '';

      // Share file
      await Share.shareXFiles([XFile(file.path)], text: 'সম্পূর্ণ ডাটা রিপোর্ট');

      Get.snackbar('সফল', 'সম্পূর্ণ ডাটা এক্সপোর্ট হয়েছে', backgroundColor: Colors.green[100]);
    } catch (e) {
      isExporting.value = false;
      exportStatus.value = '';
      Get.snackbar('ত্রুটি', 'এক্সপোর্ট করতে সমস্যা হয়েছে: $e');
      debugPrint('Export error: $e');
    }
  }

  // Export individual seller data
  Future<void> exportSellerData(SellerModel seller) async {
    if (!await _requestPermission()) {
      Get.snackbar('ত্রুটি', 'স্টোরেজ অনুমতি প্রয়োজন');
      return;
    }

    try {
      isExporting.value = true;
      exportStatus.value = 'ক্রেতার তথ্য প্রস্তুত হচ্ছে...';

      final pdf = pw.Document();
      final logo = await _loadLogo();

      // Get seller's invoices
      final sellerInvoices = invoiceController.invoices.where((inv) => inv.sellerId == seller.id).toList();

      // Add pages
      pdf.addPage(
        pw.MultiPage(
          margin: pw.EdgeInsets.all(20),
          header: (context) => _buildHeader(context, logo, 'ক্রেতার বিস্তারিত রিপোর্ট'),
          footer: (context) => _buildFooter(context),
          build: (context) => [
            _buildSellerDetailContent(context, seller, sellerInvoices),
            ..._buildSellerInvoicesContent(context, sellerInvoices),
          ],
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            theme: pw.ThemeData.withFont(
              base: _bengaliFont ?? pw.Font.helvetica(),
              bold: _bengaliFontBold ?? pw.Font.helveticaBold(),
            ),
          ),
        ),
      );

      // Save PDF
      exportStatus.value = 'পিডিএফ সংরক্ষণ হচ্ছে...';
      final directory = await _getExportDirectory();
      final file = File('${directory.path}/${seller.name}_রিপোর্ট_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      isExporting.value = false;
      exportStatus.value = '';

      // Share file
      await Share.shareXFiles([XFile(file.path)], text: '${seller.name} এর রিপোর্ট');

      Get.snackbar('সফল', 'ক্রেতার রিপোর্ট এক্সপোর্ট হয়েছে', backgroundColor: Colors.green[100]);
    } catch (e) {
      isExporting.value = false;
      exportStatus.value = '';
      Get.snackbar('ত্রুটি', 'এক্সপোর্ট করতে সমস্যা হয়েছে: $e');
    }
  }

  // Build PDF header with logo and watermark
  pw.Widget _buildHeader(pw.Context context, pw.MemoryImage? logo, String title) {
    return pw.Container(
      padding: pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey.shade(300), width: 1),
        ),
      ),
      child: pw.Row(
        children: [
          if (logo != null)
            pw.Image(logo, width: 50, height: 50),
          pw.SizedBox(width: 15),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DokanMate',
                  style: pw.TextStyle(
                    font: _bengaliFontBold ?? pw.Font.helveticaBold(),
                    fontSize: 20,
                    color: PdfColors.blue.shade(700),
                  ),
                ),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: _bengaliFont ?? pw.Font.helvetica(),
                    fontSize: 16,
                    color: PdfColors.grey.shade(600),
                  ),
                ),
              ],
            ),
          ),
          pw.Text(
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
            style: pw.TextStyle(
              font: _bengaliFont ?? pw.Font.helvetica(),
              fontSize: 12,
              color: PdfColors.grey.shade(500),
            ),
          ),
        ],
      ),
    );
  }

  // Build PDF footer
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: pw.EdgeInsets.only(top: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey.shade(300), width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'DokanMate - আপনার ব্যবসার সহায়ক',
            style: pw.TextStyle(
              font: _bengaliFont ?? pw.Font.helvetica(),
              fontSize: 10,
              color: PdfColors.grey.shade(500),
            ),
          ),
          pw.Text(
            'পৃষ্ঠা ${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(
              font: _bengaliFont ?? pw.Font.helvetica(),
              fontSize: 10,
              color: PdfColors.grey.shade(500),
            ),
          ),
        ],
      ),
    );
  }

  // Build summary content
  pw.Widget _buildSummaryContent(pw.Context context) {
    final sellers = sellerController.sellers;
    final invoices = invoiceController.invoices;
    
    double totalSales = 0;
    double totalPaid = 0;
    double totalDue = 0;

    for (var invoice in invoices) {
      totalSales += invoice.totalAmount;
      totalPaid += invoice.amountPaid;
      totalDue += invoice.amountDue;
    }

    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'সারসংক্ষেপ',
            style: pw.TextStyle(
              font: _bengaliFontBold ?? pw.Font.helveticaBold(),
              fontSize: 16,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট ক্রেতা', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('${sellers.length}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট বিল', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('${invoices.length}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট বিক্রয়', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('৳${totalSales.toStringAsFixed(0)}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট পরিশোধিত', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('৳${totalPaid.toStringAsFixed(0)}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট বাকি', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('৳${totalDue.toStringAsFixed(0)}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build sellers content
  List<pw.Widget> _buildSellersContent(pw.Context context) {
    final sellers = sellerController.sellers;
    
    return [
      pw.Text(
        'ক্রেতাদের তালিকা',
        style: pw.TextStyle(
          font: _bengaliFontBold ?? pw.Font.helveticaBold(),
          fontSize: 16,
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey),
        columnWidths: {
          0: pw.FlexColumnWidth(2),
          1: pw.FlexColumnWidth(1.5),
          2: pw.FlexColumnWidth(2),
          3: pw.FlexColumnWidth(1),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text('নাম', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text('ফোন', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text('দোকান', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text('তারিখ', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
              ),
            ],
          ),
          // Data rows
          ...sellers.map((seller) => pw.TableRow(
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text(seller.name, style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text(seller.phone, style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text(seller.shopName ?? '-', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text(DateFormat('dd/MM/yyyy').format(seller.createdAt), style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
              ),
            ],
          )).toList(),
        ],
      ),
      pw.SizedBox(height: 30),
    ];
  }

  // Build invoices content
  List<pw.Widget> _buildInvoicesContent(pw.Context context) {
    final invoices = invoiceController.invoices;
    
    return [
      pw.Text(
        'বিলের তালিকা',
        style: pw.TextStyle(
          font: _bengaliFontBold ?? pw.Font.helveticaBold(),
          fontSize: 16,
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey),
        columnWidths: {
          0: pw.FlexColumnWidth(1),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(1),
          3: pw.FlexColumnWidth(1),
          4: pw.FlexColumnWidth(1),
          5: pw.FlexColumnWidth(1),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('বিল আইডি', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('ক্রেতা', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('ওজন', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('মূল্য', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('স্ট্যাটাস', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('তারিখ', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
            ],
          ),
          // Data rows
          ...invoices.map((invoice) {
            final seller = invoiceController.getSellerById(invoice.sellerId);
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(6),
                  child: pw.Text(invoice.id?.substring(0, 8) ?? 'N/A', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(6),
                  child: pw.Text(seller?.name ?? 'Unknown', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(6),
                  child: pw.Text('${invoice.kg} কেজি', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(6),
                  child: pw.Text('৳${invoice.totalAmount.toStringAsFixed(0)}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(6),
                  child: pw.Text(_getStatusText(invoice.status), style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(6),
                  child: pw.Text(DateFormat('dd/MM/yyyy').format(invoice.createdAt), style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    ];
  }

  // Build seller detail content
  pw.Widget _buildSellerDetailContent(pw.Context context, SellerModel seller, List<Invoice> invoices) {
    double totalSales = 0;
    double totalPaid = 0;
    double totalDue = 0;
    double totalKg = 0;
    int totalPieces = 0;

    for (var inv in invoices) {
      totalSales += inv.totalAmount;
      totalPaid += inv.amountPaid;
      totalDue += inv.amountDue;
      totalKg += inv.kg;
      totalPieces += inv.pieces.toInt();
    }

    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ক্রেতার তথ্য',
            style: pw.TextStyle(
              font: _bengaliFontBold ?? pw.Font.helveticaBold(),
              fontSize: 16,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('নাম', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(seller.name, style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('ফোন', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(seller.phone, style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              if (seller.shopName != null && seller.shopName!.isNotEmpty)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('দোকান', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(seller.shopName!, style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                    ),
                  ],
                ),
              if (seller.address != null && seller.address!.isNotEmpty)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('ঠিকানা', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(seller.address!, style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'বিক্রয় সারসংক্ষেপ',
            style: pw.TextStyle(
              font: _bengaliFontBold ?? pw.Font.helveticaBold(),
              fontSize: 16,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট বিল', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('${invoices.length}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট বিক্রয়', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('৳${totalSales.toStringAsFixed(0)}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট পরিশোধিত', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('৳${totalPaid.toStringAsFixed(0)}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট বাকি', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('৳${totalDue.toStringAsFixed(0)}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট ওজন', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('${totalKg.toStringAsFixed(1)} কেজি', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('মোট পিস', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold())),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('$totalPieces', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica())),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build seller invoices content
  List<pw.Widget> _buildSellerInvoicesContent(pw.Context context, List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return [
        pw.Text(
          'এই ক্রেতার কোনো বিল নেই',
          style: pw.TextStyle(
            font: _bengaliFont ?? pw.Font.helvetica(),
            fontSize: 14,
            color: PdfColors.grey,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ];
    }

    return [
      pw.Text(
        'বিলের তালিকা',
        style: pw.TextStyle(
          font: _bengaliFontBold ?? pw.Font.helveticaBold(),
          fontSize: 16,
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey),
        columnWidths: {
          0: pw.FlexColumnWidth(1),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(1),
          3: pw.FlexColumnWidth(1),
          4: pw.FlexColumnWidth(1),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('বিল আইডি', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('ওজন', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('মূল্য', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('স্ট্যাটাস', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('তারিখ', style: pw.TextStyle(font: _bengaliFontBold ?? pw.Font.helveticaBold(), fontSize: 10)),
              ),
            ],
          ),
          // Data rows
          ...invoices.map((invoice) => pw.TableRow(
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text(invoice.id?.substring(0, 8) ?? 'N/A', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('${invoice.kg} কেজি', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('৳${invoice.totalAmount.toStringAsFixed(0)}', style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text(_getStatusText(invoice.status), style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text(DateFormat('dd/MM/yyyy').format(invoice.createdAt), style: pw.TextStyle(font: _bengaliFont ?? pw.Font.helvetica(), fontSize: 10)),
              ),
            ],
          )).toList(),
        ],
      ),
    ];
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid': return 'পরিশোধিত';
      case 'partial': return 'আংশিক';
      case 'finalized': return 'বাকি';
      default: return 'খসড়া';
    }
  }
} 