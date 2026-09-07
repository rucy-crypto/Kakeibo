import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_ledger/data/database/app_database.dart';
import 'package:simple_ledger/data/database/daos/transactions_dao.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:simple_ledger/presentation/providers/accounts_provider.dart';
import 'package:simple_ledger/presentation/providers/database_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final transactionsWithEntriesProvider =
    StreamProvider<List<TransactionWithEntries>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.transactionsDao.watchAllTransactionsWithEntries();
});

final addJournalProvider = Provider<
    Future<void> Function({
      required DateTime date,
      required String description,
      required String memo,
      required List<({int accountId, int entryTypeIndex, double amount})>
          entries,
    })>((ref) {
  final db = ref.watch(databaseProvider);
  return ({
    required DateTime date,
    required String description,
    required String memo,
    required List<({int accountId, int entryTypeIndex, double amount})> entries,
  }) async {
    final txId = _uuid.v4();
    final tx = FinancialTransactionsCompanion.insert(
      id: txId,
      date: date,
      description: description,
      memo: Value(memo),
    );
    final journalEntries = entries
        .map((e) => JournalEntriesCompanion.insert(
              transactionId: txId,
              accountId: e.accountId,
              entryTypeIndex: e.entryTypeIndex,
              amount: e.amount,
            ))
        .toList();
    await db.transactionsDao.insertTransactionWithEntries(
      transaction: tx,
      entries: journalEntries,
    );
  };
});

final updateJournalProvider = Provider<
    Future<void> Function({
      required String transactionId,
      required DateTime date,
      required String description,
      required String memo,
      required List<({int accountId, int entryTypeIndex, double amount})>
          entries,
    })>((ref) {
  final db = ref.watch(databaseProvider);
  return ({
    required String transactionId,
    required DateTime date,
    required String description,
    required String memo,
    required List<({int accountId, int entryTypeIndex, double amount})> entries,
  }) async {
    final tx = FinancialTransactionsCompanion(
      date: Value(date),
      description: Value(description),
      memo: Value(memo),
    );
    final journalEntries = entries
        .map((e) => JournalEntriesCompanion.insert(
              transactionId: transactionId,
              accountId: e.accountId,
              entryTypeIndex: e.entryTypeIndex,
              amount: e.amount,
            ))
        .toList();
    await db.transactionsDao.updateTransactionWithEntries(
      transaction: tx,
      entries: journalEntries,
      transactionId: transactionId,
    );
  };
});

final deleteTransactionProvider =
    Provider<Future<void> Function(String)>((ref) {
  final db = ref.watch(databaseProvider);
  return (String txId) => db.transactionsDao.deleteTransactionWithEntries(txId);
});

final selectedHomeMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final monthTransactionsProvider =
    StreamProvider<List<TransactionWithEntries>>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedHomeMonthProvider);
  return db.transactionsDao
      .watchTransactionsInMonth(month.year, month.month)
      .asyncMap((txList) async {
    final result = <TransactionWithEntries>[];
    for (final tx in txList) {
      final w = await db.transactionsDao.getTransactionWithEntries(tx.id);
      if (w != null) result.add(w);
    }
    return result;
  });
});

enum SearchSort { dateDesc, dateAsc, amountDesc, amountAsc }

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchAccountQueryProvider = StateProvider<String>((ref) => '');
final searchStartDateProvider = StateProvider<DateTime?>((ref) => null);
final searchEndDateProvider = StateProvider<DateTime?>((ref) => null);
final searchSortProvider = StateProvider<SearchSort>((ref) => SearchSort.dateDesc);

// グループ名 → AccountGroup の完全一致マップ
const _groupByName = {
  '資産': AccountGroup.asset,
  '負債': AccountGroup.liability,
  '純資産': AccountGroup.equity,
  '費用': AccountGroup.expense,
  '収益': AccountGroup.revenue,
};

