// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _groupIndexMeta =
      const VerificationMeta('groupIndex');
  @override
  late final GeneratedColumn<int> groupIndex = GeneratedColumn<int>(
      'group_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _parentAccountIdMeta =
      const VerificationMeta('parentAccountId');
  @override
  late final GeneratedColumn<int> parentAccountId = GeneratedColumn<int>(
      'parent_account_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, groupIndex, displayOrder, isDefault, parentAccountId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group_index')) {
      context.handle(
          _groupIndexMeta,
          groupIndex.isAcceptableOrUnknown(
              data['group_index']!, _groupIndexMeta));
    } else if (isInserting) {
      context.missing(_groupIndexMeta);
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('parent_account_id')) {
      context.handle(
          _parentAccountIdMeta,
          parentAccountId.isAcceptableOrUnknown(
              data['parent_account_id']!, _parentAccountIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      groupIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_index'])!,
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      parentAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_account_id']),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;
  final int groupIndex;
  final int displayOrder;
  final bool isDefault;
  final int? parentAccountId;
  const Account(
      {required this.id,
      required this.name,
      required this.groupIndex,
      required this.displayOrder,
      required this.isDefault,
      this.parentAccountId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['group_index'] = Variable<int>(groupIndex);
    map['display_order'] = Variable<int>(displayOrder);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || parentAccountId != null) {
      map['parent_account_id'] = Variable<int>(parentAccountId);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      groupIndex: Value(groupIndex),
      displayOrder: Value(displayOrder),
      isDefault: Value(isDefault),
      parentAccountId: parentAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentAccountId),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      groupIndex: serializer.fromJson<int>(json['groupIndex']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      parentAccountId: serializer.fromJson<int?>(json['parentAccountId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'groupIndex': serializer.toJson<int>(groupIndex),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'isDefault': serializer.toJson<bool>(isDefault),
      'parentAccountId': serializer.toJson<int?>(parentAccountId),
    };
  }

  Account copyWith(
          {int? id,
          String? name,
          int? groupIndex,
          int? displayOrder,
          bool? isDefault,
          Value<int?> parentAccountId = const Value.absent()}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        groupIndex: groupIndex ?? this.groupIndex,
        displayOrder: displayOrder ?? this.displayOrder,
        isDefault: isDefault ?? this.isDefault,
        parentAccountId: parentAccountId.present
            ? parentAccountId.value
            : this.parentAccountId,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      groupIndex:
          data.groupIndex.present ? data.groupIndex.value : this.groupIndex,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      parentAccountId: data.parentAccountId.present
          ? data.parentAccountId.value
          : this.parentAccountId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('isDefault: $isDefault, ')
          ..write('parentAccountId: $parentAccountId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, groupIndex, displayOrder, isDefault, parentAccountId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.groupIndex == this.groupIndex &&
          other.displayOrder == this.displayOrder &&
          other.isDefault == this.isDefault &&
          other.parentAccountId == this.parentAccountId);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> groupIndex;
  final Value<int> displayOrder;
  final Value<bool> isDefault;
  final Value<int?> parentAccountId;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.groupIndex = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.parentAccountId = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int groupIndex,
    this.displayOrder = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.parentAccountId = const Value.absent(),
  })  : name = Value(name),
        groupIndex = Value(groupIndex);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? groupIndex,
    Expression<int>? displayOrder,
    Expression<bool>? isDefault,
    Expression<int>? parentAccountId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (groupIndex != null) 'group_index': groupIndex,
      if (displayOrder != null) 'display_order': displayOrder,
      if (isDefault != null) 'is_default': isDefault,
      if (parentAccountId != null) 'parent_account_id': parentAccountId,
    });
  }

  AccountsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? groupIndex,
      Value<int>? displayOrder,
      Value<bool>? isDefault,
      Value<int?>? parentAccountId}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      groupIndex: groupIndex ?? this.groupIndex,
      displayOrder: displayOrder ?? this.displayOrder,
      isDefault: isDefault ?? this.isDefault,
      parentAccountId: parentAccountId ?? this.parentAccountId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupIndex.present) {
      map['group_index'] = Variable<int>(groupIndex.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (parentAccountId.present) {
      map['parent_account_id'] = Variable<int>(parentAccountId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('isDefault: $isDefault, ')
          ..write('parentAccountId: $parentAccountId')
          ..write(')'))
        .toString();
  }
}

class $FinancialTransactionsTable extends FinancialTransactions
    with TableInfo<$FinancialTransactionsTable, FinancialTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [id, date, description, memo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<FinancialTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancialTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo'])!,
    );
  }

  @override
  $FinancialTransactionsTable createAlias(String alias) {
    return $FinancialTransactionsTable(attachedDatabase, alias);
  }
}

