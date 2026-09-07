import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_ledger/data/database/app_database.dart';
import 'package:simple_ledger/domain/services/recurring_service.dart';
import 'package:simple_ledger/presentation/providers/database_provider.dart';
import 'package:uuid/uuid.dart';

// 今回の起動で自動生成された件数（セッション限定）
final recurringSessionCountProvider = StateProvider<int>((ref) => 0);

final recurringRulesProvider = StreamProvider<List<RecurringRule>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.recurringDao.watchAllRules();
});

// 今月の変動費入力待ちルール
final pendingRecurringProvider =
    FutureProvider<List<PendingRecurringItem>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final key = RecurringService.monthKey(now);
  final pendingLogs = await db.recurringDao.getPendingLogsForMonth(key);

  final allRules = await db.recurringDao.getActiveRules();
  final ruleMap = {for (final r in allRules) r.id: r};

  final items = <PendingRecurringItem>[];
  for (final log in pendingLogs) {
    final rule = ruleMap[log.ruleId];
    if (rule == null) continue;
    final debit = await (db.select(db.accounts)
          ..where((a) => a.id.equals(rule.debitAccountId)))
        .getSingleOrNull();
    final credit = await (db.select(db.accounts)
          ..where((a) => a.id.equals(rule.creditAccountId)))
        .getSingleOrNull();
    if (debit != null && credit != null) {
      items.add(PendingRecurringItem(
        rule: rule,
        log: log,
        debitAccount: debit,
        creditAccount: credit,
      ));
    }
  }
  return items;
});

class PendingRecurringItem {
  final RecurringRule rule;
  final RecurringLog log;
  final Account debitAccount;
  final Account creditAccount;
  const PendingRecurringItem({
    required this.rule,
    required this.log,
    required this.debitAccount,
    required this.creditAccount,
  });
}

// CRUD
final addRecurringRuleProvider =
    Provider<Future<void> Function(RecurringRulesCompanion)>((ref) {
  final db = ref.watch(databaseProvider);
  return (rule) => db.recurringDao.insertRule(rule).then((_) {});
});

final updateRecurringRuleProvider =
    Provider<Future<void> Function(RecurringRule)>((ref) {
  final db = ref.watch(databaseProvider);
  return (rule) => db.recurringDao.updateRule(rule).then((_) {});
});

final deleteRecurringRuleProvider =
    Provider<Future<void> Function(int)>((ref) {
  final db = ref.watch(databaseProvider);
  return (id) => db.recurringDao.deleteRule(id).then((_) {});
});

// 変動費の金額入力完了 → 取引を作成してログを更新
final completeRecurringProvider =
    Provider<Future<void> Function(PendingRecurringItem, double)>((ref) {
  final db = ref.watch(databaseProvider);
  return (item, amount) async {
    const uuid = Uuid();
    final txId = uuid.v4();
    final now = DateTime.now();
    final txDate = DateTime(now.year, now.month, item.rule.dayOfMonth);
    await db.transactionsDao.insertTransactionWithEntries(
      transaction: FinancialTransactionsCompanion.insert(
        id: txId,
        date: txDate,
        description: item.rule.name,
        memo: Value(item.rule.memo),
      ),
      entries: [
        JournalEntriesCompanion.insert(
          transactionId: txId,
          accountId: item.rule.debitAccountId,
          entryTypeIndex: 0,
          amount: amount,
        ),
        JournalEntriesCompanion.insert(
          transactionId: txId,
          accountId: item.rule.creditAccountId,
          entryTypeIndex: 1,
          amount: amount,
        ),
      ],
    );
    await db.recurringDao.markLogComplete(item.log.id, txId);
    ref.invalidate(pendingRecurringProvider);
  };
});
