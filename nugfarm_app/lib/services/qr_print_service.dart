import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/aset.dart';

class QrPrintService {
  // --- Cetak strip A4 (menu lama, tidak berubah) ---
  Future<void> cetakStiker(List<Aset> asetList) async {
    final doc = pw.Document();
    const mm = PdfPageFormat.mm;

    const stripHeight = 25 * mm;
    const gap = 2 * mm;
    const margin = 5 * mm;

    final usableHeight = PdfPageFormat.a4.availableHeight - (2 * margin);
    final perHalaman = (usableHeight / (stripHeight + gap)).floor();

    for (var start = 0; start < asetList.length; start += perHalaman) {
      final chunk = asetList.skip(start).take(perHalaman).toList();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(margin),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: chunk.expand((aset) {
                return [
                  pw.Container(
                    width: double.infinity,
                    height: stripHeight,
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4 * mm, vertical: 1 * mm),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 0.8),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: aset.kodeAset,
                          width: 20 * mm,
                          height: 20 * mm,
                        ),
                        pw.SizedBox(width: 8 * mm),
                        pw.Expanded(
                          child: pw.Text(
                            aset.kodeAset,
                            style: pw.TextStyle(
                              fontSize: 32,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: gap),
                ];
              }).toList(),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: 'stiker-qr-nugfarm-a4.pdf',
    );
  }

  // --- Cetak label roll untuk printer Zebra (10cm x 3cm, 1 label = 1 halaman) ---
  Future<void> cetakLabelZebra(List<Aset> asetList) async {
    final doc = pw.Document();
    const mm = PdfPageFormat.mm;

    const labelWidth = 100 * mm;
    const labelHeight = 30 * mm;
    const marginTepi = 3 * mm; // jarak garis border ke tepi kertas
    const borderWidth = 0.8 * mm; // ~3px
    const borderRadius = 2.5 * mm; // sudut membulat halus, proporsional untuk label 10x3cm
    const url = 'https://nugfarm-id.netlify.app';

    final pageFormat = PdfPageFormat(
      labelWidth,
      labelHeight,
      marginAll: 0,
    );

    for (final aset in asetList) {
      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Container(
              width: labelWidth,
              height: labelHeight,
              padding: const pw.EdgeInsets.all(marginTepi),
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 2 * mm, vertical: 1.5 * mm),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: borderWidth),
                  borderRadius: pw.BorderRadius.circular(borderRadius),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: aset.kodeAset,
                      width: 20 * mm,
                      height: 20 * mm,
                    ),
                    pw.SizedBox(width: 3 * mm),
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            aset.kodeAset,
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 1.5 * mm),
                          pw.Text(
                            aset.areaLahanNama ?? '-',
                            style: const pw.TextStyle(fontSize: 8),
                            maxLines: 1,
                            overflow: pw.TextOverflow.clip,
                          ),
                          pw.Text(
                            aset.areaLahanLokasi ?? '',
                            style: const pw.TextStyle(fontSize: 7),
                            maxLines: 1,
                            overflow: pw.TextOverflow.clip,
                          ),
                          pw.SizedBox(height: 1 * mm),
                          pw.Text(
                            url,
                            style: const pw.TextStyle(fontSize: 6.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: 'label-zebra-nugfarm.pdf',
      format: pageFormat,
    );
  }
}
