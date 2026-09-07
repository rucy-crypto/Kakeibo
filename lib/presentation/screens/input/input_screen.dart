import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_ledger/data/database/app_database.dart';
import 'package:simple_ledger/data/database/daos/transactions_dao.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:simple_ledger/presentation/providers/accounts_provider.dart';
import 'package:simple_ledger/presentation/providers/transactions_provider.dart';

final _dateFmt = DateFormat('yyyy/M/d (E)', 'ja');
final _amountFmt = NumberFormat('#,###');

class InputScreen extends StatelessWidget {
  final TransactionWithEntries? editTarget;
  const InputScreen({super.key, this.editTarget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editTarget == null ? '仕訳を追加' : '仕訳を編集'),
      ),
      body: _JournalStepForm(editTarget: editTarget),
    );
  }
}

// ---------------------------------------------------------------------------
// ステップカード
// ---------------------------------------------------------------------------

class _StepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isActive;
  final bool isCompleted;
  final String? completedValue;
  final Widget? activeContent;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onEdit;

  const _StepCard({
    required this.stepNumber,
    required this.title,
    required this.isActive,
    required this.isCompleted,
    this.completedValue,
    this.activeContent,
    this.confirmLabel = '確定',
    this.onConfirm,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: isActive ? 3 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            dense: true,
            leading: _StepIndicator(
              number: stepNumber,
              isCompleted: isCompleted,
              isActive: isActive,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: (!isActive && !isCompleted && onEdit == null)
                    ? Colors.grey
                    : theme.colorScheme.onSurface,
              ),
            ),
            subtitle: isCompleted && completedValue != null
                ? Text(
                    completedValue!,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
            onTap: onEdit,
            trailing: isCompleted
                ? Icon(Icons.edit_outlined,
                    size: 16, color: Colors.grey.shade400)
                : (onEdit != null && !isActive)
                    ? Icon(Icons.keyboard_arrow_right_outlined,
                        size: 16, color: Colors.grey.shade400)
                    : null,
          ),
          if (isActive && activeContent != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: activeContent!,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton(
                onPressed: onConfirm,
                child: Text(confirmLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final bool isCompleted;
  final bool isActive;

  const _StepIndicator({
    required this.number,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return const CircleAvatar(
        radius: 14,
        backgroundColor: Colors.green,
        child: Icon(Icons.check, color: Colors.white, size: 16),
      );
    }
    return CircleAvatar(
      radius: 14,
      backgroundColor: isActive
          ? Theme.of(context).colorScheme.primary
          : Colors.grey.shade200,
      child: Text(
        '$number',
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade500,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 仕訳フォームで使うエントリ行データ
// ---------------------------------------------------------------------------

class _EntryRow {
  Account? account;
  final TextEditingController amountCtrl = TextEditingController();

  double get amount =>
      double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
  bool get isValid => account != null && amount >= 0;

  void dispose() => amountCtrl.dispose();
}

// ---------------------------------------------------------------------------
// 仕訳 ステップフォーム（借方・貸方を複数行指定）
// ---------------------------------------------------------------------------

class _JournalStepForm extends ConsumerStatefulWidget {
  final TransactionWithEntries? editTarget;
  const _JournalStepForm({this.editTarget});

  @override
  ConsumerState<_JournalStepForm> createState() => _JournalStepFormState();
}

class _JournalStepFormState extends ConsumerState<_JournalStepForm> {
  int _currentStep = 0;
  int _maxStep = 0;

  DateTime _date = DateTime.now();
  final _descCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();

  // 複数行対応
  final List<_EntryRow> _debitRows = [_EntryRow()];
  final List<_EntryRow> _creditRows = [_EntryRow()];

  final _descFocus = FocusNode();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final edit = widget.editTarget;
    if (edit == null) return;

    // 編集モード: 既存データを各フィールドに展開
    _date = edit.transaction.date;
    _descCtrl.text = edit.transaction.description;
    _memoCtrl.text = edit.transaction.memo;

    _debitRows.clear();
    for (final e in edit.entries.where((e) => e.entry.entryTypeIndex == 0)) {
      _debitRows.add(_EntryRow()
        ..account = e.account
        ..amountCtrl.text = e.entry.amount.toStringAsFixed(0));
    }
    if (_debitRows.isEmpty) _debitRows.add(_EntryRow());

    _creditRows.clear();
    for (final e in edit.entries.where((e) => e.entry.entryTypeIndex == 1)) {
      _creditRows.add(_EntryRow()
        ..account = e.account
        ..amountCtrl.text = e.entry.amount.toStringAsFixed(0));
    }
    if (_creditRows.isEmpty) _creditRows.add(_EntryRow());

    // 全ステップを完了済み表示にして最終ステップを開く
    _currentStep = 4;
    _maxStep = 4;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _memoCtrl.dispose();
    _descFocus.dispose();
    _scrollCtrl.dispose();
    for (final r in _debitRows) { r.dispose(); }
    for (final r in _creditRows) { r.dispose(); }
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
      if (step > _maxStep) _maxStep = step;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentStep == 1) _descFocus.requestFocus();
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        (step * 100.0).clamp(0, _scrollCtrl.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  double get _totalDebit => _debitRows.fold(0, (s, r) => s + r.amount);
  double get _totalCredit => _creditRows.fold(0, (s, r) => s + r.amount);
  bool get _debitRowsValid => _debitRows.every((r) => r.isValid);
  bool get _creditRowsValid => _creditRows.every((r) => r.isValid);
  bool get _isBalanced =>
      _debitRowsValid && _creditRowsValid &&
      (_totalDebit - _totalCredit).abs() < 0.01;

  /// 借方/貸方ステップの完了値サマリ文字列
  String _rowsSummary(List<_EntryRow> rows) => rows
      .where((r) => r.isValid)
      .map((r) => '${r.account!.name} ¥${_amountFmt.format(r.amount)}')
      .join(' / ');

  Future<void> _submit() async {
    if (!_isBalanced) return;
    final entries = [
      ..._debitRows.map((r) =>
          (accountId: r.account!.id, entryTypeIndex: 0, amount: r.amount)),
      ..._creditRows.map((r) =>
          (accountId: r.account!.id, entryTypeIndex: 1, amount: r.amount)),
    ];
    try {
      if (widget.editTarget != null) {
        await ref.read(updateJournalProvider)(
          transactionId: widget.editTarget!.transaction.id,
          date: _date,
          description: _descCtrl.text.trim(),
          memo: _memoCtrl.text.trim(),
          entries: entries,
        );
      } else {
        await ref.read(addJournalProvider)(
          date: _date,
          description: _descCtrl.text.trim(),
          memo: _memoCtrl.text.trim(),
          entries: entries,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editTarget != null ? '仕訳を更新しました' : '仕訳を記録しました'),
            backgroundColor: Colors.green,
          ),
        );
        if (widget.editTarget != null) {
          Navigator.of(context).pop(); // 編集画面を閉じる
        } else {
          _reset();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    }
  }

  void _reset() {
    for (final r in _debitRows) { r.dispose(); }
    for (final r in _creditRows) { r.dispose(); }
    setState(() {
      _currentStep = 0;
      _date = DateTime.now();
      _descCtrl.clear();
      _memoCtrl.clear();
      _debitRows
        ..clear()
        ..add(_EntryRow());
      _creditRows
        ..clear()
        ..add(_EntryRow());
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);

    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
      data: (allAccounts) => ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(12),
        children: [
          // ── Step 1: 日付 ──────────────────────────────
          _StepCard(
            stepNumber: 1,
            title: '日付',
            isActive: _currentStep == 0,
            isCompleted: _maxStep > 0,
            completedValue: _dateFmt.format(_date),
            onEdit: _maxStep > 0 ? () => _goToStep(0) : null,
            onConfirm: () => _goToStep(1),
            activeContent: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _dateFmt.format(_date),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('日付を変更'),
                ),
              ],
            ),
          ),

          // ── Step 2: 内容 ──────────────────────────────
          _StepCard(
            stepNumber: 2,
            title: '内容（摘要）',
            isActive: _currentStep == 1,
            isCompleted: _maxStep > 1,
            completedValue:
                _descCtrl.text.isNotEmpty ? _descCtrl.text : null,
            onEdit: _maxStep > 1 ? () => _goToStep(1) : null,
            onConfirm: _descCtrl.text.trim().isNotEmpty
                ? () => _goToStep(2)
                : null,
            activeContent: TextField(
              controller: _descCtrl,
              focusNode: _descFocus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '例: 食料品・日用品購入',
              ),
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (_descCtrl.text.trim().isNotEmpty) _goToStep(2);
              },
            ),
          ),

          // ── Step 3: 借方（複数行）───────────────────────
          _StepCard(
            stepNumber: 3,
            title: '借方（Debit）',
            isActive: _currentStep == 2,
            isCompleted: _maxStep > 2,
            completedValue: _debitRowsValid && _debitRows.isNotEmpty
                ? _rowsSummary(_debitRows)
                : null,
            onEdit: _maxStep > 2 ? () => _goToStep(2) : null,
            onConfirm: _debitRowsValid ? () => _goToStep(3) : null,
            activeContent: _MultiEntryRows(
              rows: _debitRows,
              allAccounts: allAccounts,
              onChanged: () => setState(() {}),
              onAdd: () => setState(() => _debitRows.add(_EntryRow())),
              onRemove: (i) => setState(() {
                _debitRows[i].dispose();
                _debitRows.removeAt(i);
              }),
            ),
          ),

          // ── Step 4: 貸方（複数行）───────────────────────
          _StepCard(
            stepNumber: 4,
            title: '貸方（Credit）',
            isActive: _currentStep == 3,
            isCompleted: _maxStep > 3,
            completedValue: _creditRowsValid && _creditRows.isNotEmpty
                ? _rowsSummary(_creditRows)
                : null,
            onEdit: _maxStep > 3 ? () => _goToStep(3) : null,
            onConfirm: _creditRowsValid ? () => _goToStep(4) : null,
            activeContent: Column(
              children: [
                _MultiEntryRows(
                  rows: _creditRows,
                  allAccounts: allAccounts,
                  onChanged: () => setState(() {}),
                  onAdd: () => setState(() => _creditRows.add(_EntryRow())),
                  onRemove: (i) => setState(() {
                    _creditRows[i].dispose();
                    _creditRows.removeAt(i);
                  }),
                ),
                if (_totalDebit > 0 && _totalCredit > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _BalanceIndicator(
                        debit: _totalDebit, credit: _totalCredit),
                  ),
              ],
            ),
          ),

          // ── Step 5: メモ + 記録する ───────────────────
          _StepCard(
            stepNumber: 5,
            title: 'メモ（任意）',
            isActive: _currentStep == 4,
            isCompleted: false,
            onEdit: _maxStep >= 4 ? () => _goToStep(4) : null,
            confirmLabel: '記録する',
            onConfirm: _isBalanced ? _submit : null,
            activeContent: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BalanceIndicator(
                    debit: _totalDebit, credit: _totalCredit),
                const SizedBox(height: 12),
                TextField(
                  controller: _memoCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'メモを入力（省略可）',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 複数エントリ行ウィジェット
// ---------------------------------------------------------------------------

class _MultiEntryRows extends StatelessWidget {
  final List<_EntryRow> rows;
  final List<Account> allAccounts;
  final VoidCallback onChanged;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const _MultiEntryRows({
    required this.rows,
    required this.allAccounts,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 科目ドロップダウン
              Expanded(
                flex: 3,
                child: _AccountDropdown(
                  accounts: allAccounts,
                  value: rows[i].account,
                  onChanged: (a) {
                    rows[i].account = a;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              // 金額
              Expanded(
                flex: 2,
                child: TextField(
                  controller: rows[i].amountCtrl,
                  decoration: const InputDecoration(
                    prefixText: '¥',
                    border: OutlineInputBorder(),
                    hintText: '金額',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => onChanged(),
                ),
              ),
              // 削除ボタン（2行以上のとき表示）
              if (rows.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.red.shade300,
                  onPressed: () => onRemove(i),
                  padding: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(),
                )
              else
                const SizedBox(width: 40),
            ],
          ),
          if (i < rows.length - 1) const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('行を追加'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 貸借バランスインジケーター
// ---------------------------------------------------------------------------

class _BalanceIndicator extends StatelessWidget {
  final double debit;
  final double credit;
  const _BalanceIndicator({required this.debit, required this.credit});

  @override
  Widget build(BuildContext context) {
    final balanced = (debit - credit).abs() < 0.01;
    final color = balanced ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('借方: ¥${_amountFmt.format(debit)}',
                  style: const TextStyle(fontSize: 13)),
              Text('貸方: ¥${_amountFmt.format(credit)}',
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
          Row(
            children: [
              Icon(
                balanced ? Icons.check_circle : Icons.error_outline,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                balanced ? '貸借一致' : '不一致',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 勘定科目ドロップダウン（共通）
// ---------------------------------------------------------------------------

class _AccountDropdown extends StatelessWidget {
  final List<Account> accounts;
  final Account? value;
  final ValueChanged<Account?> onChanged;

  const _AccountDropdown({
    required this.accounts,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // グループ別にソート・表示するため DropdownMenuItem にヘッダーを挟む
    final items = <DropdownMenuItem<Account>>[];
    AccountGroup? lastGroup;

    for (final acc in accounts) {
      final group = AccountGroup.values[acc.groupIndex];
      if (group != lastGroup) {
        // グループヘッダー（disabled item）
        items.add(DropdownMenuItem<Account>(
          enabled: false,
          value: null,
          child: Text(
            group.displayName,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
        lastGroup = group;
      }
      items.add(DropdownMenuItem<Account>(
        value: acc,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(acc.name),
        ),
      ));
    }

    final currentValue = accounts.contains(value) ? value : null;

    return InputDecorator(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Account>(
          value: currentValue,
          hint: const Text('科目を選択'),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