class FinancialTransaction extends DataClass
    implements Insertable<FinancialTransaction> {
  final String id;
  final DateTime date;
  final String description;
  final String memo;
  const FinancialTransaction(
      {required this.id,
      required this.date,
      required this.description,
      required this.memo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['description'] = Variable<String>(description);
    map['memo'] = Variable<String>(memo);
    return map;
  }

  FinancialTransactionsCompanion toCompanion(bool nullToAbsent) {
    return FinancialTransactionsCompanion(
      id: Value(id),
      date: Value(date),
      description: Value(description),
      memo: Value(memo),
    );
  }

  factory FinancialTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialTransaction(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      memo: serializer.fromJson<String>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String>(description),
      'memo': serializer.toJson<String>(memo),
    };
  }

  FinancialTransaction copyWith(
          {String? id, DateTime? date, String? description, String? memo}) =>
      FinancialTransaction(
        id: id ?? this.id,
        date: date ?? this.date,
        description: description ?? this.description,
        memo: memo ?? this.memo,
      );
  FinancialTransaction copyWithCompanion(FinancialTransactionsCompanion data) {
    return FinancialTransaction(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      description:
          data.description.present ? data.description.value : this.description,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialTransaction(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, description, memo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialTransaction &&
          other.id == this.id &&
          other.date == this.date &&
          other.description == this.description &&
          other.memo == this.memo);
}

class FinancialTransactionsCompanion
    extends UpdateCompanion<FinancialTransaction> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> description;
  final Value<String> memo;
  final Value<int> rowid;
  const FinancialTransactionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.memo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialTransactionsCompanion.insert({
    required String id,
    required DateTime date,
    required String description,
    this.memo = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        description = Value(description);
  static Insertable<FinancialTransaction> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<String>? memo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (memo != null) 'memo': memo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<String>? description,
      Value<String>? memo,
      Value<int>? rowid}) {
    return FinancialTransactionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      memo: memo ?? this.memo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('memo: $memo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES financial_transactions (id)'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _entryTypeIndexMeta =
      const VerificationMeta('entryTypeIndex');
  @override
  late final GeneratedColumn<int> entryTypeIndex = GeneratedColumn<int>(
      'entry_type_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, transactionId, accountId, entryTypeIndex, amount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(Insertable<JournalEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('entry_type_index')) {
      context.handle(
          _entryTypeIndexMeta,
          entryTypeIndex.isAcceptableOrUnknown(
              data['entry_type_index']!, _entryTypeIndexMeta));
    } else if (isInserting) {
      context.missing(_entryTypeIndexMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      entryTypeIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entry_type_index'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final int id;
  final String transactionId;
  final int accountId;
  final int entryTypeIndex;
  final double amount;
  const JournalEntry(
      {required this.id,
      required this.transactionId,
      required this.accountId,
      required this.entryTypeIndex,
      required this.amount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['account_id'] = Variable<int>(accountId);
    map['entry_type_index'] = Variable<int>(entryTypeIndex);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      accountId: Value(accountId),
      entryTypeIndex: Value(entryTypeIndex),
      amount: Value(amount),
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      entryTypeIndex: serializer.fromJson<int>(json['entryTypeIndex']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'accountId': serializer.toJson<int>(accountId),
      'entryTypeIndex': serializer.toJson<int>(entryTypeIndex),
      'amount': serializer.toJson<double>(amount),
    };
  }

  JournalEntry copyWith(
          {int? id,
          String? transactionId,
          int? accountId,
          int? entryTypeIndex,
          double? amount}) =>
      JournalEntry(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        accountId: accountId ?? this.accountId,
        entryTypeIndex: entryTypeIndex ?? this.entryTypeIndex,
        amount: amount ?? this.amount,
      );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      entryTypeIndex: data.entryTypeIndex.present
          ? data.entryTypeIndex.value
          : this.entryTypeIndex,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('entryTypeIndex: $entryTypeIndex, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, transactionId, accountId, entryTypeIndex, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.accountId == this.accountId &&
          other.entryTypeIndex == this.entryTypeIndex &&
          other.amount == this.amount);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<int> id;
  final Value<String> transactionId;
  final Value<int> accountId;
  final Value<int> entryTypeIndex;
  final Value<double> amount;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.entryTypeIndex = const Value.absent(),
    this.amount = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String transactionId,
    required int accountId,
    required int entryTypeIndex,
    required double amount,
  })  : transactionId = Value(transactionId),
        accountId = Value(accountId),
        entryTypeIndex = Value(entryTypeIndex),
        amount = Value(amount);
  static Insertable<JournalEntry> custom({
    Expression<int>? id,
    Expression<String>? transactionId,
    Expression<int>? accountId,
    Expression<int>? entryTypeIndex,
    Expression<double>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (accountId != null) 'account_id': accountId,
      if (entryTypeIndex != null) 'entry_type_index': entryTypeIndex,
      if (amount != null) 'amount': amount,
    });
  }

  JournalEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? transactionId,
      Value<int>? accountId,
      Value<int>? entryTypeIndex,
      Value<double>? amount}) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      accountId: accountId ?? this.accountId,
      entryTypeIndex: entryTypeIndex ?? this.entryTypeIndex,
      amount: amount ?? this.amount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (entryTypeIndex.present) {
      map['entry_type_index'] = Variable<int>(entryTypeIndex.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('entryTypeIndex: $entryTypeIndex, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _debitAccountIdMeta =
      const VerificationMeta('debitAccountId');
  @override
  late final GeneratedColumn<int> debitAccountId = GeneratedColumn<int>(
      'debit_account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _creditAccountIdMeta =
      const VerificationMeta('creditAccountId');
  @override
  late final GeneratedColumn<int> creditAccountId = GeneratedColumn<int>(
      'credit_account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dayOfMonthMeta =
      const VerificationMeta('dayOfMonth');
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
      'day_of_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        debitAccountId,
        creditAccountId,
        amount,
        dayOfMonth,
        memo,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('debit_account_id')) {
      context.handle(
          _debitAccountIdMeta,
          debitAccountId.isAcceptableOrUnknown(
              data['debit_account_id']!, _debitAccountIdMeta));
    } else if (isInserting) {
      context.missing(_debitAccountIdMeta);
    }
    if (data.containsKey('credit_account_id')) {
      context.handle(
          _creditAccountIdMeta,
          creditAccountId.isAcceptableOrUnknown(
              data['credit_account_id']!, _creditAccountIdMeta));
    } else if (isInserting) {
      context.missing(_creditAccountIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
          _dayOfMonthMeta,
          dayOfMonth.isAcceptableOrUnknown(
              data['day_of_month']!, _dayOfMonthMeta));
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      debitAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}debit_account_id'])!,
      creditAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credit_account_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount']),
      dayOfMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_month'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }
}

class RecurringRule extends DataClass implements Insertable<RecurringRule> {
  final int id;
  final String name;
  final int debitAccountId;
  final int creditAccountId;
  final double? amount;
  final int dayOfMonth;
  final String memo;
  final bool isActive;
  const RecurringRule(
      {required this.id,
      required this.name,
      required this.debitAccountId,
      required this.creditAccountId,
      this.amount,
      required this.dayOfMonth,
      required this.memo,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['debit_account_id'] = Variable<int>(debitAccountId);
    map['credit_account_id'] = Variable<int>(creditAccountId);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['memo'] = Variable<String>(memo);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      name: Value(name),
      debitAccountId: Value(debitAccountId),
      creditAccountId: Value(creditAccountId),
      amount:
          amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      dayOfMonth: Value(dayOfMonth),
      memo: Value(memo),
      isActive: Value(isActive),
    );
  }

  factory RecurringRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRule(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      debitAccountId: serializer.fromJson<int>(json['debitAccountId']),
      creditAccountId: serializer.fromJson<int>(json['creditAccountId']),
      amount: serializer.fromJson<double?>(json['amount']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      memo: serializer.fromJson<String>(json['memo']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'debitAccountId': serializer.toJson<int>(debitAccountId),
      'creditAccountId': serializer.toJson<int>(creditAccountId),
      'amount': serializer.toJson<double?>(amount),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'memo': serializer.toJson<String>(memo),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  RecurringRule copyWith(
          {int? id,
          String? name,
          int? debitAccountId,
          int? creditAccountId,
          Value<double?> amount = const Value.absent(),
          int? dayOfMonth,
          String? memo,
          bool? isActive}) =>
      RecurringRule(
        id: id ?? this.id,
        name: name ?? this.name,
        debitAccountId: debitAccountId ?? this.debitAccountId,
        creditAccountId: creditAccountId ?? this.creditAccountId,
        amount: amount.present ? amount.value : this.amount,
        dayOfMonth: dayOfMonth ?? this.dayOfMonth,
        memo: memo ?? this.memo,
        isActive: isActive ?? this.isActive,
      );
  RecurringRule copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      debitAccountId: data.debitAccountId.present
          ? data.debitAccountId.value
          : this.debitAccountId,
      creditAccountId: data.creditAccountId.present
          ? data.creditAccountId.value
          : this.creditAccountId,
      amount: data.amount.present ? data.amount.value : this.amount,
      dayOfMonth:
          data.dayOfMonth.present ? data.dayOfMonth.value : this.dayOfMonth,
      memo: data.memo.present ? data.memo.value : this.memo,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('debitAccountId: $debitAccountId, ')
          ..write('creditAccountId: $creditAccountId, ')
          ..write('amount: $amount, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('memo: $memo, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, debitAccountId, creditAccountId,
      amount, dayOfMonth, memo, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRule &&
          other.id == this.id &&
          other.name == this.name &&
          other.debitAccountId == this.debitAccountId &&
          other.creditAccountId == this.creditAccountId &&
          other.amount == this.amount &&
          other.dayOfMonth == this.dayOfMonth &&
          other.memo == this.memo &&
          other.isActive == this.isActive);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRule> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> debitAccountId;
  final Value<int> creditAccountId;
  final Value<double?> amount;
  final Value<int> dayOfMonth;
  final Value<String> memo;
  final Value<bool> isActive;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.debitAccountId = const Value.absent(),
    this.creditAccountId = const Value.absent(),
    this.amount = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.memo = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int debitAccountId,
    required int creditAccountId,
    this.amount = const Value.absent(),
    required int dayOfMonth,
    this.memo = const Value.absent(),
    this.isActive = const Value.absent(),
  })  : name = Value(name),
        debitAccountId = Value(debitAccountId),
        creditAccountId = Value(creditAccountId),
        dayOfMonth = Value(dayOfMonth);
  static Insertable<RecurringRule> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? debitAccountId,
    Expression<int>? creditAccountId,
    Expression<double>? amount,
    Expression<int>? dayOfMonth,
    Expression<String>? memo,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (debitAccountId != null) 'debit_account_id': debitAccountId,
      if (creditAccountId != null) 'credit_account_id': creditAccountId,
      if (amount != null) 'amount': amount,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (memo != null) 'memo': memo,
      if (isActive != null) 'is_active': isActive,
    });
  }

  RecurringRulesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? debitAccountId,
      Value<int>? creditAccountId,
      Value<double?>? amount,
      Value<int>? dayOfMonth,
      Value<String>? memo,
      Value<bool>? isActive}) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      debitAccountId: debitAccountId ?? this.debitAccountId,
      creditAccountId: creditAccountId ?? this.creditAccountId,
      amount: amount ?? this.amount,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      memo: memo ?? this.memo,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (debitAccountId.present) {
      map['debit_account_id'] = Variable<int>(debitAccountId.value);
    }
    if (creditAccountId.present) {
      map['credit_account_id'] = Variable<int>(creditAccountId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('debitAccountId: $debitAccountId, ')
          ..write('creditAccountId: $creditAccountId, ')
          ..write('amount: $amount, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('memo: $memo, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $RecurringLogsTable extends RecurringLogs
    with TableInfo<$RecurringLogsTable, RecurringLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
      'rule_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_rules (id)'));
  static const VerificationMeta _generatedForMeta =
      const VerificationMeta('generatedFor');
  @override
  late final GeneratedColumn<String> generatedFor = GeneratedColumn<String>(
      'generated_for', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ruleId, generatedFor, transactionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_logs';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rule_id')) {
      context.handle(_ruleIdMeta,
          ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta));
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('generated_for')) {
      context.handle(
          _generatedForMeta,
          generatedFor.isAcceptableOrUnknown(
              data['generated_for']!, _generatedForMeta));
    } else if (isInserting) {
      context.missing(_generatedForMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ruleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rule_id'])!,
      generatedFor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}generated_for'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id']),
    );
  }

  @override
  $RecurringLogsTable createAlias(String alias) {
    return $RecurringLogsTable(attachedDatabase, alias);
  }
}

