import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/transactions.dart';
import 'add_edit_forum.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    Key? key,
    required this.deleteTrx,
    @required this.transaction,
    this.state,
  }) : super(key: key);

  final Function deleteTrx;
  final Transaction? transaction;
  final Function? state;

  void _showBottomSheet(
      BuildContext context, int? edit, Transaction? transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return AddEdit(
          action: edit,
          transaction: transaction,
          state: state,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(
                NumberFormat.decimalPattern().format(transaction?.amount),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          transaction?.title as String,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 19,
          ),
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(transaction?.dates as DateTime).toString(),
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontFamily: 'Louis',
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _showBottomSheet(context, 1, transaction),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(
                          'Deleting item!',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontFamily: 'Louis',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete item?',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontFamily: 'Louis',
                            fontSize: 17,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'No'),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteTrx(transaction);
                              Navigator.pop(context, 'Yes');
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        fontFamily: 'Louis',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
