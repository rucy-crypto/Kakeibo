import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_ledger/data/database/app_database.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:simple_ledger/presentation/providers/accounts_provider.dart';
import 'package:simple_ledger/presentation/providers/database_provider.dart';
import 'package:simple_ledger/presentation/providers/transactions_provider.dart';

class ReportPeriod {
  final int year;
  final int? month;
  const ReportPeriod({required this.year, this.month});
  DateTime get from =>
      month != null ? DateTime(year, month!, 1) : DateTime(year, 1, 1);
  DateTime get to =>
      month != null ? DateTime(year, month! + 1, 1) : DateTime(year + 1, 1, 1);
  String get label =>
      month != null ? '$year年${month!}月' : '$year年';
}

final selectedReportPeriodProvider =
    StateProvider<ReportPeriod>((ref) {
  final now = DateTime.now();
  return ReportPeriod(year: now.year, month: now.month);
});

final rawBalancesProvider =
    FutureProvider.autoDispose<Map<int, double>>((ref) async {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(selectedReportPeriodProvider);
  return db.transactionsDao.getAccountBalances(
    from: period.from,
    to: period.to,
  );
});

final allTimeRawBalancesProvider =
    FutureProvider.autoDispose<Map<int, double>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.transactionsDao.getAccountBalances();
});

class BSItem {
  final Account account;
  final double ownBalance;
  final double subtotalBalance;
  final List<BSItem> children;

  const BSItem({
    required this.account,
    required this.ownBalance,
    required this.subtotalBalance,
    this.children = const [],
  });
}

class BalanceSheetData {
  final Map<AccountGroup, List<BSItem>> items;
  final double totalAssets;
  final double totalLiabilities;
  final double totalEquity;
  final double netIncome; // 累計当期純利益（収益 - 費用、全期間）
  final double netAssets;

  BalanceSheetData({
    required this.items,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalEquity,
    required this.netIncome,
    required this.netAssets,
  });

  // 純資産の部合計（元入金 + 当期純利益）
  double get totalEquityWithIncome => totalEquity + netIncome;
}

class ProfitLossData {
  final List<({Account account, double amount})> revenues;
  final List<({Account account, double amount})> expenses;
  final double totalRevenue;
  final double totalExpense;
  final double netIncome;

  ProfitLossData({
    required this.revenues,
    required this.expenses,
    required this.totalRevenue,
    required this.totalExpense,
    required this.netIncome,
  });
}

final balanceSheetProvider =
    FutureProvider.autoDispose<BalanceSheetData>((ref) async {
  final allAccounts = await ref.watch(accountsStreamProvider.future);
  final balances = await ref.watch(allTimeRawBalancesProvider.future);

  final bsGroups = [
    AccountGroup.asset,
    AccountGroup.liability,
    AccountGroup.equity,
  ];

  final items = <AccountGroup, List<BSItem>>{};
  for (final g in bsGroups) {
    final groupAccounts =
        allAccounts.where((a) => a.groupIndex == g.index).toList();
    final groupIds = groupAccounts.map((a) => a.id).toSet();

    // 子科目マップを構築
    final childrenOf = <int, List<Account>>{};
    for (final a in groupAccounts) {
      if (a.parentAccountId != null && groupIds.contains(a.parentAccountId)) {
        childrenOf.putIfAbsent(a.parentAccountId!, () => []).add(a);
      }
    }

    // ルート科目（親なし、または親が同グループにない）
    final roots = groupAccounts
        .where((a) =>
            a.parentAccountId == null ||
            !groupIds.contains(a.parentAccountId))
        .toList();

    final bsItems = <BSItem>[];
    for (final root in roots) {
      final raw = balances[root.id] ?? 0.0;
      final ownBalance = g.normallyDebit ? raw : -raw;

      final childItems = <BSItem>[];
      for (final child in childrenOf[root.id] ?? []) {
        final childRaw = balances[child.id] ?? 0.0;
        final childBalance = g.normallyDebit ? childRaw : -childRaw;
        if (childBalance > 0) {
          childItems.add(BSItem(
            account: child,
            ownBalance: childBalance,
            subtotalBalance: childBalance,
          ));
        }
      }

      final subtotal =
          ownBalance + childItems.fold(0.0, (s, c) => s + c.subtotalBalance);
      if (subtotal > 0) {
        bsItems.add(BSItem(
          account: root,
          ownBalance: ownBalance,
          subtotalBalance: subtotal,
          children: childItems,
        ));
      }
    }
    items[g] = bsItems;
  }

  final totalAssets =
      items[AccountGroup.asset]!.fold(0.0, (s, e) => s + e.subtotalBalance);
  final totalLiabilities =
      items[AccountGroup.liability]!.fold(0.0, (s, e) => s + e.subtotalBalance);
  final totalEquity =
      items[AccountGroup.equity]!.fold(0.0, (s, e) => s + e.subtotalBalance);

  // 累計当期純利益：全期間の収益合計 - 費用合計
  final netIncome = allAccounts.fold(0.0, (s, a) {
    final g = AccountGroup.values[a.groupIndex];
    final raw = balances[a.id] ?? 0.0;
    if (g == AccountGroup.revenue) return s + (-raw);
    if (g == AccountGroup.expense) return s - raw;
    return s;
  });

  return BalanceSheetData(
    items: items,
    totalAssets: totalAssets,
    totalLiabilities: totalLiabilities,
    totalEquity: totalEquity,
    netIncome: netIncome,
    netAssets: totalAssets - totalLiabilities,
  );
});

