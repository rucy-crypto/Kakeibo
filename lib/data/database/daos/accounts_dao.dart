import 'package:drift/drift.dart';
import 'package:simple_ledger/data/database/app_database.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Stream<List<Account>> watchAllAccounts() =>
      (select(accounts)
            ..orderBy([
              (a) => OrderingTerm.asc(a.groupIndex),
              (a) => OrderingTerm.asc(a.displayOrder),
            ]))
          .watch();

  Future<void> insertAccount(AccountsCompanion account) =>
      into(accounts).insert(account);

  Future<void> deleteAccount(int id) =>
      (delete(accounts)..where((a) => a.id.equals(id))).go();

  Future<void> setParentAccount(int accountId, int? parentId) =>
      (update(accounts)..where((a) => a.id.equals(accountId)))
          .write(AccountsCompanion(parentAccountId: Value(parentId)));

  // 削除前に子科目の親IDをnullにリセット
  Future<void> clearChildParents(int parentId) =>
      (update(accounts)..where((a) => a.parentAccountId.equals(parentId)))
          .write(const AccountsCompanion(parentAccountId: Value(null)));
}
