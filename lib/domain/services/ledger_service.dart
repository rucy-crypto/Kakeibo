import 'package:drift/drift.dart';
import 'package:simple_ledger/data/database/app_database.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 家計簿UI向けの入力種別
enum InputType {
  expense,  // 支出 (費用 / 資産)
  income,   // 収入 (資産 / 収益)
  transfer, // 振替 (資産 / 資産)
}

extension InputTypeExtension on InputType {
  String get displayName {
    switch (this) {
      case InputType.expense:
        return '支出';
      case InputType.income:
        return '収入';
      case InputType.transfer:
        return '振替';
    }
  }
}

/// 家計簿UI から受け取るシンプルな入力データ
class SimpleEntry {
  final InputType type;
  final int debitAccountId;   // 費用科目 or 振込先資産
  final int creditAccountId;  // 現金・預金などの資産 or 収益科目
  final double amount;
  final DateTime date;
  final String description;
  final String memo;

  SimpleEntry({
    required this.type,
    required this.debitAccountId,
    required this.creditAccountId,
    required this.amount,
    required this.date,
    required this.description,
    this.memo = '',
  });
}

/// 複式簿記ルールを適用して DB 挿入用データを生成するサービス
class LedgerService {
  /// SimpleEntry を検証し TransactionWithEntries 相当の Companion を返す
  ({
    FinancialTransactionsCompanion transaction,
    List<JournalEntriesCompanion> entries,
  })
  buildTransaction(SimpleEntry input) {
    assert(input.amount > 0, 'Amount must be positive');

    final txId = _uuid.v4();

    final transaction = FinancialTransactionsCompanion.insert(
      id: txId,
      date: input.date,
      description: input.description,
      memo: Value(input.memo),
    );

    // 借方エントリ
    final debit = JournalEntriesCompanion.insert(
      transactionId: txId,
      accountId: input.debitAccountId,
      entryTypeIndex: 0, // EntryType.debit
      amount: input.amount,
    );

    // 貸方エントリ
    final credit = JournalEntriesCompanion.insert(
      transactionId: txId,
      accountId: input.creditAccountId,
      entryTypeIndex: 1, // EntryType.credit
      amount: input.amount,
    );

    return (transaction: transaction, entries: [debit, credit]);
  }

  /// B/S 用の残高集計
  /// 資産はデビット増加、負債・純資産はクレジット増加なので符号調整
  Map<String, double> calcBalanceSheet({
    required List<Account> allAccounts,
    required Map<int, double> rawBalances, // debit - credit
  }) {
    final result = <String, double>{};
    for (final acc in allAccounts) {
      final group = AccountGroup.values[acc.groupIndex];
      if (!group.isBalanceSheet) continue;
      final raw = rawBalances[acc.id] ?? 0.0;
      // 資産: 借方増加 → raw がそのままプラス
      // 負債・純資産: 貸方増加 → raw は負の値になっている → 絶対値で表示
      result[acc.name] = group.normallyDebit ? raw : -raw;
    }
    return result;
  }

  /// P/L 用の集計
  Map<String, double> calcProfitAndLoss({
    required List<Account> allAccounts,
    required Map<int, double> rawBalances,
  }) {
    final result = <String, double>{};
    for (final acc in allAccounts) {
      final group = AccountGroup.values[acc.groupIndex];
      if (!group.isProfitAndLoss) continue;
      final raw = rawBalances[acc.id] ?? 0.0;
      // 費用: 借方増加 → raw がそのままプラス
      // 収益: 貸方増加 → raw は負 → 絶対値で表示
      result[acc.name] = group.normallyDebit ? raw : -raw;
    }
    return result;
  }
}