final profitLossProvider =
    FutureProvider.autoDispose<ProfitLossData>((ref) async {
  final allAccounts = await ref.watch(accountsStreamProvider.future);
  final balances = await ref.watch(rawBalancesProvider.future);

  final allRevenues = allAccounts
      .where((a) => a.groupIndex == AccountGroup.revenue.index)
      .map((a) => (account: a, amount: -(balances[a.id] ?? 0.0)))
      .toList();
  final revenues = allRevenues.where((e) => e.amount > 0).toList();
  final totalRevenue = allRevenues.fold(0.0, (s, e) => s + e.amount);

  final allExpenses = allAccounts
      .where((a) => a.groupIndex == AccountGroup.expense.index)
      .map((a) => (account: a, amount: balances[a.id] ?? 0.0))
      .toList();
  final expenses = allExpenses.where((e) => e.amount > 0).toList();
  final totalExpense = allExpenses.fold(0.0, (s, e) => s + e.amount);

  return ProfitLossData(
    revenues: revenues,
    expenses: expenses,
    totalRevenue: totalRevenue,
    totalExpense: totalExpense,
    netIncome: totalRevenue - totalExpense,
  );
});

class HomeSummary {
  final double monthlyIncome;
  final double monthlyExpense;
  final double netAssets;

  HomeSummary({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.netAssets,
  });

  double get monthlyBalance => monthlyIncome - monthlyExpense;
}

final homeSummaryProvider =
    FutureProvider.autoDispose<HomeSummary>((ref) async {
  final allAccounts = await ref.watch(accountsStreamProvider.future);
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  final monthlyBalances = await db.transactionsDao.getAccountBalances(
    from: DateTime(now.year, now.month, 1),
    to: DateTime(now.year, now.month + 1, 1),
  );
  final allTimeBalances = await db.transactionsDao.getAccountBalances();

  double monthlyIncome = 0;
  double monthlyExpense = 0;
  double totalAssets = 0;
  double totalLiabilities = 0;

  for (final acc in allAccounts) {
    final group = AccountGroup.values[acc.groupIndex];
    final monthRaw = monthlyBalances[acc.id] ?? 0.0;
    final allRaw = allTimeBalances[acc.id] ?? 0.0;
    if (group == AccountGroup.revenue) monthlyIncome += -monthRaw;
    if (group == AccountGroup.expense) monthlyExpense += monthRaw;
    if (group == AccountGroup.asset) totalAssets += allRaw;
    if (group == AccountGroup.liability) totalLiabilities += -allRaw;
  }

  return HomeSummary(
    monthlyIncome: monthlyIncome,
    monthlyExpense: monthlyExpense,
    netAssets: totalAssets - totalLiabilities,
  );
});

final selectedMonthSummaryProvider =
    FutureProvider.autoDispose<HomeSummary>((ref) async {
  final allAccounts = await ref.watch(accountsStreamProvider.future);
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedHomeMonthProvider);

  final monthlyBalances = await db.transactionsDao.getAccountBalances(
    from: DateTime(month.year, month.month, 1),
    to: DateTime(month.year, month.month + 1, 1),
  );
  final allTimeBalances = await db.transactionsDao.getAccountBalances();

  double monthlyIncome = 0;
  double monthlyExpense = 0;
  double totalAssets = 0;
  double totalLiabilities = 0;

  for (final acc in allAccounts) {
    final group = AccountGroup.values[acc.groupIndex];
    final monthRaw = monthlyBalances[acc.id] ?? 0.0;
    final allRaw = allTimeBalances[acc.id] ?? 0.0;
    if (group == AccountGroup.revenue) monthlyIncome += -monthRaw;
    if (group == AccountGroup.expense) monthlyExpense += monthRaw;
    if (group == AccountGroup.asset) totalAssets += allRaw;
    if (group == AccountGroup.liability) totalLiabilities += -allRaw;
  }

  return HomeSummary(
    monthlyIncome: monthlyIncome,
    monthlyExpense: monthlyExpense,
    netAssets: totalAssets - totalLiabilities,
  );
});

