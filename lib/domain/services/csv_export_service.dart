import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_ledger/data/database/daos/transactions_dao.dart';

final _dateFmt = DateFormat('yyyy/MM/dd');

class CsvExportService {
  Future<void> exportAndShare(List<TransactionWithEntries> transactions) async {
    final rows = <List<dynamic>>[
      // ヘッダー
      ['日付', '取引ID', '内容', 'メモ', '借貸', '科目', '金額'],
    ];

    for (final tx in transactions) {
      for (final e in tx.entries) {
        rows.add([
          _dateFmt.format(tx.transaction.date),
          tx.transaction.id,
          tx.transaction.description,
          tx.transaction.memo,
          e.entry.entryTypeIndex == 0 ? '借方' : '貸方',
          e.account.name,
          e.entry.amount.toStringAsFixed(0),
        ]);
      }
    }

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/simple_ledger_export.csv');
    await file.writeAsString('\uFEFF$csv'); // BOM付きUTF-8（Excel対応）

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Simple Ledger 仕訳データ',
    );
  }
}
