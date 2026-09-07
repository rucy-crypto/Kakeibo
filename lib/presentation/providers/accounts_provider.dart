import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_ledger/data/database/app_database.dart';
import 'package:simple_ledger/domain/enums/account_group.dart';
import 'package:simple_ledger/presentation/providers/database_provider.dart';

final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.accountsDao.watchAllAccounts();
});

final accountsByGroupProvider =
    Provider<AsyncValue<Map<AccountGroup, List<Account>>>>((ref) {
  return ref.watch(accountsStreamProvider).whenData((accounts) {
    final map = <AccountGroup, List<Account>>{};
    for (final g in AccountGroup.values) {
      map[g] = accounts.where((a) => a.groupIndex == g.index).toList();
    }
    return map;
  });
});

final addAccountProvider =
    Provider<Future<void> Function(String, AccountGroup, [int?])>((ref) {
  final db = ref.watch(databaseProvider);
  return (name, group, [parentId]) async {
    await db.accountsDao.insertAccount(
      AccountsCompanion.insert(
        name: name,
        groupIndex: group.index,
        parentAccountId: Value(parentId),
      ),
    );
  };
});

final setParentAccountProvider =
    Provider<Future<void> Function(int, int?)>((ref) {
  final db = ref.watch(databaseProvider);
  return (accountId, parentId) =>
      db.accountsDao.setParentAccount(accountId, parentId);
});

final deleteAccountProvider = Provider<Future<void> Function(Account)>((ref) {
  final db = ref.watch(databaseProvider);
  return (account) async {
    // 子科目の親リンクをリセットしてから削除
    await db.accountsDao.clearChildParents(account.id);
    await db.accountsDao.deleteAccount(account.id);
  };
});
