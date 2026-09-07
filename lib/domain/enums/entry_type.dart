enum EntryType {
  debit,  // 借方
  credit, // 貸方
}

extension EntryTypeExtension on EntryType {
  String get displayName {
    switch (this) {
      case EntryType.debit:
        return '借方';
      case EntryType.credit:
        return '貸方';
    }
  }
}
