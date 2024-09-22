
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import "package:indian_currency_to_word/indian_currency_to_word.dart";
import '../const/const.dart';
import '../model/bill_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
class PDFPage extends StatefulWidget {
  final Bill bill;
  PDFPage({required this.bill});
  @override
  State<PDFPage> createState() => PDFPageState();
}

class PDFPageState extends State<PDFPage> {


  late Future<Uint8List> logoFuture;
  late Future<Uint8List> signImageFuture;

  @override
  void initState() {
    super.initState();
    logoFuture = readImageDataAsset('logo.png');
    signImageFuture = readImageDataAsset('pdf_stamp.png');
  }

  final converter = AmountToWords();
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${date.day}-${months[date.month - 1]}-${date.year}";
  }


  Future<Uint8List> createInvoicePdf(PdfPageFormat format) async {
  //final font = await PdfGoogleFonts.nunitoExtraLight();
  final Logo = await logoFuture;
  final SignImage = await signImageFuture;
  final pdf = pw.Document();

  final itemsPerPage = 10;
  final totalPages = (widget.bill.tests.length / itemsPerPage).ceil();

  for (int pageNum = 0; pageNum < totalPages; pageNum++) {
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (pageNum == 0) ...[
                  _buildHeaderSection(Logo),
                  _buildBillToAndInvoiceDetailsSection(),
                  _buildCustomerAndInvoiceInfoSection(),
                ],
                _buildItemsTable(context, pageNum, itemsPerPage),
                if (pageNum == totalPages - 1) ...[
                  _buildTotalAmountSection(),
                  _buildTermsAndSignatureSection(SignImage),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  return pdf.save();
}

  pw.Widget _buildHeaderSection(Uint8List Logo) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.0),
      ),
      padding: pw.EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Container(
            width: 150,
            height: 100,
            child: pw.Image(pw.MemoryImage(Logo))
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('S.S PATHOLOGY & DIAGNOSTIC CENTRE', style: Const.boldStyle),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Shop no 18,Eden Appts, Opp baker point, Powerhouse, Aquem ,Margao Goa',
                  style: Const.normalStyle,
                  textAlign: pw.TextAlign.right,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Phone no.: 8446500197 Email: s.spathologygoa@gmail.com',
                  style: Const.normalStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBillToAndInvoiceDetailsSection() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF3E5A94),
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
          left: pw.BorderSide(color: PdfColors.black, width: 1.0),
          right: pw.BorderSide(color: PdfColors.black, width: 1.0),
          top: pw.BorderSide(color: PdfColors.black, width: 1.0),
        ),
      ),
      padding: pw.EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text('Bill To', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
          ),
          pw.Container(width: 1, height: 20, color: PdfColors.black),
          pw.Expanded(
            child: pw.Text('Invoice Details', style: pw.TextStyle(fontSize: 9, color: PdfColors.white), textAlign: pw.TextAlign.right),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCustomerAndInvoiceInfoSection() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
          left: pw.BorderSide(color: PdfColors.black, width: 1.0),
          right: pw.BorderSide(color: PdfColors.black, width: 1.0),
        ),
      ),
      padding: pw.EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(widget.bill.patientName, style: Const.normalStyle),
                pw.SizedBox(height: 7),
                widget.bill.patientNumber.isNotEmpty ?
                pw.Text('Contact No. : ${widget.bill.patientNumber} ', style: Const.normalStyle)
                :pw.Text('', style: Const.normalStyle)
                ,
              ],
            ),
          ),
          pw.Container(width: 1.0, height: 40, color: PdfColors.black),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Invoice No. : ${widget.bill.id}', style: Const.normalBoldStyle),
                pw.SizedBox(height: 7),
                // pw.Text('Date : ${widget.bill.created.toString().split(' ')[0]}', style: Const.normalStyle),
                pw.Text('Date : ${_formatDate(widget.bill.created)}', style: Const.normalStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

 pw.Widget _buildItemsTable(pw.Context context, int pageNum, int itemsPerPage) {
  final startIndex = pageNum * itemsPerPage;
  final endIndex = math.min(startIndex + itemsPerPage, widget.bill.tests.length);
  final pageItems = widget.bill.tests.sublist(startIndex, endIndex);
  int totalQuantity = 0;
  for (TestItem item in widget.bill.tests) {
    totalQuantity += item.quantity;
  }
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
      ),
    ),
    child: pw.Table.fromTextArray(
      context: context,
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold,color: PdfColors.white),
      cellStyle: Const.normalStyle,
      cellAlignment: pw.Alignment.center,
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF3E5A94)),
      data: <List<String>>[
        <String>['#', 'Item name', 'HSN/ SAC', 'Quantity', 'Price/ Unit', 'Amount'],
        ...pageItems.asMap().entries.map((entry) {
          int index = startIndex + entry.key;
          TestItem test = entry.value;
          return <String>[
            '${index + 1}',
            test.name,
            '',
            test.quantity.toString(),
            'Rs ${test.price.toStringAsFixed(2)}',
            'Rs ${(test.price * test.quantity).toStringAsFixed(2)}'
          ];
        }).toList(),
        if (pageNum == (widget.bill.tests.length / itemsPerPage).ceil() - 1)
          <String>['', 'Total', '', totalQuantity.toString(), '', 'Rs ${widget.bill.subTotalAmount.toStringAsFixed(2)}'],
      ],
    ),
  );
}

  pw.Widget _buildTotalAmountSection() {
    return pw.Column(
      children: [
        _buildTotalAmountHeader(),
        _buildTotalAmountContent(),
      ],
    );
  }

  pw.Widget _buildTotalAmountHeader() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF3E5A94),
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
          left: pw.BorderSide(color: PdfColors.black, width: 1.0),
          right: pw.BorderSide(color: PdfColors.black, width: 1.0),
          top: pw.BorderSide(color: PdfColors.black, width: 1.0),
        ),
      ),
      padding: pw.EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text('Invoice Amount In Words', style: pw.TextStyle(fontSize: 9, color: PdfColors.white), textAlign: pw.TextAlign.center),
          ),
          pw.Container(width: 1.0, height: 22, color: PdfColors.black),
          pw.Expanded(
            child: pw.Padding(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text('Amount', style: pw.TextStyle(fontSize: 9, color: PdfColors.white), textAlign: pw.TextAlign.left),
              )
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTotalAmountContent() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
          left: pw.BorderSide(color: PdfColors.black, width: 1.0),
          right: pw.BorderSide(color: PdfColors.black, width: 1.0),
          top: pw.BorderSide(color: PdfColors.black, width: 1.0),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  alignment: pw.Alignment.topCenter,
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text('${converter.convertAmountToWords(widget.bill.totalAmount)} Only', style: Const.normalWordsStyle),
                ),
                pw.SizedBox(height: 45),
              ],
            ),
          ),
          pw.Expanded(
            child: _buildAmountBreakdown(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAmountBreakdown() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildAmountRow('Sub Total: ', widget.bill.subTotalAmount),
          _buildAmountRow('Discount: ', widget.bill.discount),
          _buildAmountRow('Total: ', widget.bill.totalAmount),
          _buildAmountRow('Received: ', widget.bill.paidAmount),
          _buildAmountRow('Balance: ', widget.bill.pendingAmount, isLast: true),
        ],
      ),
    );
  }

  pw.Widget _buildAmountRow(String label, double amount, {bool isLast = false}) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: pw.EdgeInsets.all(5),
      width: double.infinity,
      decoration: isLast ? null : pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: Const.normalStyle),
          pw.Text('Rs ${amount.toStringAsFixed(2)}', style: Const.normalStyle),
        ],
      ),
    );
  }

  pw.Widget _buildTermsAndSignatureSection(Uint8List SignImage) {
    return pw.Column(
      children: [
        _buildTermsHeader(),
        _buildTermsAndSignatureContent(SignImage),
      ],
    );
  }

  pw.Widget _buildTermsHeader() {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: pw.EdgeInsets.all(5),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF3E5A94),
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
                top: pw.BorderSide(color: PdfColors.black, width: 1.0),
                left: pw.BorderSide(color: PdfColors.black, width: 1.0),
              ),
            ),
            child: pw.Text('Terms and Conditions', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
          ),
        ),
        pw.SizedBox(width: 1.0, height: 20, child: pw.Container(color: PdfColors.black)),
        pw.Expanded(child: pw.Container(
          height: 20,
          decoration: pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(color: PdfColors.black, width: 1.0),
              ),
            ),
        )),
      ],
    );
  }

  pw.Widget _buildTermsAndSignatureContent(Uint8List SignImage) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
          left: pw.BorderSide(color: PdfColors.black, width: 1.0),
          right: pw.BorderSide(color: PdfColors.black, width: 1.0),
        ),
      ),
      padding: pw.EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text('Thanks for your trust! \nWe Care For Your Heath!', style: Const.normalStyle, textAlign: pw.TextAlign.left),
          ),
          pw.Container(width: 1.0, height: 100, color: PdfColors.black),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('For : S.S PATHOLOGY & DIAGNOSTIC CENTRE', style: Const.normalStyle),
                pw.Container(
                  width: 100,
                  height: 50,
                  margin: pw.EdgeInsets.all(10),
                  child: pw.Image(pw.MemoryImage(SignImage)),
                ),
                pw.Text('Authorized Signatory', style: Const.normalStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Generated'),
        centerTitle: true,
      ),
      body: FutureBuilder<Uint8List>(
        future: createInvoicePdf(PdfPageFormat.a4),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) { 
            return PdfPreview(
              dpi: 72,
              maxPageWidth: 350,
              previewPageMargin: EdgeInsets.all(10),
              useActions: true,
              allowPrinting: true,
              allowSharing: true,
              canDebug: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              pdfFileName: 'invoice_${widget.bill.id}${widget.bill.patientName}${DateFormat('yyyy-MM-dd HH:mm').format(widget.bill.created)}.pdf',
              build: (format) => snapshot.data!,
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: ()async{
        sharePdf(context);
      },
      child: Icon(Icons.share),
      ),
    );
  }

Future<void> sharePdf(BuildContext context) async {
  try {
      // Convert PDF to Uint8List
      final pdfBytes = await createInvoicePdf(PdfPageFormat.a4);

  } catch (e) {
    // Handle any errors that occur during the PDF generation and saving process.
    print('Error saving PDF: $e');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save PDF: $e'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
  
  Future<Uint8List> readImageDataAsset(String name) async {
    final data = await rootBundle.rootBundle.load('assets/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  // Converting Network Image in Uint8List
  Future<Uint8List> readImageDataUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    return response.bodyBytes;
  }
}