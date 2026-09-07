import 'package:drift/drift.dart';
import 'package:simple_ledger/data/database/app_database.dart';

part 'recurring_dao.g.dart';

@DriftAccessor(tables: [RecurringRules, RecurringLogs, Accounts])
class RecurringDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringDaoMixin {
  RecurringDao(super.db);

  Stream<List<RecurringRule>> watchAllRules() =>
      (select(recurringRules)
            ..orderBy([(r) => OrderingTerm.asc(r.dayOfMonth)]))
          .watch();

  Future<List<RecurringRule>> getActiveRules() =>
      (select(recurringRules)
            ..where((r) => r.isActive.equals(true))
            ..orderBy([(r) => OrderingTerm.asc(r.dayOfMonth)]))
          .get();

  Future<int> insertRule(RecurringRulesCompanion rule) =>
      into(recurringRules).insert(rule);

  Future<bool> updateRule(RecurringRule rule) =>
      update(recurringRules).replace(rule);

  Future<int> deleteRule(int id) =>
      (delete(recurringRules)..where((r) => r.id.equals(id))).go();

  Future<List<RecurringLog>> getLogsForMonth(String yyyyMm) =>
      (select(recurringLogs)
            ..where((l) => l.generatedFor.equals(yyyyMm)))
          .get();

  Future<List<RecurringLog>> getPendingLogsForMonth(String yyyyMm) =>
      (select(recurringLogs)
            ..where((l) =>
                l.generatedFor.equals(yyyyMm) & l.transactionId.isNull()))
          .get();

  Future<int> insertLog(RecurringLogsCompanion log) =>
      into(recurringLogs).insert(log);

  Future<void> markLogComplete(int logId, String transactionId) =>
      (update(recurringLogs)..where((l) => l.id.equals(logId)))
          .write(RecurringLogsCompanion(transactionId: Value(transactionId)));
}
