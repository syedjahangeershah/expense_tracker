import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/transactions.dart';

class AddEdit extends StatefulWidget {
  final int? action;
  Transaction? transaction;
  List<Transaction>? transactions;
  Function? state;

  AddEdit({
    Key? key,
    @required this.action,
    this.transaction,
    this.state,
    this.transactions,
  }) : super(key: key);

  @override
  State<AddEdit> createState() => _AddEditState();
}

class _AddEditState extends State<AddEdit> {
  @override
  void initState() {
    // Reason for calling the 'initState()' function is that if the existing data is being update
    // then the input field should have the old fields when the Bottom Model Sheet is opened.
    title?.text = widget.action == 1 ? widget.transaction?.title as String : '';
    amount?.text = widget.action == 1
        ? widget.transaction?.amount.toString() as String
        : '';
    _pickedDate = widget.action == 1 ? widget.transaction?.dates : null;
    super.initState();
  }

  // These variable control the input given by user
  TextEditingController? title = TextEditingController();
  TextEditingController? amount = TextEditingController();

  DateTime? _pickedDate;

  // Date Picker CallBack Function
  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _pickedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate == null) return;
      setState(() {
        _pickedDate = selectedDate;
      });
    });
  }

  //This function submit the data:
  // 1: if the existing data is being update OR
  // 2: if the newly data is being update
  void _dataSubmit() {
    if (widget.transaction != null) {
      // This 'if' condition is used if the existing data is being update
      widget.transaction?.title = title?.text;
      widget.transaction?.amount = double.parse(amount?.text as String);
      widget.transaction?.dates = _pickedDate;
      widget.state!();
    } else {
      // This 'else' condition is used if the data is new

      // New data should be complete (transaction title, transaction amount and date is required).
      if (amount?.text == null) return;
      if (title?.text == null ||
          double.parse(amount?.text as String) <= 0 ||
          _pickedDate == null) return;
      widget.state!(
        title: title!.text,
        amount: double.parse(amount!.text),
        date: _pickedDate,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 6,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter transaction Name and Price:',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Louis',
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: title,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Louis',
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
                decoration: const InputDecoration(
                  labelText: 'Transaction name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: amount,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Louis',
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
                decoration: const InputDecoration(
                  labelText: 'Transaction price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                    child: _pickedDate != null
                        ? Text(
                            'Chosen date: ${DateFormat.yMMMEd().format(_pickedDate as DateTime)}',
                          )
                        : const Text('No date choosen'),
                  ),
                  TextButton.icon(
                    onPressed: _showDatePicker,
                    style: TextButton.styleFrom(
                      primary: Theme.of(context).accentColor,
                    ),
                    icon: const Icon(Icons.access_time),
                    label: const Text(
                      'Choose date',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _dataSubmit,
                    child: const Text('Add transaction'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
