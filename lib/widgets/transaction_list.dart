import 'package:flutter/material.dart';

import '../model/transactions.dart';
import './trasnaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction>? transactions;
  final Function? state;

  const TransactionList({Key? key, this.transactions, this.state})
      : super(key: key);

  // delete the transaction item
  void _deleteTrx(Transaction tx) {
    transactions?.removeWhere((element) => element.id == tx.id);
    state!();
  }

  @override
  Widget build(BuildContext context) {
    final int length = transactions!.length;
    return length == 0
        ? const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Text(
                'There is not any transaction.',
                style: TextStyle(
                  fontFamily: 'Louis',
                  fontSize: 30,
                ),
              ),
            ),
          )
        : ListView.builder(
            itemCount: transactions?.length,
            itemBuilder: (ctx, index) {
              return TransactionItem(
                transaction: transactions![index],
                deleteTrx: _deleteTrx,
                state: state,
              );
            },
          );
  }
}
