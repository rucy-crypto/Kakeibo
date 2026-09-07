import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_ledger/data/database/app_database.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:simple_ledger/presentation/providers/accounts_provider.dart';

enum _RootAction { addChild, delete }
enum _ChildAction { detach, delete }

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _fabVisible = true;
  double _lastScrollOffset = 0;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is ScrollStartNotification) {
      _lastScrollOffset = notification.metrics.pixels;
      return false;
    }
    if (notification is ScrollUpdateNotification) {
      final delta = notification.metrics.pixels - _lastScrollOffset;
      _lastScrollOffset = notification.metrics.pixels;
      if (notification.metrics.pixels <= 0) {
        if (!_fabVisible) setState(() => _fabVisible = true);
      } else if (delta > 4 && _fabVisible) {
        setState(() => _fabVisible = false);
      } else if (delta < -4 && !_fabVisible) {
        setState(() => _fabVisible = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final deleteAccount = ref.read(deleteAccountProvider);
    final setParentAccount = ref.read(setParentAccountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('勘定科目')),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: accountsAsync.when(
          data: (accounts) {
            final grouped = <AccountGroup, List<Account>>{};
            for (final g in AccountGroup.values) {
              grouped[g] =
                  accounts.where((a) => a.groupIndex == g.index).toList();
            }
            return ListView(
              children: AccountGroup.values.map((group) {
                final list = grouped[group] ?? [];
                return _GroupSection(
                  group: group,
                  accounts: list,
                  onDelete: (acc) async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('削除しますか？'),
                        content:
                            Text('「${acc.name}」を削除します。\n既存の仕訳には影響しません。'),
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
                    if (ok == true) await deleteAccount(acc);
                  },
                  onAddChild: (parent) =>
                      _showAddDialog(context, preselectedParent: parent),
                  onDetachParent: (child) async {
                    await setParentAccount(child.id, null);
                  },
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _fabVisible ? Offset.zero : const Offset(0, 1.5),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _fabVisible ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('科目を追加'),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context,
      {Account? preselectedParent}) async {
    final addAccount = ref.read(addAccountProvider);
    final accounts = ref.read(accountsStreamProvider).valueOrNull ?? [];
    await showDialog<void>(
      context: context,
      builder: (ctx) => _AddAccountDialog(
        onAdd: addAccount,
        allAccounts: accounts,
        preselectedParent: preselectedParent,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AddAccountDialog extends StatefulWidget {
  final Future<void> Function(String, AccountGroup, [int?]) onAdd;
  final List<Account> allAccounts;
  final Account? preselectedParent;

  const _AddAccountDialog({
    required this.onAdd,
    required this.allAccounts,
    this.preselectedParent,
  });

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  final _nameCtrl = TextEditingController();
  late AccountGroup _group;
  int? _parentId;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedParent != null) {
      _group = AccountGroup.values[widget.preselectedParent!.groupIndex];
      _parentId = widget.preselectedParent!.id;
    } else {
      _group = AccountGroup.expense;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  List<Account> get _parentCandidates => widget.allAccounts
      .where((a) =>
          a.groupIndex == _group.index && a.parentAccountId == null)
      .toList();

  @override
  Widget build(BuildContext context) {
    final candidates = _parentCandidates;
    final effectiveParentId =
        candidates.any((a) => a.id == _parentId) ? _parentId : null;

    return AlertDialog(
      title: const Text('勘定科目を追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: '科目名',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'グループ',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AccountGroup>(
                value: _group,
                isExpanded: true,
                onChanged: widget.preselectedParent != null
                    ? null
                    : (g) {
                        if (g != null) {
                          setState(() {
                            _group = g;
                            _parentId = null;
                          });
                        }
                      },
                items: AccountGroup.values
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g.displayName),
                        ))
                    .toList(),
              ),
            ),
          ),
          if (candidates.isNotEmpty) ...[
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: '親科目（任意）',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: effectiveParentId,
                  isExpanded: true,
                  onChanged: widget.preselectedParent != null
                      ? null
                      : (v) => setState(() => _parentId = v),
                  items: [
                    const DropdownMenuItem<int?>(
                        value: null, child: Text('なし（独立科目）')),
                    ...candidates.map((a) => DropdownMenuItem<int?>(
                        value: a.id, child: Text(a.name))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context);
            await widget.onAdd(name, _group, effectiveParentId);
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _GroupSection extends StatelessWidget {
  final AccountGroup group;
  final List<Account> accounts;
  final Future<void> Function(Account) onDelete;
  final void Function(Account parent) onAddChild;
  final Future<void> Function(Account child) onDetachParent;

  const _GroupSection({
    required this.group,
    required this.accounts,
    required this.onDelete,
    required this.onAddChild,
    required this.onDetachParent,
  });

  @override
  Widget build(BuildContext context) {
    final accountIds = accounts.map((a) => a.id).toSet();
    final childrenOf = <int, List<Account>>{};
    for (final a in accounts) {
      if (a.parentAccountId != null && accountIds.contains(a.parentAccountId)) {
        childrenOf.putIfAbsent(a.parentAccountId!, () => []).add(a);
      }
    }
    final roots = accounts
        .where((a) =>
            a.parentAccountId == null ||
            !accountIds.contains(a.parentAccountId))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            group.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (roots.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('科目なし', style: TextStyle(color: Colors.grey)),
          ),
        ...roots.expand<Widget>((root) {
          final children = childrenOf[root.id] ?? [];
          return [
            ListTile(
              title: Text(
                root.name,
                style: children.isNotEmpty
                    ? const TextStyle(fontWeight: FontWeight.w600)
                    : null,
              ),
              trailing: PopupMenuButton<_RootAction>(
                onSelected: (action) {
                  switch (action) {
                    case _RootAction.addChild:
                      onAddChild(root);
                    case _RootAction.delete:
                      onDelete(root);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: _RootAction.addChild,
                    child: Text('子科目を追加'),
                  ),
                  const PopupMenuItem(
                    value: _RootAction.delete,
                    child: Text('削除', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            ...children.map((child) => ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 32, right: 8),
                  leading: const Icon(
                    Icons.subdirectory_arrow_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                  title: Text(child.name),
                  trailing: PopupMenuButton<_ChildAction>(
                    onSelected: (action) {
                      switch (action) {
                        case _ChildAction.detach:
                          onDetachParent(child);
                        case _ChildAction.delete:
                          onDelete(child);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: _ChildAction.detach,
                        child: Text('独立科目にする'),
                      ),
                      const PopupMenuItem(
                        value: _ChildAction.delete,
                        child: Text('削除',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                )),
          ];
        }),
        const Divider(height: 1),
      ],
    );
  }
}