class RecurringLog extends DataClass implements Insertable<RecurringLog> {
  final int id;
  final int ruleId;
  final String generatedFor;
  final String? transactionId;
  const RecurringLog(
      {required this.id,
      required this.ruleId,
      required this.generatedFor,
      this.transactionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rule_id'] = Variable<int>(ruleId);
    map['generated_for'] = Variable<String>(generatedFor);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    return map;
  }

  RecurringLogsCompanion toCompanion(bool nullToAbsent) {
    return RecurringLogsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      generatedFor: Value(generatedFor),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
    );
  }

  factory RecurringLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringLog(
      id: serializer.fromJson<int>(json['id']),
      ruleId: serializer.fromJson<int>(json['ruleId']),
      generatedFor: serializer.fromJson<String>(json['generatedFor']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ruleId': serializer.toJson<int>(ruleId),
      'generatedFor': serializer.toJson<String>(generatedFor),
      'transactionId': serializer.toJson<String?>(transactionId),
    };
  }

  RecurringLog copyWith(
          {int? id,
          int? ruleId,
          String? generatedFor,
          Value<String?> transactionId = const Value.absent()}) =>
      RecurringLog(
        id: id ?? this.id,
        ruleId: ruleId ?? this.ruleId,
        generatedFor: generatedFor ?? this.generatedFor,
        transactionId:
            transactionId.present ? transactionId.value : this.transactionId,
      );
  RecurringLog copyWithCompanion(RecurringLogsCompanion data) {
    return RecurringLog(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      generatedFor: data.generatedFor.present
          ? data.generatedFor.value
          : this.generatedFor,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringLog(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('generatedFor: $generatedFor, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ruleId, generatedFor, transactionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringLog &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.generatedFor == this.generatedFor &&
          other.transactionId == this.transactionId);
}

class RecurringLogsCompanion extends UpdateCompanion<RecurringLog> {
  final Value<int> id;
  final Value<int> ruleId;
  final Value<String> generatedFor;
  final Value<String?> transactionId;
  const RecurringLogsCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.generatedFor = const Value.absent(),
    this.transactionId = const Value.absent(),
  });
  RecurringLogsCompanion.insert({
    this.id = const Value.absent(),
    required int ruleId,
    required String generatedFor,
    this.transactionId = const Value.absent(),
  })  : ruleId = Value(ruleId),
        generatedFor = Value(generatedFor);
  static Insertable<RecurringLog> custom({
    Expression<int>? id,
    Expression<int>? ruleId,
    Expression<String>? generatedFor,
    Expression<String>? transactionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (generatedFor != null) 'generated_for': generatedFor,
      if (transactionId != null) 'transaction_id': transactionId,
    });
  }

