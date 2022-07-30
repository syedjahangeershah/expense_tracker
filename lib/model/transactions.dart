class Transaction {
  String? title;
  String? id;
  double? amount;
  DateTime? dates;

  Transaction({this.title, this.id, this.amount, this.dates});

  toJson() {
    Map<String, dynamic> m = {};
    m['title'] = title;
    m['id'] = id;
    m['amount'] = amount;
    m['dates'] = dates!.toIso8601String();
    return m;
  }
}

class TransactionsList {
  List<Transaction> transactions = [];

  toJson() {
    return transactions.map((transaction) {
      return transaction.toJson();
    }).toList();
  }
}
