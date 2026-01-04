import 'package:meta/meta.dart';

@immutable
class Transaction {
  const Transaction({
    required this.amount,
    required this.currency,
    this.note,
    DateTime? occurredAt,
  }) : occurredAt = occurredAt ?? DateTime.now();

  final double amount;
  final String currency;
  final String? note;
  final DateTime occurredAt;
}

@immutable
class Summary {
  const Summary({required this.balance, required this.totalCount});

  final double balance;
  final int totalCount;
}

abstract class LedgerService {
  void init();
  void addTransaction(Transaction transaction);
  Summary querySummary();
}

class InMemoryLedgerService implements LedgerService {
  final List<Transaction> _transactions = [];

  @override
  void init() {
    _transactions.clear();
  }

  @override
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
  }

  @override
  Summary querySummary() {
    final balance =
        _transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
    return Summary(balance: balance, totalCount: _transactions.length);
  }
}