/// 科目名フィルターにマッチする勘定科目IDセット（子勘定含む）。
/// null = フィルター未設定、空セット = フィルター設定済みだが一致なし。
final searchMatchingAccountIdsProvider = Provider<Set<int>?>((ref) {
  final q = ref.watch(searchAccountQueryProvider).trim().toLowerCase();
  if (q.isEmpty) return null;

  final allAccounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
  final group = _groupByName[q];

  // 直接マッチ（名前の部分一致 or グループ名完全一致）
  final directIds = allAccounts.where((a) {
    if (a.name.toLowerCase().contains(q)) return true;
    if (group != null && a.groupIndex == group.index) return true;
    return false;
  }).map((a) => a.id).toSet();

  // 直接マッチした科目の子勘定も追加
  final allIds = Set<int>.from(directIds);
  for (final a in allAccounts) {
    if (a.parentAccountId != null && directIds.contains(a.parentAccountId)) {
      allIds.add(a.id);
    }
  }
  return allIds;
});

final searchResultsProvider =
    Provider<AsyncValue<List<TransactionWithEntries>>>((ref) {
  final rawQuery = ref.watch(searchQueryProvider).trim().toLowerCase();
  final matchingIds = ref.watch(searchMatchingAccountIdsProvider);
  final startDate = ref.watch(searchStartDateProvider);
  final endDate = ref.watch(searchEndDateProvider);
  final sort = ref.watch(searchSortProvider);

  // スペース区切りでトークン化 → 全トークンにマッチ（AND検索）
  final tokens = rawQuery.isEmpty
      ? <String>[]
      : rawQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  return ref.watch(transactionsWithEntriesProvider).whenData((list) {
    var filtered = list.where((t) {
      // 取引検索：説明文・メモのみ（科目名は対象外）
      if (tokens.isNotEmpty) {
        final matches = tokens.every((token) =>
            t.transaction.description.toLowerCase().contains(token) ||
            t.transaction.memo.toLowerCase().contains(token));
        if (!matches) return false;
      }
      // 科目名検索：matchingIds を使用（親子関係含む）
      if (matchingIds != null) {
        if (matchingIds.isEmpty) return false;
        if (!t.entries.any((e) => matchingIds.contains(e.account.id))) {
          return false;
        }
      }
      if (startDate != null) {
        final txDay = DateTime(t.transaction.date.year,
            t.transaction.date.month, t.transaction.date.day);
        final startDay =
            DateTime(startDate.year, startDate.month, startDate.day);
        if (txDay.isBefore(startDay)) return false;
      }
      if (endDate != null) {
        final txDay = DateTime(t.transaction.date.year,
            t.transaction.date.month, t.transaction.date.day);
        final endDay = DateTime(endDate.year, endDate.month, endDate.day);
        if (txDay.isAfter(endDay)) return false;
      }
      return true;
    }).toList();

    switch (sort) {
      case SearchSort.dateDesc:
        filtered.sort(
            (a, b) => b.transaction.date.compareTo(a.transaction.date));
      case SearchSort.dateAsc:
        filtered.sort(
            (a, b) => a.transaction.date.compareTo(b.transaction.date));
      case SearchSort.amountDesc:
        filtered.sort((a, b) {
          final aAmt = a.entries.fold(0.0, (s, e) =>
              e.entry.entryTypeIndex == 0 ? s + e.entry.amount : s);
          final bAmt = b.entries.fold(0.0, (s, e) =>
              e.entry.entryTypeIndex == 0 ? s + e.entry.amount : s);
          return bAmt.compareTo(aAmt);
        });
      case SearchSort.amountAsc:
        filtered.sort((a, b) {
          final aAmt = a.entries.fold(0.0, (s, e) =>
              e.entry.entryTypeIndex == 0 ? s + e.entry.amount : s);
          final bAmt = b.entries.fold(0.0, (s, e) =>
              e.entry.entryTypeIndex == 0 ? s + e.entry.amount : s);
          return aAmt.compareTo(bAmt);
        });
    }
    return filtered;
  });
});
