import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_ledger/data/database/app_database.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:simple_ledger/presentation/providers/accounts_provider.dart';
import 'package:simple_ledger/presentation/providers/transactions_provider.dart';

/// 初期残高設定画面
/// 資産・負債科目に対して開始残高を一括登録する。
/// 内部では「資産 Dr / 元入金 Cr」または「元入金 Dr / 負債 Cr」の仕訳を作成する。
class InitialBalanceScreen extends ConsumerStatefulWidget {
  const InitialBalanceScreen({super.key});

  @override
  ConsumerState<InitialBalanceScreen> createState() =>
      _InitialBalanceScreenState();
}

class _InitialBalanceScreenState
    extends ConsumerState<InitialBalanceScreen> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(int accountId) {
    return _controllers.putIfAbsent(
        accountId, () => TextEditingController());
  }

  Future<void> _save(List<Account> allAccounts) async {
    // 元入金科目を探す
    final equityAccount = allAccounts.firstWhere(
      (a) => a.name == '元入金',
      orElse: () => allAccounts
          .firstWhere((a) => a.groupIndex == AccountGroup.equity.index),
    );

    int saved = 0;
    for (final acc in allAccounts) {
      final group = AccountGroup.values[acc.groupIndex];
      if (group != AccountGroup.asset && group != AccountGroup.liability) {
        continue;
      }
      final ctrl = _controllers[acc.id];
      if (ctrl == null || ctrl.text.trim().isEmpty) continue;
      final amount = double.tryParse(ctrl.text.replaceAll(',', ''));
      if (amount == null || amount <= 0) continue;

      // 資産: 資産(Dr) / 元入金(Cr)
      // 負債: 元入金(Dr) / 負債(Cr)
      final isAsset = group == AccountGroup.asset;
      await ref.read(addJournalProvider)(
        date: DateTime.now(),
        description: '【初期残高】${acc.name}',
        memo: '開始残高の設定',
        entries: [
          (
            accountId: isAsset ? acc.id : equityAccount.id,
            entryTypeIndex: 0,
            amount: amount,
          ),
          (
            accountId: isAsset ? equityAccount.id : acc.id,
            entryTypeIndex: 1,
            amount: amount,
          ),
        ],
      );
      saved++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$saved 件の初期残高を設定しました'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('初期残高を設定')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (allAccounts) {
          final assetAccounts = allAccounts
              .where((a) => a.groupIndex == AccountGroup.asset.index)
              .toList();
          final liabilityAccounts = allAccounts
              .where(
                  (a) => a.groupIndex == AccountGroup.liability.index)
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _InfoBanner(),
                    const SizedBox(height: 16),
                    _SectionLabel('資産'),
                    ...assetAccounts.map((acc) => _BalanceRow(
                          account: acc,
                          controller: _ctrl(acc.id),
                        )),
                    const SizedBox(height: 16),
                    _SectionLabel('負債'),
                    ...liabilityAccounts.map((acc) => _BalanceRow(
                          account: acc,
                          controller: _ctrl(acc.id),
                        )),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: FilledButton.icon(
                    onPressed: () => _save(allAccounts),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('保存する'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 18,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '残高がある科目に金額を入力してください。空欄の科目はスキップされます。',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary)),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final Account account;
  final TextEditingController controller;
  const _BalanceRow({required this.account, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(account.name, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                prefixText: '¥',
                border: OutlineInputBorder(),
                hintText: '0',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
