import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_ledger/presentation/providers/transactions_provider.dart';
import 'package:simple_ledger/presentation/widgets/transaction_list_tile.dart';

final _dateFmt = DateFormat('yyyy/M/d', 'ja');
final _amountFmt = NumberFormat('#,###');


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _accountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.text = ref.read(searchQueryProvider);
    _accountCtrl.text = ref.read(searchAccountQueryProvider);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final current = isStart
        ? ref.read(searchStartDateProvider)
        : ref.read(searchEndDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    if (isStart) {
      ref.read(searchStartDateProvider.notifier).state = picked;
    } else {
      ref.read(searchEndDateProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final accountQuery = ref.watch(searchAccountQueryProvider);
    final matchingIds = ref.watch(searchMatchingAccountIdsProvider);
    final startDate = ref.watch(searchStartDateProvider);
    final endDate = ref.watch(searchEndDateProvider);
    final sort = ref.watch(searchSortProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final deleteTransaction = ref.read(deleteTransactionProvider);
    final hasFilter = query.trim().isNotEmpty ||
        accountQuery.trim().isNotEmpty ||
        startDate != null ||
        endDate != null;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '取引で検索（説明文・メモ）',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black45),
          ),
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          onChanged: (q) =>
              ref.read(searchQueryProvider.notifier).state = q,
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ── フィルターバー ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Column(
              children: [
                // 行1: 日付 + ソート
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _DateChip(
                            label: startDate == null
                                ? '開始日'
                                : _dateFmt.format(startDate),
                            isSet: startDate != null,
                            onTap: () => _pickDate(true),
                            onClear: startDate != null
                                ? () => ref
                                    .read(searchStartDateProvider.notifier)
                                    .state = null
                                : null,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text('〜',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                          ),
                          _DateChip(
                            label: endDate == null
                                ? '終了日'
                                : _dateFmt.format(endDate),
                            isSet: endDate != null,
                            onTap: () => _pickDate(false),
                            onClear: endDate != null
                                ? () => ref
                                    .read(searchEndDateProvider.notifier)
                                    .state = null
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<SearchSort>(
                        value: sort,
                        isDense: true,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                        items: const [
                          DropdownMenuItem(
                              value: SearchSort.dateDesc,
                              child: Text('日付↓')),
                          DropdownMenuItem(
                              value: SearchSort.dateAsc,
                              child: Text('日付↑')),
                          DropdownMenuItem(
                              value: SearchSort.amountDesc,
                              child: Text('金額↓')),
                          DropdownMenuItem(
                              value: SearchSort.amountAsc,
                              child: Text('金額↑')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            ref
                                .read(searchSortProvider.notifier)
                                .state = v;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 行2: 科目名フィルター
                Row(
                  children: [
                    const Text('科目名:',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _accountCtrl,
                        decoration: InputDecoration(
                          hintText: '食費・費用など',
                          hintStyle: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (v) => ref
                            .read(searchAccountQueryProvider.notifier)
                            .state = v,
                      ),
                    ),
                    if (accountQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _accountCtrl.clear();
                          ref
                              .read(searchAccountQueryProvider.notifier)
                              .state = '';
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── 結果 ─────────────────────────────────────────
          Expanded(
            child: resultsAsync.when(
              data: (list) {
                if (!hasFilter) {
                  return const Center(
                    child: Text(
                      'キーワードまたは期間を入力してください',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      '該当する取引が見つかりません',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // 集計: 科目フィルターが有効なときは該当エントリのみ
                double debitTotal = 0;
                double creditTotal = 0;
                for (final t in list) {
                  final relevantEntries = matchingIds != null
                      ? t.entries
                          .where((e) => matchingIds.contains(e.account.id))
                          .toList()
                      : t.entries;
                  for (final e in relevantEntries) {
                    if (e.entry.entryTypeIndex == 0) {
                      debitTotal += e.entry.amount;
                    } else {
                      creditTotal += e.entry.amount;
                    }
                  }
                }
                final net = debitTotal - creditTotal;

                return Column(
                  children: [
                    // 合計バー
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${list.length}件',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _SummaryItem(
                                  label: '借方',
                                  amount: debitTotal,
                                  color: Colors.blue.shade700),
                              const SizedBox(width: 16),
                              _SummaryItem(
                                  label: '貸方',
                                  amount: creditTotal,
                                  color: Colors.orange.shade700),
                              const Spacer(),
                              Text(
                                net > 0.01
                                    ? '差引 借方'
                                    : net < -0.01
                                        ? '差引 貸方'
                                        : '差引',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '¥${_amountFmt.format(net.abs().toInt())}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, i) => TransactionListTile(
                          data: list[i],
                          matchingAccountIds: matchingIds,
                          onDelete: () =>
                              deleteTransaction(list[i].transaction.id),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('エラー: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _SummaryItem(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: color)),
        Text('¥${_amountFmt.format(amount.toInt())}',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _DateChip extends StatelessWidget {
  final String label;
  final bool isSet;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateChip({
    required this.label,
    required this.isSet,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSet
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSet ? primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSet ? primary : Colors.grey.shade600,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 14, color: primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
