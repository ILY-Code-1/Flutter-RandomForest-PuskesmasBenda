/// PDF Service untuk Generate Tiket Antrian
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/queue_model.dart';

class PdfService {
  /// Generate dan download PDF tiket antrian
  static Future<void> generateAndDownloadTicket(QueueModel queue) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Text(
                  'SISTEM ANTRIAN ONLINE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'PUSKESMAS BENDA',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Nomor Antrian
                pw.Text(
                  'NOMOR ANTRIAN',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    queue.nomorAntrian,
                    style: pw.TextStyle(
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 15),

                // Poli Badge
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green700,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    queue.poli.toUpperCase(),
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Estimasi
                pw.Text(
                  'ESTIMASI WAKTU TUNGGU',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  _formatMinutes(queue.estimasiWaktuTunggu),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Perkiraan Dipanggil: ${DateFormat('HH:mm').format(queue.jamEfektifPelayanan)} WIB',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 15),

                // Data Pasien
                _buildInfoRow('Nama', queue.namaPasien),
                _buildInfoRow('Jenis Kelamin', queue.jenisKelamin),
                _buildInfoRow('Usia', '${queue.usia} tahun'),
                _buildInfoRow(
                  'Waktu Daftar',
                  DateFormat('dd/MM/yyyy HH:mm').format(queue.waktuDaftar),
                ),
                pw.SizedBox(height: 20),

                // Footer
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Harap datang 10 menit sebelum waktu panggil',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'Terima kasih telah menggunakan layanan kami',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    // Download PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'tiket_antrian_${queue.nomorAntrian}.pdf',
    );
  }

  /// Generate PDF untuk detail prediksi (admin)
  static Future<void> generatePredictionDetailPdf(QueueModel queue) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'DETAIL PREDIKSI ANTRIAN',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Nomor: ${queue.nomorAntrian}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Detail Input
                pw.Text(
                  'DETAIL INPUT',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildDetailRow('Poli', queue.poli),
                _buildDetailRow('Nama Pasien', queue.namaPasien),
                _buildDetailRow('Jenis Kelamin', queue.jenisKelamin),
                _buildDetailRow('Usia', '${queue.usia} tahun'),
                _buildDetailRow(
                  'Waktu Daftar',
                  DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id')
                      .format(queue.waktuDaftar),
                ),
                _buildDetailRow(
                  'Jumlah Antrian Sebelum',
                  '${queue.jumlahAntrianSebelum}',
                ),
                _buildDetailRow(
                  'Rata-rata Waktu Pelayanan',
                  '${queue.rataRataWaktuPelayanan} menit',
                ),
                pw.SizedBox(height: 20),

                // Hasil Prediksi Random Forest
                pw.Text(
                  'HASIL PREDIKSI RANDOM FOREST',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Detail pohon logika
                if (queue.predictionDetails != null &&
                    queue.predictionDetails!['treePredictions'] != null) ...[
                  ...((queue.predictionDetails!['treePredictions'] as List)
                      .map((tree) => _buildTreeRow(
                            tree['name'] as String,
                            '${tree['prediction']} menit',
                          ))),
                  pw.SizedBox(height: 10),
                  pw.Divider(),
                ],
                pw.SizedBox(height: 10),

                // Final Prediction
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'ESTIMASI WAKTU TUNGGU',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        _formatMinutes(queue.estimasiWaktuTunggu),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'PERKIRAAN DIPANGGIL',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${DateFormat('HH:mm:ss').format(queue.jamEfektifPelayanan)} WIB',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Status
                _buildDetailRow('Status', queue.statusAntrian),
                if (queue.waktuTungguAktual != null)
                  _buildDetailRow(
                    'Waktu Tunggu Aktual',
                    '${queue.waktuTungguAktual} menit',
                  ),

                // Footer
                pw.Spacer(),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Dokumen ini digenerate oleh Sistem Antrian Online Puskesmas Benda',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'detail_prediksi_${queue.nomorAntrian}.pdf',
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildTreeRow(String treeName, String prediction) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(treeName, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(prediction, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes menit';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours jam';
    }
    return '$hours jam $mins menit';
  }
}
