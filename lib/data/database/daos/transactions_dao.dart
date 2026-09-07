import 'package:drift/drift.dart';
import 'package:simple_ledger/data/database/app_database.dart';

part 'transactions_dao.g.dart';

class JournalEntryWithAccount {
  final JournalEntry entry;
  final Account account;
  JournalEntryWithAccount({required this.entry, required this.account});
}

class TransactionWithEntries {
  final FinancialTransaction transaction;
  final List<JournalEntryWithAccount> entries;
  TransactionWithEntries({required this.transaction, required this.entries});
}

@DriftAccessor(tables: [FinancialTransactions, JournalEntries, Accounts])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Stream<List<FinancialTransaction>> watchTransactionsInMonth(
      int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (select(financialTransactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<TransactionWithEntries>> watchAllTransactionsWithEntries() {
    return (select(financialTransactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch()
        .asyncMap((txList) async {
      final result = <TransactionWithEntries>[];
      for (final tx in txList) {
        final w = await getTransactionWithEntries(tx.id);
        if (w != null) result.add(w);
      }
      return result;
    });
  }

  Future<TransactionWithEntries?> getTransactionWithEntries(String txId) async {
    final tx = await (select(financialTransactions)
          ..where((t) => t.id.equals(txId)))
        .getSingleOrNull();
    if (tx == null) return null;

    final rawEntries = await (select(journalEntries)
          ..where((e) => e.transactionId.equals(txId)))
        .get();

    final entriesWithAccount = <JournalEntryWithAccount>[];
    for (final e in rawEntries) {
      final acc = await (select(accounts)
            ..where((a) => a.id.equals(e.accountId)))
          .getSingleOrNull();
      if (acc != null) {
        entriesWithAccount.add(JournalEntryWithAccount(entry: e, account: acc));
      }
    }
    return TransactionWithEntries(transaction: tx, entries: entriesWithAccount);
  }

  Future<void> insertTransactionWithEntries({
    required FinancialTransactionsCompanion transaction,
    required List<JournalEntriesCompanion> entries,
  }) async {
    await db.transaction(() async {
      await into(financialTransactions).insert(transaction);
      for (final e in entries) {
        await into(journalEntries).insert(e);
      }
    });
  }

  Future<void> updateTransactionWithEntries({
    required FinancialTransactionsCompanion transaction,
    required List<JournalEntriesCompanion> entries,
    required String transactionId,
  }) async {
    await db.transaction(() async {
      await (update(financialTransactions)
            ..where((t) => t.id.equals(transactionId)))
          .write(transaction);
      await (delete(journalEntries)
            ..where((e) => e.transactionId.equals(transactionId)))
          .go();
      for (final e in entries) {
        await into(journalEntries).insert(e);
      }
    });
  }

  Future<void> deleteTransactionWithEntries(String transactionId) async {
    await db.transaction(() async {
      await (delete(journalEntries)
            ..where((e) => e.transactionId.equals(transactionId)))
          .go();
      await (delete(financialTransactions)
            ..where((t) => t.id.equals(transactionId)))
          .go();
    });
  }

  Future<Map<int, double>> getAccountBalances({
    DateTime? from,
    DateTime? to,
  }) async {
    final allTx = await (select(financialTransactions)
          ..where((t) {
            if (from != null && to != null) {
              return t.date.isBetweenValues(from, to);
            } else if (from != null) {
              return t.date.isBiggerOrEqualValue(from);
            } else if (to != null) {
              return t.date.isSmallerOrEqualValue(to);
            }
            return const Constant(true);
          }))
        .get();

    final balances = <int, double>{};
    for (final tx in allTx) {
      final entries = await (select(journalEntries)
            ..where((e) => e.transactionId.equals(tx.id)))
          .get();
      for (final e in entries) {
        final current = balances[e.accountId] ?? 0.0;
        balances[e.accountId] =
            e.entryTypeIndex == 0 ? current + e.amount : current - e.amount;
      }
    }
    return balances;
  }
}
