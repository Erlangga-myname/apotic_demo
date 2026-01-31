import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/kasir/sales_transaction.dart';

class ReceiptPrinter {
  static Future<void> printReceipt(BuildContext context, SalesTransaction transaction) async {
    final pdf = pw.Document();

    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'APOTIK Apotic',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Jl. Contoh No. 123, Kota',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Telp: (021) 1234567',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Divider(),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Transaction Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('No. Struk: ${transaction.receiptNumber ?? transaction.id?.substring(0, 8)}'),
                    pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text('Kasir: ${transaction.cashierName}'),
                pw.Text('Metode Bayar: ${transaction.paymentMethod}'),
                pw.SizedBox(height: 20),

                // Items Header
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(vertical: 5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 1)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('Harga', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 2, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                ),

                // Items List
                pw.ListView.builder(
                  itemCount: transaction.items.length,
                  itemBuilder: (context, index) {
                    final item = transaction.items[index];
                    return pw.Container(
                      padding: pw.EdgeInsets.symmetric(vertical: 5),
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.Text(item.itemName)),
                          pw.Expanded(flex: 1, child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center)),
                          pw.Expanded(flex: 2, child: pw.Text(currencyFormat.format(item.price), textAlign: pw.TextAlign.right)),
                          pw.Expanded(flex: 2, child: pw.Text(currencyFormat.format(item.subtotal), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    );
                  },
                ),

                pw.SizedBox(height: 20),
                pw.Divider(),

                // Totals
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Pembelian:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(currencyFormat.format(transaction.totalAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Jumlah Bayar:'),
                          pw.Text(currencyFormat.format(transaction.paidAmount)),
                        ],
                      ),
                      if (transaction.changeAmount > 0) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Kembalian:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(currencyFormat.format(transaction.changeAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Footer
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Terima Kasih Atas Kunjungan Anda',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Semoga Lekas Sembuh',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Barang yang sudah dibeli tidak dapat dikembalikan',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Print the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> shareReceipt(BuildContext context, SalesTransaction transaction) async {
    final pdf = pw.Document();

    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'APOTIK Apotic',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Jl. Contoh No. 123, Kota',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Telp: (021) 1234567',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Divider(),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Transaction Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('No. Struk: ${transaction.receiptNumber ?? transaction.id?.substring(0, 8)}'),
                    pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text('Kasir: ${transaction.cashierName}'),
                pw.Text('Metode Bayar: ${transaction.paymentMethod}'),
                pw.SizedBox(height: 20),

                // Items Header
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(vertical: 5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 1)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('Harga', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 2, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                ),

                // Items List
                pw.ListView.builder(
                  itemCount: transaction.items.length,
                  itemBuilder: (context, index) {
                    final item = transaction.items[index];
                    return pw.Container(
                      padding: pw.EdgeInsets.symmetric(vertical: 5),
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.Text(item.itemName)),
                          pw.Expanded(flex: 1, child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center)),
                          pw.Expanded(flex: 2, child: pw.Text(currencyFormat.format(item.price), textAlign: pw.TextAlign.right)),
                          pw.Expanded(flex: 2, child: pw.Text(currencyFormat.format(item.subtotal), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    );
                  },
                ),

                pw.SizedBox(height: 20),
                pw.Divider(),

                // Totals
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Pembelian:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(currencyFormat.format(transaction.totalAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Jumlah Bayar:'),
                          pw.Text(currencyFormat.format(transaction.paidAmount)),
                        ],
                      ),
                      if (transaction.changeAmount > 0) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Kembalian:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(currencyFormat.format(transaction.changeAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Footer
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Terima Kasih Atas Kunjungan Anda',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Semoga Lekas Sembuh',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Barang yang sudah dibeli tidak dapat dikembalikan',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Share the PDF
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'struk-${transaction.receiptNumber ?? transaction.id}.pdf');
  }
}
