enum AccountGroup {
  asset,      // 資産
  liability,  // 負債
  equity,     // 純資産
  expense,    // 費用
  revenue,    // 収益
}

extension AccountGroupExtension on AccountGroup {
  String get displayName {
    switch (this) {
      case AccountGroup.asset:
        return '資産';
      case AccountGroup.liability:
        return '負債';
      case AccountGroup.equity:
        return '純資産';
      case AccountGroup.expense:
        return '費用';
      case AccountGroup.revenue:
        return '収益';
    }
  }

  /// B/S (貸借対照表) に属するか
  bool get isBalanceSheet =>
      this == AccountGroup.asset ||
      this == AccountGroup.liability ||
      this == AccountGroup.equity;

  /// P/L (損益計算書) に属するか
  bool get isProfitAndLoss =>
      this == AccountGroup.expense || this == AccountGroup.revenue;

  /// 借方 (Debit) が増加方向か
  bool get normallyDebit =>
      this == AccountGroup.asset || this == AccountGroup.expense;
}
