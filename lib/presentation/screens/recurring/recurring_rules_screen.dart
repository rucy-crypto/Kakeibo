import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_ledger/data/database/app_database.dart';
import 'package:simple_ledger/presentation/providers/accounts_provider.dart';
import 'package:simple_ledger/presentation/providers/recurring_provider.dart';

final _amtFmt = NumberFormat('#,###');

// ---------------------------------------------------------------------------
// 定期取引一覧
// ---------------------------------------------------------------------------

class RecurringRulesScreen extends ConsumerWidget {
  const RecurringRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(recurringRulesProvider);
    final delete = ref.read(deleteRecurringRuleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('定期取引')),
      body: rulesAsync.when(
        data: (rules) {
          if (rules.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.repeat, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('定期取引はまだありません',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    '右下の＋ボタンから追加できます',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: rules.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _RuleListTile(
              rule: rules[i],
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RecurringRuleFormScreen(editRule: rules[i]),
                ),
              ),
              onDelete: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('削除しますか？'),
                    content: Text('「${rules[i].name}」を削除します。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('削除',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (ok == true) await delete(rules[i].id);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const RecurringRuleFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('定期取引を追加'),
      ),
    );
  }
}

class _RuleListTile extends ConsumerWidget {
  final RecurringRule rule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RuleListTile({
    required this.rule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
    final debit =
        accounts.where((a) => a.id == rule.debitAccountId).firstOrNull;
    final credit =
        accounts.where((a) => a.id == rule.creditAccountId).firstOrNull;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rule.isActive
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey.shade200,
        child: Text(
          rule.dayOfMonth == 31 ? '月末' : '${rule.dayOfMonth}日',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: rule.isActive
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.grey,
          ),
        ),
      ),
      title: Text(
        rule.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: rule.isActive ? null : Colors.grey,
        ),
      ),
      subtitle: Text(
        '${debit?.name ?? '?'} → ${credit?.name ?? '?'}  '
        '${rule.amount != null ? '¥${_amtFmt.format(rule.amount!.toInt())}' : '変動（要入力）'}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 定期取引 追加・編集フォーム
// ---------------------------------------------------------------------------

class RecurringRuleFormScreen extends ConsumerStatefulWidget {
  final RecurringRule? editRule;
  const RecurringRuleFormScreen({super.key, this.editRule});

  @override
  ConsumerState<RecurringRuleFormScreen> createState() =>
      _RecurringRuleFormScreenState();
}

class _RecurringRuleFormScreenState
    extends ConsumerState<RecurringRuleFormScreen> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  int _dayOfMonth = 1;
  int? _debitAccountId;
  int? _creditAccountId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final r = widget.editRule;
    if (r != null) {
      _nameCtrl.text = r.name;
      if (r.amount != null) _amountCtrl.text = r.amount!.toInt().toString();
      _memoCtrl.text = r.memo;
      _dayOfMonth = r.dayOfMonth;
      _debitAccountId = r.debitAccountId;
      _creditAccountId = r.creditAccountId;
      _isActive = r.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editRule != null;
    final accounts =
        ref.watch(accountsStreamProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '定期取引を編集' : '定期取引を追加'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '例：家賃、Netflix',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: '毎月の処理日',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _dayOfMonth,
                  isExpanded: true,
                  items: [
                    ...List.generate(28, (i) => i + 1).map(
                        (d) => DropdownMenuItem(value: d, child: Text('$d日'))),
                    const DropdownMenuItem(value: 31, child: Text('月末')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _dayOfMonth = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _AccountDropdown(
              label: '借方科目（費用・資産側）',
              accounts: accounts,
              value: _debitAccountId,
              onChanged: (v) => setState(() => _debitAccountId = v),
            ),
            const SizedBox(height: 16),
            _AccountDropdown(
              label: '貸方科目（支払い元）',
              accounts: accounts,
              value: _creditAccountId,
              onChanged: (v) => setState(() => _creditAccountId = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: '金額（空欄 = 変動費として毎月通知）',
                hintText: '例：80000',
                border: OutlineInputBorder(),
                suffixText: '円',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _memoCtrl,
              decoration: const InputDecoration(
                labelText: 'メモ（任意）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              title: const Text('有効'),
              subtitle: const Text('無効にすると自動処理をスキップします'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEdit ? '更新' : '追加'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _err('名称を入力してください');
      return;
    }
    if (_debitAccountId == null) {
      _err('借方科目を選択してください');
      return;
    }
    if (_creditAccountId == null) {
      _err('貸方科目を選択してください');
      return;
    }
    final amtText = _amountCtrl.text.trim();
    double? amount;
    if (amtText.isNotEmpty) {
      amount = double.tryParse(amtText);
      if (amount == null || amount <= 0) {
        _err('金額が不正です');
        return;
      }
    }

    if (widget.editRule == null) {
      await ref.read(addRecurringRuleProvider)(
        RecurringRulesCompanion.insert(
          name: name,
          debitAccountId: _debitAccountId!,
          creditAccountId: _creditAccountId!,
          amount: Value(amount),
          dayOfMonth: _dayOfMonth,
          memo: Value(_memoCtrl.text.trim()),
          isActive: Value(_isActive),
        ),
      );
    } else {
      await ref.read(updateRecurringRuleProvider)(
        widget.editRule!.copyWith(
          name: name,
          debitAccountId: _debitAccountId!,
          creditAccountId: _creditAccountId!,
          amount: Value(amount),
          dayOfMonth: _dayOfMonth,
          memo: _memoCtrl.text.trim(),
          isActive: _isActive,
        ),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  void _err(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
}

class _AccountDropdown extends StatelessWidget {
  final String label;
  final List<Account> accounts;
  final int? value;
  final ValueChanged<int?> onChanged;

  const _AccountDropdown({
    required this.label,
    required this.accounts,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          hint: const Text('科目を選択'),
          items: accounts
              .map((a) =>
                  DropdownMenuItem(value: a.id, child: Text(a.name)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
