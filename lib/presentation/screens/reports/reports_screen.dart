import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:simple_ledger/presentation/providers/reports_provider.dart';
import 'package:simple_ledger/presentation/providers/transactions_provider.dart';
import 'package:simple_ledger/presentation/screens/search/search_screen.dart';
import 'package:simple_ledger/presentation/widgets/amount_text.dart';

final _shortMonth = DateFormat('M月', 'ja');
final _amountK = NumberFormat('#,###');

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('決算レポート'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'グラフ'),
              Tab(text: 'P/L 損益'),
              Tab(text: 'B/S 貸借'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ChartTab(),
            _PLTab(),
            _BSTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// グラフ Tab
// ---------------------------------------------------------------------------

class _ChartTab extends ConsumerWidget {
  const _ChartTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedReportPeriodProvider);
    final chartAsync = ref.watch(monthlyChartProvider);
    final breakdownAsync = ref.watch(expenseBreakdownProvider);

    return Column(
      children: [
        _PeriodSelector(period: period),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 収支棒グラフ
              Text('過去6ヶ月の収支',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              chartAsync.when(
                data: (data) => _BarChart(data: data),
                loading: () =>
                    const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('エラー: $e'),
              ),
              const SizedBox(height: 24),
              // 費目別円グラフ
              Text('費目別支出内訳（${period.label}）',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              breakdownAsync.when(
                data: (data) => data.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                            child: Text('支出データなし',
                                style: TextStyle(color: Colors.grey))))
                    : _PieChart(
                        data: data,
                        onAccountTap: (name) {
                          ref.read(searchQueryProvider.notifier).state = name;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SearchScreen()),
                          );
                        },
                      ),
                loading: () =>
                    const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('エラー: $e'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<MonthlyChartData> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.fold(0.0, (m, d) {
      final peak = d.income > d.expense ? d.income : d.expense;
      return peak > m ? peak : m;
    });
    final maxYAdj = maxY == 0 ? 10000.0 : maxY * 1.25;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxYAdj,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, gi, rod, ri) {
                final label = ri == 0 ? '収入' : '支出';
                return BarTooltipItem(
                  '$label\n¥${_amountK.format(rod.toY)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  _shortMonth.format(data[v.toInt()].month),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (v, _) => Text(
                  v == 0 ? '0' : '¥${(v / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                    toY: d.income,
                    color: Colors.green.shade400,
                    width: 10,
                    borderRadius: BorderRadius.circular(3)),
                BarChartRodData(
                    toY: d.expense,
                    color: Colors.red.shade300,
                    width: 10,
                    borderRadius: BorderRadius.circular(3)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

final _pieColors = [
  Colors.blue,
  Colors.orange,
  Colors.green,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.amber,
];

class _PieChart extends StatefulWidget {
  final List<ExpenseBreakdown> data;
  final void Function(String accountName)? onAccountTap;
  const _PieChart({required this.data, this.onAccountTap});

  @override
  State<_PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<_PieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, resp) {
                  if (!event.isInterestedForInteractions ||
                      resp == null ||
                      resp.touchedSection == null) {
                    setState(() => _touched = -1);
                    return;
                  }
                  final idx = resp.touchedSection!.touchedSectionIndex;
                  setState(() => _touched = idx);
                  if (event is FlTapUpEvent &&
                      idx >= 0 &&
                      idx < widget.data.length) {
                    widget.onAccountTap?.call(widget.data[idx].accountName);
                  }
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: widget.data.asMap().entries.map((e) {
                final isTouched = e.key == _touched;
                return PieChartSectionData(
                  value: e.value.amount,
                  color: _pieColors[e.key % _pieColors.length],
                  radius: isTouched ? 56 : 44,
                  title:
                      '${(e.value.ratio * 100).toStringAsFixed(1)}%',
                  titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 凡例
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: widget.data.asMap().entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _pieColors[e.key % _pieColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${e.value.accountName} ¥${_amountK.format(e.value.amount)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// P/L Tab
// ---------------------------------------------------------------------------

class _PLTab extends ConsumerWidget {
  const _PLTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedReportPeriodProvider);
    final plAsync = ref.watch(profitLossProvider);

    return Column(
      children: [
        _PeriodSelector(period: period),
        Expanded(
          child: plAsync.when(
            data: (pl) => _PLBody(data: pl),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('エラー: $e')),
          ),
        ),
      ],
    );
  }
}

class _PLBody extends StatelessWidget {
  final ProfitLossData data;
  const _PLBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final isProfit = data.netIncome >= 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 収益セクション
        _SectionHeader(
          title: '収益',
          total: data.totalRevenue,
          color: Colors.green.shade700,
        ),
        ...data.revenues.map(
          (e) => _AccountRow(
            name: e.account.name,
            amount: e.amount,
            color: Colors.green.shade600,
          ),
        ),
        if (data.revenues.isEmpty)
          const _EmptyRow(message: '収益なし'),
        const Divider(height: 24),

        // 費用セクション
        _SectionHeader(
          title: '費用',
          total: data.totalExpense,
          color: Colors.red.shade700,
        ),
        ...data.expenses.map(
          (e) => _AccountRow(
            name: e.account.name,
            amount: e.amount,
            color: Colors.red.shade400,
          ),
        ),
        if (data.expenses.isEmpty)
          const _EmptyRow(message: '費用なし'),
        const Divider(height: 24),

        // 当期純利益/損失
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isProfit ? Colors.green : Colors.red).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isProfit ? Colors.green : Colors.red).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isProfit ? '当期純利益' : '当期純損失',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AmountText(
                amount: data.netIncome.abs(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 8),
        const _MonthlyChangesTable(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 資産・負債 増減テーブル（P/L タブ）
// ---------------------------------------------------------------------------

final _amountFmt2 = NumberFormat('#,###');

class _MonthlyChangesTable extends ConsumerWidget {
  const _MonthlyChangesTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changesAsync = ref.watch(balanceChangesProvider);
    return changesAsync.when(
      data: (items) => _buildContent(context, items),
      loading: () =>
          const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('エラー: $e'),
    );
  }

  Widget _buildContent(BuildContext context, List<BalanceChangeItem> items) {
    final assets =
        items.where((i) => i.group == AccountGroup.asset).toList();
    final liabilities =
        items.where((i) => i.group == AccountGroup.liability).toList();

    if (assets.isEmpty && liabilities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('残高変動データなし', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '資産・負債の増減',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // ヘッダー行
        _ChangeRow(
          name: '科目',
          start: '期首残高',
          end: '期末残高',
          change: '増減',
          isHeader: true,
        ),
        if (assets.isNotEmpty) ...[
          _ChangeSectionLabel(label: '【資産】', color: Colors.blue.shade700),
          ...assets.map((item) => _ChangeRow(
                name: item.account.name,
                start: '¥${_amountFmt2.format(item.startBalance.abs())}',
                end: '¥${_amountFmt2.format(item.endBalance.abs())}',
                change: _fmtChange(item.change),
                changeColor: item.change >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              )),
        ],
        if (liabilities.isNotEmpty) ...[
          _ChangeSectionLabel(label: '【負債】', color: Colors.orange.shade700),
          ...liabilities.map((item) => _ChangeRow(
                name: item.account.name,
                start: '¥${_amountFmt2.format(item.startBalance.abs())}',
                end: '¥${_amountFmt2.format(item.endBalance.abs())}',
                change: _fmtChange(item.change),
                changeColor: item.change <= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              )),
        ],
      ],
    );
  }

  String _fmtChange(double v) =>
      '${v >= 0 ? '+' : ''}¥${_amountFmt2.format(v.toInt())}';
}

class _ChangeSectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _ChangeSectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  final String name;
  final String start;
  final String end;
  final String change;
  final bool isHeader;
  final Color? changeColor;

  const _ChangeRow({
    required this.name,
    required this.start,
    required this.end,
    required this.change,
    this.isHeader = false,
    this.changeColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
            color: Colors.grey)
        : const TextStyle(fontSize: 12);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(name, style: style, overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 3,
              child: Text(start,
                  style: style, textAlign: TextAlign.right)),
          Expanded(
              flex: 3,
              child: Text(end,
                  style: style, textAlign: TextAlign.right)),
          Expanded(
              flex: 3,
              child: Text(change,
                  style: isHeader
                      ? style
                      : TextStyle(
                          fontSize: 12,
                          color: changeColor,
                          fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// B/S Tab
// ---------------------------------------------------------------------------

class _BSTab extends ConsumerWidget {
  const _BSTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bsAsync = ref.watch(balanceSheetProvider);

    return bsAsync.when(
      data: (bs) => _BSBody(data: bs),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }
}

// ---------------------------------------------------------------------------
// B/S ビジュアル図（左: 資産 / 右上: 負債、右下: 純資産）
// ---------------------------------------------------------------------------

class _BSVisualChart extends StatelessWidget {
  final BalanceSheetData data;
  const _BSVisualChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final totalRight = data.totalLiabilities + data.totalEquity;
    final total = data.totalAssets >= totalRight
        ? data.totalAssets
        : totalRight;
    if (total <= 0) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text('データがありません', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    const chartH = 200.0;
    const minH = 50.0;
    const gap = 4.0;

    final hasLiab = data.totalLiabilities > 0;
    // 純資産ブロックは元入金 + 当期純利益の合計で表示
    final equityTotal = data.totalEquityWithIncome;
    final hasEquity = equityTotal > 0;

    double liabH = 0;
    double equityH = 0;

    if (hasLiab && hasEquity) {
      final rightTotal = data.totalLiabilities + equityTotal;
      final raw = data.totalLiabilities / rightTotal * (chartH - gap);
      liabH = raw.clamp(minH, chartH - gap - minH);
      equityH = chartH - gap - liabH;
    } else if (hasLiab) {
      liabH = chartH;
    } else if (hasEquity) {
      equityH = chartH;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '貸借対照表',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: chartH,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 左列: 資産（全高）────────────────────
              Expanded(
                child: _BSBlockFill(
                  color: Colors.blue.shade400,
                  label: '資産',
                  amount: data.totalAssets,
                  items: data.items[AccountGroup.asset] ?? [],
                ),
              ),
              const SizedBox(width: 8),
              // ── 右列: 負債 + 純資産（最低 50px 保証）──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasLiab)
                      SizedBox(
                        height: liabH,
                        child: _BSBlockFill(
                          color: Colors.orange.shade400,
                          label: '負債',
                          amount: data.totalLiabilities,
                          items: data.items[AccountGroup.liability] ?? [],
                        ),
                      ),
                    if (hasLiab && hasEquity)
                      const SizedBox(height: gap),
                    if (hasEquity)
                      SizedBox(
                        height: equityH,
                        child: _BSBlockFill(
                          color: Colors.purple.shade400,
                          label: '純資産',
                          amount: equityTotal,
                          items: data.items[AccountGroup.equity] ?? [],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 凡例
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: Colors.blue.shade400, label: '資産'),
            const SizedBox(width: 16),
            _Legend(color: Colors.orange.shade400, label: '負債'),
            const SizedBox(width: 16),
            _Legend(color: Colors.purple.shade400, label: '純資産'),
          ],
        ),
      ],
    );
  }
}

class _BSBlockFill extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;
  final List<BSItem> items;

  const _BSBlockFill({
    required this.color,
    required this.label,
    required this.amount,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (h >= 52) ...[
                const SizedBox(height: 2),
                Text(
                  '¥${NumberFormat('#,###').format(amount)}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
              if (h >= 80)
                ...items.take(3).map(
                      (e) => Text(
                        '${e.account.name}: ¥${NumberFormat('#,###').format(e.subtotalBalance)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _BSBody extends StatelessWidget {
  final BalanceSheetData data;
  const _BSBody({required this.data});

  List<Widget> _buildItems(List<BSItem> items, Color color) {
    return items.expand<Widget>((item) {
      if (item.children.isEmpty) {
        return [_AccountRow(name: item.account.name, amount: item.subtotalBalance, color: color)];
      }
      return [
        _AccountRow(name: item.account.name, amount: item.subtotalBalance, color: color, isSubtotal: true),
        ...item.children.map((c) => _AccountRow(
          name: c.account.name,
          amount: c.subtotalBalance,
          color: color,
          indent: true,
        )),
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isBalanced =
        (data.totalAssets - data.totalLiabilities - data.totalEquityWithIncome).abs() < 0.01;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── ビジュアル図 ──────────────────────────────
        _BSVisualChart(data: data),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // 資産
        _SectionHeader(
          title: '資産の部',
          total: data.totalAssets,
          color: Colors.blue.shade700,
        ),
        ..._buildItems(data.items[AccountGroup.asset] ?? [], Colors.blue.shade400),
        const Divider(height: 24),

        // 負債
        _SectionHeader(
          title: '負債の部',
          total: data.totalLiabilities,
          color: Colors.orange.shade700,
        ),
        ..._buildItems(data.items[AccountGroup.liability] ?? [], Colors.orange.shade400),
        const Divider(height: 24),

        // 純資産
        _SectionHeader(
          title: '純資産の部',
          total: data.totalEquityWithIncome,
          color: Colors.purple.shade700,
        ),
        ..._buildItems(data.items[AccountGroup.equity] ?? [], Colors.purple.shade400),
        _AccountRow(
          name: data.netIncome >= 0 ? '当期純利益（累計）' : '当期純損失（累計）',
          amount: data.netIncome.abs(),
          color: data.netIncome >= 0
              ? Colors.green.shade600
              : Colors.red.shade600,
        ),
        const Divider(height: 24),

        // 純資産合計
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('資産合計',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  AmountText(
                    amount: data.totalAssets,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('負債 + 純資産',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  AmountText(
                    amount: data.totalLiabilities + data.totalEquityWithIncome,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              if (!isBalanced)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '⚠ 貸借不一致',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Widgets
// ---------------------------------------------------------------------------

class _PeriodSelector extends ConsumerWidget {
  final ReportPeriod period;
  const _PeriodSelector({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final p = ref.read(selectedReportPeriodProvider);
              if (p.month == null) {
                ref.read(selectedReportPeriodProvider.notifier).state =
                    ReportPeriod(year: p.year - 1);
              } else {
                final prev = DateTime(p.year, p.month! - 1);
                ref.read(selectedReportPeriodProvider.notifier).state =
                    ReportPeriod(year: prev.year, month: prev.month);
              }
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                period.label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final p = ref.read(selectedReportPeriodProvider);
              if (p.month == null) {
                ref.read(selectedReportPeriodProvider.notifier).state =
                    ReportPeriod(year: p.year + 1);
              } else {
                final next = DateTime(p.year, p.month! + 1);
                ref.read(selectedReportPeriodProvider.notifier).state =
                    ReportPeriod(year: next.year, month: next.month);
              }
            },
          ),
          TextButton(
            onPressed: () {
              ref.read(selectedReportPeriodProvider.notifier).state =
                  ReportPeriod(year: now.year, month: now.month);
            },
            child: const Text('今月'),
          ),
          TextButton(
            onPressed: () {
              final p = ref.read(selectedReportPeriodProvider);
              ref.read(selectedReportPeriodProvider.notifier).state =
                  ReportPeriod(year: p.year);
            },
            child: const Text('年次'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final double total;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          AmountText(
            amount: total,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String name;
  final double amount;
  final Color color;
  final bool indent;
  final bool isSubtotal;

  const _AccountRow({
    required this.name,
    required this.amount,
    required this.color,
    this.indent = false,
    this.isSubtotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final fw = isSubtotal ? FontWeight.w600 : FontWeight.normal;
    return Padding(
      padding: EdgeInsets.fromLTRB(indent ? 24 : 8, 4, 8, 4),
      child: Row(
        children: [
          if (indent)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.subdirectory_arrow_right, size: 14, color: Colors.grey),
            ),
          Expanded(child: Text(name, style: TextStyle(fontSize: 14, fontWeight: fw))),
          AmountText(
            amount: amount,
            style: TextStyle(fontSize: 14, color: color, fontWeight: fw),
          ),
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String message;
  const _EmptyRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
    );
  }
}

