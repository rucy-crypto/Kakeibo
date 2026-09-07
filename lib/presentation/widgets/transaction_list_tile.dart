import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_ledger/data/database/daos/transactions_dao.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:simple_ledger/domain/enums/entry_type.dart';
import 'package:simple_ledger/presentation/providers/transactions_provider.dart';
import 'package:simple_ledger/presentation/screens/input/input_screen.dart';
import 'package:simple_ledger/presentation/widgets/amount_text.dart';

final _dateFmt = DateFormat('M/d');
final _dateFmtFull = DateFormat('yyyy年M月d日 (E)', 'ja');
final _amountFmt = NumberFormat('#,###');

class TransactionListTile extends StatelessWidget {
  final TransactionWithEntries data;
  final VoidCallback? onDelete;
  final Set<int>? matchingAccountIds;

  const TransactionListTile({
    super.key,
    required this.data,
    this.onDelete,
    this.matchingAccountIds,
  });

  @override
  Widget build(BuildContext context) {
    final tx = data.transaction;
    final entries = data.entries;
    final hasAccFilter =
        matchingAccountIds != null && matchingAccountIds!.isNotEmpty;

    // 科目フィルターが有効な場合はマッチしたエントリのみ
    final matchedEntries = hasAccFilter
        ? entries
            .where((e) => matchingAccountIds!.contains(e.account.id))
            .toList()
        : entries;
    final displayEntries =
        matchedEntries.isNotEmpty ? matchedEntries : entries;

    // 表示用: 費用/収益エントリのグループでアイコン・色を決める
    final primaryEntry = displayEntries.firstWhere(
      (e) {
        final g = AccountGroup.values[e.account.groupIndex];
        return g == AccountGroup.expense || g == AccountGroup.revenue;
      },
      orElse: () => displayEntries.first,
    );
    final group = AccountGroup.values[primaryEntry.account.groupIndex];
    final isExpense = group == AccountGroup.expense;
    final isRevenue = group == AccountGroup.revenue;

    // 金額・色の計算
    final double trailingAmount;
    final Color trailingColor;
    if (!hasAccFilter) {
      // 従来: 借方合計
      trailingAmount = entries
          .where((e) => e.entry.entryTypeIndex == EntryType.debit.index)
          .fold(0.0, (s, e) => s + e.entry.amount);
      trailingColor = isExpense
          ? Colors.red.shade400
          : isRevenue
              ? Colors.green.shade600
              : Colors.blue.shade400;
    } else {
      // 科目フィルターあり: 該当科目の差引（借方 - 貸方）
      final matchedDebit = matchedEntries
          .where((e) => e.entry.entryTypeIndex == EntryType.debit.index)
          .fold(0.0, (s, e) => s + e.entry.amount);
      final matchedCredit = matchedEntries
          .where((e) => e.entry.entryTypeIndex == EntryType.credit.index)
          .fold(0.0, (s, e) => s + e.entry.amount);
      final net = matchedDebit - matchedCredit;
      trailingAmount = net.abs();
      // 借方超 → 費用系は赤、資産系は青 / 貸方超（返金等）→ 緑
      trailingColor = net >= 0
          ? (isExpense ? Colors.red.shade400 : Colors.blue.shade400)
          : Colors.green.shade600;
    }

    // サブタイトル
    final subtitleText = hasAccFilter && matchedEntries.isNotEmpty
        ? '${_dateFmt.format(tx.date)}  ${matchedEntries.map((e) => e.account.name).join('・')}'
        : '${_dateFmt.format(tx.date)}  ${primaryEntry.account.name}';

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('削除しますか？'),
            content: Text('「${tx.description}」を削除します'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text('削除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: ListTile(
        onTap: () => _showDetail(context),
        leading: CircleAvatar(
          backgroundColor: trailingColor.withValues(alpha: 0.15),
          child: Icon(
            isExpense
                ? Icons.arrow_upward
                : isRevenue
                    ? Icons.arrow_downward
                    : Icons.swap_horiz,
            color: trailingColor,
            size: 20,
          ),
        ),
        title: Text(tx.description, style: const TextStyle(fontSize: 15)),
        subtitle: Text(
          subtitleText,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AmountText(
              amount: trailingAmount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: trailingColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext outerContext) {
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _TransactionDetailSheet(
        data: data,
        onEdit: () {
          Navigator.pop(sheetCtx);
          Navigator.of(outerContext).push(
            MaterialPageRoute(
              builder: (_) => InputScreen(editTarget: data),
            ),
          );
        },
        onDelete: () {
          Navigator.pop(sheetCtx);
          onDelete?.call();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 仕訳詳細ボトムシート
// ---------------------------------------------------------------------------

class _TransactionDetailSheet extends ConsumerWidget {
  final TransactionWithEntries data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionDetailSheet({
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = data.transaction;
    final debitEntries = data.entries
        .where((e) => e.entry.entryTypeIndex == EntryType.debit.index)
        .toList();
    final creditEntries = data.entries
        .where((e) => e.entry.entryTypeIndex == EntryType.credit.index)
        .toList();
    final totalDebit =
        debitEntries.fold(0.0, (s, e) => s + e.entry.amount);
    final totalCredit =
        creditEntries.fold(0.0, (s, e) => s + e.entry.amount);
    final isBalanced = (totalDebit - totalCredit).abs() < 0.01;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // ドラッグハンドル
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                // ヘッダー
                Text(
                  tx.description,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateFmtFull.format(tx.date),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                if (tx.memo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tx.memo,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
                const SizedBox(height: 20),

                // 仕訳テーブル
                _JournalTable(
                  debitEntries: debitEntries,
                  creditEntries: creditEntries,
                  totalDebit: totalDebit,
                  totalCredit: totalCredit,
                  isBalanced: isBalanced,
                ),
                const SizedBox(height: 24),

                // 編集・削除ボタン
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('編集'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _confirmDelete(context, ref),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('削除'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除しますか？'),
        content: Text('「${data.transaction.description}」を削除します'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(deleteTransactionProvider)(data.transaction.id);
      onDelete();
    }
  }
}

// ---------------------------------------------------------------------------
// 仕訳テーブル
// ---------------------------------------------------------------------------

class _JournalTable extends StatelessWidget {
  final List<JournalEntryWithAccount> debitEntries;
  final List<JournalEntryWithAccount> creditEntries;
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;

  const _JournalTable({
    required this.debitEntries,
    required this.creditEntries,
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
  });

  @override
  Widget build(BuildContext context) {
    final maxRows = debitEntries.length > creditEntries.length
        ? debitEntries.length
        : creditEntries.length;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // ヘッダー行
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                _HeaderCell('借方', Colors.blue.shade700),
                Container(
                    width: 1, height: 40, color: Colors.grey.shade300),
                _HeaderCell('貸方', Colors.orange.shade700),
              ],
            ),
          ),
          const Divider(height: 1),

          // エントリ行
          for (int i = 0; i < maxRows; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: i < debitEntries.length
                      ? _EntryCell(
                          name: debitEntries[i].account.name,
                          amount: debitEntries[i].entry.amount,
                          color: Colors.blue.shade700,
                        )
                      : const SizedBox(height: 52),
                ),
                Container(
                    width: 1,
                    color: Colors.grey.shade300,
                    height: 52),
                Expanded(
                  child: i < creditEntries.length
                      ? _EntryCell(
                          name: creditEntries[i].account.name,
                          amount: creditEntries[i].entry.amount,
                          color: Colors.orange.shade700,
                        )
                      : const SizedBox(height: 52),
                ),
              ],
            ),
            if (i < maxRows - 1)
              Divider(height: 1, color: Colors.grey.shade200),
          ],

          // 合計行
          const Divider(height: 1),
          Container(
            decoration: BoxDecoration(
              color: isBalanced
                  ? Colors.green.withValues(alpha: 0.06)
                  : Colors.red.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TotalCell(
                      amount: totalDebit, color: Colors.blue.shade700),
                ),
                Container(
                    width: 1, height: 44, color: Colors.grey.shade300),
                Expanded(
                  child: _TotalCell(
                    amount: totalCredit,
                    color: Colors.orange.shade700,
                    suffix: isBalanced
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 6),
                              Icon(Icons.check_circle,
                                  size: 14,
                                  color: Colors.green.shade600),
                            ],
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final Color color;
  const _HeaderCell(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: color),
        ),
      ),
    );
  }
}

class _EntryCell extends StatelessWidget {
  final String name;
  final double amount;
  final Color color;
  const _EntryCell(
      {required this.name, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            '¥${_amountFmt.format(amount)}',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  final double amount;
  final Color color;
  final Widget? suffix;
  const _TotalCell(
      {required this.amount, required this.color, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Text(
            '¥${_amountFmt.format(amount)}',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}