class MonthlyChartData {
  final DateTime month;
  final double income;
  final double expense;
  MonthlyChartData(
      {required this.month, required this.income, required this.expense});
}

final monthlyChartProvider =
    FutureProvider.autoDispose<List<MonthlyChartData>>((ref) async {
  final allAccounts = await ref.watch(accountsStreamProvider.future);
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  final result = <MonthlyChartData>[];
  for (int i = 5; i >= 0; i--) {
    final m = DateTime(now.year, now.month - i, 1);
    final balances = await db.transactionsDao.getAccountBalances(
      from: DateTime(m.year, m.month, 1),
      to: DateTime(m.year, m.month + 1, 1),
    );
    double income = 0;
    double expense = 0;
    for (final acc in allAccounts) {
      final g = AccountGroup.values[acc.groupIndex];
      final raw = balances[acc.id] ?? 0.0;
      if (g == AccountGroup.revenue) income += -raw;
      if (g == AccountGroup.expense) expense += raw;
    }
    result.add(MonthlyChartData(month: m, income: income, expense: expense));
  }
  return result;
});

class ExpenseBreakdown {
  final int accountId;
  final String accountName;
  final double amount;
  final double ratio;
  ExpenseBreakdown(
      {required this.accountId,
      required this.accountName,
      required this.amount,
      required this.ratio});
}

class BalanceChangeItem {
  final Account account;
  final AccountGroup group;
  final double startBalance;
  final double endBalance;
  final double change;

  BalanceChangeItem({
    required this.account,
    required this.group,
    required this.startBalance,
    required this.endBalance,
    required this.change,
  });
}

final balanceChangesProvider =
    FutureProvider.autoDispose<List<BalanceChangeItem>>((ref) async {
  final allAccounts = await ref.watch(accountsStreamProvider.future);
  final db = ref.watch(databaseProvider);
  final period = ref.watch(selectedReportPeriodProvider);

  final prevBalances = await db.transactionsDao
      .getAccountBalances(to: period.from.subtract(const Duration(seconds: 1)));
  final endBalances =
      await db.transactionsDao.getAccountBalances(to: period.to);

  final result = <BalanceChangeItem>[];
  for (final acc in allAccounts) {
    final g = AccountGroup.values[acc.groupIndex];
    if (g != AccountGroup.asset && g != AccountGroup.liability) continue;

    final prevRaw = prevBalances[acc.id] ?? 0.0;
    final endRaw = endBalances[acc.id] ?? 0.0;
    final start = g.normallyDebit ? prevRaw : -prevRaw;
    final end = g.normallyDebit ? endRaw : -endRaw;
    final change = end - start;

    if (start == 0.0 && end == 0.0) continue;
    result.add(BalanceChangeItem(
      account: acc,
      group: g,
      startBalance: start,
      endBalance: end,
      change: change,
    ));
  }
  return result;
});

final expenseBreakdownProvider =
    FutureProvider.autoDispose<List<ExpenseBreakdown>>((ref) async {
  final allAccounts = await ref.watch(accountsStreamProvider.future);
  final db = ref.watch(databaseProvider);
  final period = ref.watch(selectedReportPeriodProvider);

  final balances = await db.transactionsDao
      .getAccountBalances(from: period.from, to: period.to);

  final items = <ExpenseBreakdown>[];
  double total = 0;

  for (final acc in allAccounts) {
    final g = AccountGroup.values[acc.groupIndex];
    if (g != AccountGroup.expense) continue;
    final amount = balances[acc.id] ?? 0.0;
    if (amount <= 0) continue;
    total += amount;
    items.add(ExpenseBreakdown(
        accountId: acc.id, accountName: acc.name, amount: amount, ratio: 0));
  }

  if (total == 0) return [];
  return items
      .map((e) => ExpenseBreakdown(
          accountId: e.accountId,
          accountName: e.accountName,
          amount: e.amount,
          ratio: e.amount / total))
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));
});