  RecurringLogsCompanion copyWith(
      {Value<int>? id,
      Value<int>? ruleId,
      Value<String>? generatedFor,
      Value<String?>? transactionId}) {
    return RecurringLogsCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      generatedFor: generatedFor ?? this.generatedFor,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    if (generatedFor.present) {
      map['generated_for'] = Variable<String>(generatedFor.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringLogsCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('generatedFor: $generatedFor, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $FinancialTransactionsTable financialTransactions =
      $FinancialTransactionsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $RecurringLogsTable recurringLogs = $RecurringLogsTable(this);
  late final AccountsDao accountsDao = AccountsDao(this as AppDatabase);
  late final TransactionsDao transactionsDao =
      TransactionsDao(this as AppDatabase);
  late final RecurringDao recurringDao = RecurringDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        financialTransactions,
        journalEntries,
        recurringRules,
        recurringLogs
      ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  required int groupIndex,
  Value<int> displayOrder,
  Value<bool> isDefault,
  Value<int?> parentAccountId,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> groupIndex,
  Value<int> displayOrder,
  Value<bool> isDefault,
  Value<int?> parentAccountId,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _parentAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
          $_aliasNameGenerator(db.accounts.parentAccountId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get parentAccountId {
    final $_column = $_itemColumn<int>('parent_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$JournalEntriesTable, List<JournalEntry>>
      _journalEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.journalEntries,
              aliasName: $_aliasNameGenerator(
                  db.accounts.id, db.journalEntries.accountId));

  $$JournalEntriesTableProcessedTableManager get journalEntriesRefs {
    final manager = $$JournalEntriesTableTableManager($_db, $_db.journalEntries)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_journalEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get groupIndex => $composableBuilder(
      column: $table.groupIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get parentAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> journalEntriesRefs(
      Expression<bool> Function($$JournalEntriesTableFilterComposer f) f) {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.journalEntries,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalEntriesTableFilterComposer(
              $db: $db,
              $table: $db.journalEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get groupIndex => $composableBuilder(
      column: $table.groupIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get parentAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get groupIndex => $composableBuilder(
      column: $table.groupIndex, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  $$AccountsTableAnnotationComposer get parentAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> journalEntriesRefs<T extends Object>(
      Expression<T> Function($$JournalEntriesTableAnnotationComposer a) f) {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.journalEntries,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.journalEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool parentAccountId, bool journalEntriesRefs})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> groupIndex = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<int?> parentAccountId = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            groupIndex: groupIndex,
            displayOrder: displayOrder,
            isDefault: isDefault,
            parentAccountId: parentAccountId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int groupIndex,
            Value<int> displayOrder = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<int?> parentAccountId = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            groupIndex: groupIndex,
            displayOrder: displayOrder,
            isDefault: isDefault,
            parentAccountId: parentAccountId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {parentAccountId = false, journalEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (journalEntriesRefs) db.journalEntries
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (parentAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentAccountId,
                    referencedTable:
                        $$AccountsTableReferences._parentAccountIdTable(db),
                    referencedColumn:
                        $$AccountsTableReferences._parentAccountIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (journalEntriesRefs)
                    await $_getPrefetchedData<Account, $AccountsTable,
                            JournalEntry>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._journalEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .journalEntriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool parentAccountId, bool journalEntriesRefs})>;
typedef $$FinancialTransactionsTableCreateCompanionBuilder
    = FinancialTransactionsCompanion Function({
  required String id,
  required DateTime date,
  required String description,
  Value<String> memo,
  Value<int> rowid,
});
typedef $$FinancialTransactionsTableUpdateCompanionBuilder
    = FinancialTransactionsCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<String> description,
  Value<String> memo,
  Value<int> rowid,
});

final class $$FinancialTransactionsTableReferences extends BaseReferences<
    _$AppDatabase, $FinancialTransactionsTable, FinancialTransaction> {
  $$FinancialTransactionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$JournalEntriesTable, List<JournalEntry>>
      _journalEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.journalEntries,
              aliasName: $_aliasNameGenerator(db.financialTransactions.id,
                  db.journalEntries.transactionId));

  $$JournalEntriesTableProcessedTableManager get journalEntriesRefs {
    final manager = $$JournalEntriesTableTableManager($_db, $_db.journalEntries)
        .filter(
            (f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_journalEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FinancialTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $FinancialTransactionsTable> {
  $$FinancialTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  Expression<bool> journalEntriesRefs(
      Expression<bool> Function($$JournalEntriesTableFilterComposer f) f) {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.journalEntries,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalEntriesTableFilterComposer(
              $db: $db,
              $table: $db.journalEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FinancialTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancialTransactionsTable> {
  $$FinancialTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));
}

class $$FinancialTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancialTransactionsTable> {
  $$FinancialTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  Expression<T> journalEntriesRefs<T extends Object>(
      Expression<T> Function($$JournalEntriesTableAnnotationComposer a) f) {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.journalEntries,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JournalEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.journalEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FinancialTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FinancialTransactionsTable,
    FinancialTransaction,
    $$FinancialTransactionsTableFilterComposer,
    $$FinancialTransactionsTableOrderingComposer,
    $$FinancialTransactionsTableAnnotationComposer,
    $$FinancialTransactionsTableCreateCompanionBuilder,
    $$FinancialTransactionsTableUpdateCompanionBuilder,
    (FinancialTransaction, $$FinancialTransactionsTableReferences),
    FinancialTransaction,
    PrefetchHooks Function({bool journalEntriesRefs})> {
  $$FinancialTransactionsTableTableManager(
      _$AppDatabase db, $FinancialTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialTransactionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> memo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialTransactionsCompanion(
            id: id,
            date: date,
            description: description,
            memo: memo,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            required String description,
            Value<String> memo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialTransactionsCompanion.insert(
            id: id,
            date: date,
            description: description,
            memo: memo,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FinancialTransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({journalEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (journalEntriesRefs) db.journalEntries
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (journalEntriesRefs)
                    await $_getPrefetchedData<FinancialTransaction,
                            $FinancialTransactionsTable, JournalEntry>(
                        currentTable: table,
                        referencedTable: $$FinancialTransactionsTableReferences
                            ._journalEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FinancialTransactionsTableReferences(
                                    db, table, p0)
                                .journalEntriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FinancialTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $FinancialTransactionsTable,
        FinancialTransaction,
        $$FinancialTransactionsTableFilterComposer,
        $$FinancialTransactionsTableOrderingComposer,
        $$FinancialTransactionsTableAnnotationComposer,
        $$FinancialTransactionsTableCreateCompanionBuilder,
        $$FinancialTransactionsTableUpdateCompanionBuilder,
        (FinancialTransaction, $$FinancialTransactionsTableReferences),
        FinancialTransaction,
        PrefetchHooks Function({bool journalEntriesRefs})>;
typedef $$JournalEntriesTableCreateCompanionBuilder = JournalEntriesCompanion
    Function({
  Value<int> id,
  required String transactionId,
  required int accountId,
  required int entryTypeIndex,
  required double amount,
});
typedef $$JournalEntriesTableUpdateCompanionBuilder = JournalEntriesCompanion
    Function({
  Value<int> id,
  Value<String> transactionId,
  Value<int> accountId,
  Value<int> entryTypeIndex,
  Value<double> amount,
});

final class $$JournalEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry> {
  $$JournalEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $FinancialTransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.financialTransactions.createAlias($_aliasNameGenerator(
          db.journalEntries.transactionId, db.financialTransactions.id));

  $$FinancialTransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$FinancialTransactionsTableTableManager(
            $_db, $_db.financialTransactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
          $_aliasNameGenerator(db.journalEntries.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entryTypeIndex => $composableBuilder(
      column: $table.entryTypeIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  $$FinancialTransactionsTableFilterComposer get transactionId {
    final $$FinancialTransactionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transactionId,
            referencedTable: $db.financialTransactions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$FinancialTransactionsTableFilterComposer(
                  $db: $db,
                  $table: $db.financialTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entryTypeIndex => $composableBuilder(
      column: $table.entryTypeIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  $$FinancialTransactionsTableOrderingComposer get transactionId {
    final $$FinancialTransactionsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transactionId,
            referencedTable: $db.financialTransactions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$FinancialTransactionsTableOrderingComposer(
                  $db: $db,
                  $table: $db.financialTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get entryTypeIndex => $composableBuilder(
      column: $table.entryTypeIndex, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$FinancialTransactionsTableAnnotationComposer get transactionId {
    final $$FinancialTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transactionId,
            referencedTable: $db.financialTransactions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$FinancialTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.financialTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$JournalEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JournalEntriesTable,
    JournalEntry,
    $$JournalEntriesTableFilterComposer,
    $$JournalEntriesTableOrderingComposer,
    $$JournalEntriesTableAnnotationComposer,
    $$JournalEntriesTableCreateCompanionBuilder,
    $$JournalEntriesTableUpdateCompanionBuilder,
    (JournalEntry, $$JournalEntriesTableReferences),
    JournalEntry,
    PrefetchHooks Function({bool transactionId, bool accountId})> {
  $$JournalEntriesTableTableManager(
      _$AppDatabase db, $JournalEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> transactionId = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<int> entryTypeIndex = const Value.absent(),
            Value<double> amount = const Value.absent(),
          }) =>
              JournalEntriesCompanion(
            id: id,
            transactionId: transactionId,
            accountId: accountId,
            entryTypeIndex: entryTypeIndex,
            amount: amount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String transactionId,
            required int accountId,
            required int entryTypeIndex,
            required double amount,
          }) =>
              JournalEntriesCompanion.insert(
            id: id,
            transactionId: transactionId,
            accountId: accountId,
            entryTypeIndex: entryTypeIndex,
            amount: amount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$JournalEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable:
                        $$JournalEntriesTableReferences._transactionIdTable(db),
                    referencedColumn: $$JournalEntriesTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$JournalEntriesTableReferences._accountIdTable(db),
                    referencedColumn:
                        $$JournalEntriesTableReferences._accountIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$JournalEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $JournalEntriesTable,
    JournalEntry,
    $$JournalEntriesTableFilterComposer,
    $$JournalEntriesTableOrderingComposer,
    $$JournalEntriesTableAnnotationComposer,
    $$JournalEntriesTableCreateCompanionBuilder,
    $$JournalEntriesTableUpdateCompanionBuilder,
    (JournalEntry, $$JournalEntriesTableReferences),
    JournalEntry,
    PrefetchHooks Function({bool transactionId, bool accountId})>;
typedef $$RecurringRulesTableCreateCompanionBuilder = RecurringRulesCompanion
    Function({
  Value<int> id,
  required String name,
  required int debitAccountId,
  required int creditAccountId,
  Value<double?> amount,
  required int dayOfMonth,
  Value<String> memo,
  Value<bool> isActive,
});
typedef $$RecurringRulesTableUpdateCompanionBuilder = RecurringRulesCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<int> debitAccountId,
  Value<int> creditAccountId,
  Value<double?> amount,
  Value<int> dayOfMonth,
  Value<String> memo,
  Value<bool> isActive,
});

final class $$RecurringRulesTableReferences
    extends BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule> {
  $$RecurringRulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _debitAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.recurringRules.debitAccountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get debitAccountId {
    final $_column = $_itemColumn<int>('debit_account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debitAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _creditAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.recurringRules.creditAccountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get creditAccountId {
    final $_column = $_itemColumn<int>('credit_account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_creditAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RecurringLogsTable, List<RecurringLog>>
      _recurringLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.recurringLogs,
              aliasName: $_aliasNameGenerator(
                  db.recurringRules.id, db.recurringLogs.ruleId));

  $$RecurringLogsTableProcessedTableManager get recurringLogsRefs {
    final manager = $$RecurringLogsTableTableManager($_db, $_db.recurringLogs)
        .filter((f) => f.ruleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recurringLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get debitAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.debitAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get creditAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.creditAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> recurringLogsRefs(
      Expression<bool> Function($$RecurringLogsTableFilterComposer f) f) {
    final $$RecurringLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringLogs,
        getReferencedColumn: (t) => t.ruleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringLogsTableFilterComposer(
              $db: $db,
              $table: $db.recurringLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get debitAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.debitAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get creditAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.creditAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$AccountsTableAnnotationComposer get debitAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.debitAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get creditAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.creditAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> recurringLogsRefs<T extends Object>(
      Expression<T> Function($$RecurringLogsTableAnnotationComposer a) f) {
    final $$RecurringLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringLogs,
        getReferencedColumn: (t) => t.ruleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.recurringLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecurringRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringRulesTable,
    RecurringRule,
    $$RecurringRulesTableFilterComposer,
    $$RecurringRulesTableOrderingComposer,
    $$RecurringRulesTableAnnotationComposer,
    $$RecurringRulesTableCreateCompanionBuilder,
    $$RecurringRulesTableUpdateCompanionBuilder,
    (RecurringRule, $$RecurringRulesTableReferences),
    RecurringRule,
    PrefetchHooks Function(
        {bool debitAccountId, bool creditAccountId, bool recurringLogsRefs})> {
  $$RecurringRulesTableTableManager(
      _$AppDatabase db, $RecurringRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> debitAccountId = const Value.absent(),
            Value<int> creditAccountId = const Value.absent(),
            Value<double?> amount = const Value.absent(),
            Value<int> dayOfMonth = const Value.absent(),
            Value<String> memo = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              RecurringRulesCompanion(
            id: id,
            name: name,
            debitAccountId: debitAccountId,
            creditAccountId: creditAccountId,
            amount: amount,
            dayOfMonth: dayOfMonth,
            memo: memo,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int debitAccountId,
            required int creditAccountId,
            Value<double?> amount = const Value.absent(),
            required int dayOfMonth,
            Value<String> memo = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              RecurringRulesCompanion.insert(
            id: id,
            name: name,
            debitAccountId: debitAccountId,
            creditAccountId: creditAccountId,
            amount: amount,
            dayOfMonth: dayOfMonth,
            memo: memo,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringRulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {debitAccountId = false,
              creditAccountId = false,
              recurringLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recurringLogsRefs) db.recurringLogs
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (debitAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.debitAccountId,
                    referencedTable: $$RecurringRulesTableReferences
                        ._debitAccountIdTable(db),
                    referencedColumn: $$RecurringRulesTableReferences
                        ._debitAccountIdTable(db)
                        .id,
                  ) as T;
                }
                if (creditAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.creditAccountId,
                    referencedTable: $$RecurringRulesTableReferences
                        ._creditAccountIdTable(db),
                    referencedColumn: $$RecurringRulesTableReferences
                        ._creditAccountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recurringLogsRefs)
                    await $_getPrefetchedData<RecurringRule, $RecurringRulesTable,
                            RecurringLog>(
                        currentTable: table,
                        referencedTable: $$RecurringRulesTableReferences
                            ._recurringLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringRulesTableReferences(db, table, p0)
                                .recurringLogsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ruleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RecurringRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringRulesTable,
    RecurringRule,
    $$RecurringRulesTableFilterComposer,
    $$RecurringRulesTableOrderingComposer,
    $$RecurringRulesTableAnnotationComposer,
    $$RecurringRulesTableCreateCompanionBuilder,
    $$RecurringRulesTableUpdateCompanionBuilder,
    (RecurringRule, $$RecurringRulesTableReferences),
    RecurringRule,
    PrefetchHooks Function(
        {bool debitAccountId, bool creditAccountId, bool recurringLogsRefs})>;
typedef $$RecurringLogsTableCreateCompanionBuilder = RecurringLogsCompanion
    Function({
  Value<int> id,
  required int ruleId,
  required String generatedFor,
  Value<String?> transactionId,
});
typedef $$RecurringLogsTableUpdateCompanionBuilder = RecurringLogsCompanion
    Function({
  Value<int> id,
  Value<int> ruleId,
  Value<String> generatedFor,
  Value<String?> transactionId,
});

final class $$RecurringLogsTableReferences
    extends BaseReferences<_$AppDatabase, $RecurringLogsTable, RecurringLog> {
  $$RecurringLogsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RecurringRulesTable _ruleIdTable(_$AppDatabase db) =>
      db.recurringRules.createAlias(
          $_aliasNameGenerator(db.recurringLogs.ruleId, db.recurringRules.id));

  $$RecurringRulesTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<int>('rule_id')!;

    final manager = $$RecurringRulesTableTableManager($_db, $_db.recurringRules)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecurringLogsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringLogsTable> {
  $$RecurringLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get generatedFor => $composableBuilder(
      column: $table.generatedFor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  $$RecurringRulesTableFilterComposer get ruleId {
    final $$RecurringRulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ruleId,
        referencedTable: $db.recurringRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringRulesTableFilterComposer(
              $db: $db,
              $table: $db.recurringRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringLogsTable> {
  $$RecurringLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get generatedFor => $composableBuilder(
      column: $table.generatedFor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  $$RecurringRulesTableOrderingComposer get ruleId {
    final $$RecurringRulesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ruleId,
        referencedTable: $db.recurringRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringRulesTableOrderingComposer(
              $db: $db,
              $table: $db.recurringRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringLogsTable> {
  $$RecurringLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get generatedFor => $composableBuilder(
      column: $table.generatedFor, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  $$RecurringRulesTableAnnotationComposer get ruleId {
    final $$RecurringRulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ruleId,
        referencedTable: $db.recurringRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringRulesTableAnnotationComposer(
              $db: $db,
              $table: $db.recurringRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringLogsTable,
    RecurringLog,
    $$RecurringLogsTableFilterComposer,
    $$RecurringLogsTableOrderingComposer,
    $$RecurringLogsTableAnnotationComposer,
    $$RecurringLogsTableCreateCompanionBuilder,
    $$RecurringLogsTableUpdateCompanionBuilder,
    (RecurringLog, $$RecurringLogsTableReferences),
    RecurringLog,
    PrefetchHooks Function({bool ruleId})> {
  $$RecurringLogsTableTableManager(_$AppDatabase db, $RecurringLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ruleId = const Value.absent(),
            Value<String> generatedFor = const Value.absent(),
            Value<String?> transactionId = const Value.absent(),
          }) =>
              RecurringLogsCompanion(
            id: id,
            ruleId: ruleId,
            generatedFor: generatedFor,
            transactionId: transactionId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ruleId,
            required String generatedFor,
            Value<String?> transactionId = const Value.absent(),
          }) =>
              RecurringLogsCompanion.insert(
            id: id,
            ruleId: ruleId,
            generatedFor: generatedFor,
            transactionId: transactionId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ruleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ruleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ruleId,
                    referencedTable:
                        $$RecurringLogsTableReferences._ruleIdTable(db),
                    referencedColumn:
                        $$RecurringLogsTableReferences._ruleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecurringLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringLogsTable,
    RecurringLog,
    $$RecurringLogsTableFilterComposer,
    $$RecurringLogsTableOrderingComposer,
    $$RecurringLogsTableAnnotationComposer,
    $$RecurringLogsTableCreateCompanionBuilder,
    $$RecurringLogsTableUpdateCompanionBuilder,
    (RecurringLog, $$RecurringLogsTableReferences),
    RecurringLog,
    PrefetchHooks Function({bool ruleId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$FinancialTransactionsTableTableManager get financialTransactions =>
      $$FinancialTransactionsTableTableManager(_db, _db.financialTransactions);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$RecurringLogsTableTableManager get recurringLogs =>
      $$RecurringLogsTableTableManager(_db, _db.recurringLogs);
}
