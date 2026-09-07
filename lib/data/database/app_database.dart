import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:simple_ledger/data/database/daos/accounts_dao.dart';
import 'package:simple_ledger/data/database/daos/recurring_dao.dart';
import 'package:simple_ledger/data/database/daos/transactions_dao.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get groupIndex => integer()();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false))();
  // 補助科目の親科目ID（nullなら独立科目）
  IntColumn get parentAccountId =>
      integer().nullable().references(Accounts, #id)();
}

class FinancialTransactions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().withLength(min: 1, max: 200)();
  TextColumn get memo =>
      text().withLength(max: 500).withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionId =>
      text().references(FinancialTransactions, #id)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get entryTypeIndex => integer()();
  RealColumn get amount => real()();
}

class RecurringRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get debitAccountId => integer().references(Accounts, #id)();
  IntColumn get creditAccountId => integer().references(Accounts, #id)();
  RealColumn get amount => real().nullable()();
  IntColumn get dayOfMonth => integer()();
  TextColumn get memo => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class RecurringLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ruleId => integer().references(RecurringRules, #id)();
  TextColumn get generatedFor => text()();
  TextColumn get transactionId => text().nullable()();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Accounts,
    FinancialTransactions,
    JournalEntries,
    RecurringRules,
    RecurringLogs,
  ],
  daos: [AccountsDao, TransactionsDao, RecurringDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaultAccounts();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await _insertAccountIfNotExists('PayPay', 0, 5);
            await _insertAccountIfNotExists('PayPayカード', 1, 3);
            await _insertAccountIfNotExists('書籍購入費', 3, 10);
          }
          if (from < 3) {
            await (update(accounts)
                  ..where((a) => a.name.equals('クレジットカード未払')))
                .write(const AccountsCompanion(groupIndex: Value(1)));
          }
          if (from < 4) {
            await (delete(accounts)
                  ..where((a) => a.name.equals('クレジットカード')))
                .go();
          }
          if (from < 5) {
            await m.createTable(recurringRules);
            await m.createTable(recurringLogs);
          }
          if (from < 6) {
            await customStatement(
              'ALTER TABLE accounts ADD COLUMN parent_account_id INTEGER REFERENCES accounts(id)',
            );
          }
        },
      );

  Future<void> _insertAccountIfNotExists(
      String name, int group, int order) async {
    final existing = await (select(accounts)
          ..where((a) => a.name.equals(name)))
        .getSingleOrNull();
    if (existing == null) {
      await into(accounts).insert(
        AccountsCompanion.insert(
          name: name,
          groupIndex: group,
          displayOrder: Value(order),
          isDefault: const Value(true),
        ),
      );
    }
  }

  Future<void> _seedDefaultAccounts() async {
    final defaults = [
      (name: '現金', group: 0, order: 1),
      (name: '普通預金', group: 0, order: 2),
      (name: '電子マネー', group: 0, order: 3),
      (name: 'PayPay', group: 0, order: 4),
      (name: 'クレジットカード未払', group: 1, order: 1),
      (name: 'ローン', group: 1, order: 3),
      (name: 'PayPayカード', group: 1, order: 4),
      (name: '元入金', group: 2, order: 1),
      (name: '食費', group: 3, order: 1),
      (name: '日用品費', group: 3, order: 2),
      (name: '交通費', group: 3, order: 3),
      (name: '外食費', group: 3, order: 4),
      (name: '光熱費', group: 3, order: 5),
      (name: '医療費', group: 3, order: 6),
      (name: '娯楽費', group: 3, order: 7),
      (name: '衣服費', group: 3, order: 8),
      (name: 'その他費用', group: 3, order: 9),
      (name: '書籍購入費', group: 3, order: 10),
      (name: '給与収入', group: 4, order: 1),
      (name: 'その他収入', group: 4, order: 2),
    ];

    for (final a in defaults) {
      await into(accounts).insert(
        AccountsCompanion.insert(
          name: a.name,
          groupIndex: a.group,
          displayOrder: Value(a.order),
          isDefault: const Value(true),
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return driftDatabase(name: 'simple_ledger.db');
  });
}
