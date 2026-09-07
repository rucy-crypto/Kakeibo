import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_ledger/data/database/daos/transactions_dao.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:simple_ledger/presentation/providers/recurring_provider.dart';
import 'package:simple_ledger/presentation/providers/reports_provider.dart';
import 'package:simple_ledger/presentation/providers/transactions_provider.dart';
import 'package:simple_ledger/presentation/screens/recurring/recurring_rules_screen.dart';
import 'package:simple_ledger/presentation/screens/setup/initial_balance_screen.dart';
import 'package:simple_ledger/presentation/widgets/amount_text.dart';
import 'package:simple_ledger/presentation/widgets/transaction_list_tile.dart';

final _monthFmt = DateFormat('yyyy年M月', 'ja');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedHomeMonthProvider);
    final summaryAsync = ref.watch(selectedMonthSummaryProvider);
    final txAsync = ref.watch(monthTransactionsProvider);
    final deleteTransaction = ref.read(deleteTransactionProvider);
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    // 収入・支出タップ用のフィルター済みリスト
    final txList = txAsync.valueOrNull ?? [];
    final incomeTxs = txList.where((tx) => tx.entries.any((e) =>
        e.entry.entryTypeIndex == 1 &&
        AccountGroup.values[e.account.groupIndex] ==
            AccountGroup.revenue)).toList();
    final expenseTxs = txList.where((tx) => tx.entries.any((e) =>
        e.entry.entryTypeIndex == 0 &&
        AccountGroup.values[e.account.groupIndex] ==
            AccountGroup.expense)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── AppBar + サマリー ─────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            actions: [
              IconButton(
                icon: const Icon(Icons.repeat, color: Colors.white),
                tooltip: '定期取引',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RecurringRulesScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white),
                tooltip: '初期残高を設定',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InitialBalanceScreen()),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _SummaryHeader(
                summaryAsync: summaryAsync,
                selectedMonth: selectedMonth,
                isCurrentMonth: isCurrentMonth,
                onPrev: () => ref
                    .read(selectedHomeMonthProvider.notifier)
                    .state = DateTime(
                        selectedMonth.year, selectedMonth.month - 1),
                onNext: isCurrentMonth
                    ? null
                    : () => ref
                        .read(selectedHomeMonthProvider.notifier)
                        .state = DateTime(
                            selectedMonth.year, selectedMonth.month + 1),
                onIncomeTap: incomeTxs.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _FilteredJournalScreen(
                              title: '収入一覧',
                              transactions: incomeTxs,
                            ),
                          ),
                        ),
                onExpenseTap: expenseTxs.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _FilteredJournalScreen(
                              title: '支出一覧',
                              transactions: expenseTxs,
                            ),
                          ),
                        ),
              ),
            ),
          ),

          // ── 定期取引バナー ───────────────────────────
          const _RecurringBanner(),

          // ── 取引一覧ヘッダー ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_monthFmt.format(selectedMonth)}の取引',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (!isCurrentMonth)
                    TextButton(
                      onPressed: () => ref
                          .read(selectedHomeMonthProvider.notifier)
                          .state = DateTime(now.year, now.month),
                      child: const Text('今月に戻る'),
                    ),
                ],
              ),
            ),
          ),

          // ── 取引一覧 ──────────────────────────────────
          txAsync.when(
            data: (txList) {
              if (txList.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'この月の取引はありません',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => TransactionListTile(
                    data: txList[i],
                    onDelete: () =>
                        deleteTransaction(txList[i].transaction.id),
                  ),
                  childCount: txList.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('エラー: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// サマリーヘッダー（月ナビ付き）
// ---------------------------------------------------------------------------

class _SummaryHeader extends StatelessWidget {
  final AsyncValue<HomeSummary> summaryAsync;
  final DateTime selectedMonth;
  final bool isCurrentMonth;
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  const _SummaryHeader({
    required this.summaryAsync,
    required this.selectedMonth,
    required this.isCurrentMonth,
    required this.onPrev,
    this.onNext,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 月ナビゲーション
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 56, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: onPrev,
                ),
                Text(
                  _monthFmt.format(selectedMonth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right,
                      color: onNext != null
                          ? Colors.white
                          : Colors.white38),
                  onPressed: onNext,
                ),
              ],
            ),
          ),
          // サマリーカード
          summaryAsync.when(
            data: (summary) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  _StatCard(
                    label: '純資産',
                    amount: summary.netAssets,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: '収入',
                    amount: summary.monthlyIncome,
                    color: Colors.greenAccent.shade100,
                    onTap: onIncomeTap,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: '支出',
                    amount: summary.monthlyExpense,
                    color: Colors.red.shade100,
                    onTap: onExpenseTap,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: '収支',
                    amount: summary.monthlyBalance,
                    color: summary.monthlyBalance >= 0
                        ? Colors.greenAccent.shade100
                        : Colors.red.shade100,
                  ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (_, __) => const SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10, color: color.withValues(alpha: 0.85))),
              const SizedBox(height: 3),
              AmountText(
                amount: amount,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 定期取引バナー
// ---------------------------------------------------------------------------

class _RecurringBanner extends ConsumerWidget {
  const _RecurringBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionCount = ref.watch(recurringSessionCountProvider);
    final pendingAsync = ref.watch(pendingRecurringProvider);
    final pendingItems = pendingAsync.valueOrNull ?? [];

    final widgets = <Widget>[];

    if (sessionCount > 0) {
      widgets.add(_BannerCard(
        color: Colors.green.shade50,
        borderColor: Colors.green.shade300,
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
        message: '今月 $sessionCount件の定期取引を自動記帳しました',
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () =>
              ref.read(recurringSessionCountProvider.notifier).state = 0,
        ),
      ));
    }

    if (pendingItems.isNotEmpty) {
      widgets.add(_BannerCard(
        color: Colors.orange.shade50,
        borderColor: Colors.orange.shade300,
        icon: Icons.edit_note,
        iconColor: Colors.orange,
        message: '金額入力待ちの定期取引が ${pendingItems.length}件あります',
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _PendingRecurringSheet(items: pendingItems),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ));
    }

    if (widgets.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: widgets
              .map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: w,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String message;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _BannerCard({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.message,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(fontSize: 13)),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _PendingRecurringSheet extends ConsumerStatefulWidget {
  final List<PendingRecurringItem> items;
  const _PendingRecurringSheet({required this.items});

  @override
  ConsumerState<_PendingRecurringSheet> createState() =>
      _PendingRecurringSheetState();
}

class _PendingRecurringSheetState
    extends ConsumerState<_PendingRecurringSheet> {
  @override
  Widget build(BuildContext context) {
    // 最新の pending リストを取得
    final liveItems =
        ref.watch(pendingRecurringProvider).valueOrNull ?? widget.items;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('金額入力待ちの定期取引',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (liveItems.isEmpty)
            const Expanded(
              child: Center(
                child: Text('入力待ちの取引はありません',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: liveItems.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) =>
                    _PendingItemTile(item: liveItems[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _PendingItemTile extends ConsumerStatefulWidget {
  final PendingRecurringItem item;
  const _PendingItemTile({required this.item});

  @override
  ConsumerState<_PendingItemTile> createState() => _PendingItemTileState();
}

class _PendingItemTileState extends ConsumerState<_PendingItemTile> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.item.rule;
    return ListTile(
      title: Text(r.name),
      subtitle: Text(
        '${widget.item.debitAccount.name} / ${widget.item.creditAccount.name}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: SizedBox(
        width: 140,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  hintText: '金額',
                  suffixText: '円',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () async {
                final amount = double.tryParse(_ctrl.text.trim());
                if (amount == null || amount <= 0) return;
                final messenger = ScaffoldMessenger.of(context);
                await ref
                    .read(completeRecurringProvider)(widget.item, amount);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('「${r.name}」を記帳しました')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// フィルター済み仕訳一覧（収入・支出タップ用）
// ---------------------------------------------------------------------------

class _FilteredJournalScreen extends ConsumerWidget {
  final String title;
  final List<TransactionWithEntries> transactions;

  const _FilteredJournalScreen({
    required this.title,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleteTransaction = ref.read(deleteTransactionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: transactions.isEmpty
          ? const Center(
              child: Text('取引がありません', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (_, i) => TransactionListTile(
                data: transactions[i],
                onDelete: () =>
                    deleteTransaction(transactions[i].transaction.id),
              ),
            ),
    );
  }
}
