import 'package:flutter/material.dart';

import 'package:localstorage/localstorage.dart';

import './model/transactions.dart';
import './widgets/transaction_list.dart';
import './widgets/add_edit_forum.dart';
import './model/chart.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  // This function generate a material Color picked up from Internet.
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,

        textTheme: ThemeData.light().textTheme.copyWith(
              titleMedium: const TextStyle(
                fontFamily: 'Louis',
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.white,
                // decoration: TextDecoration.underline,
              ),
            ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            fontFamily: 'Louis',
            color: Color.fromARGB(113, 68, 92, 60),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) return Colors.white;
            }),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) return Colors.black;
            }),
          ),
        ),
        // ignore: prefer_const_constructors
        primarySwatch: createMaterialColor(Color(0xff48466D)),
        accentColor: const Color(0xff3D84A8),
      ),
      home: const MyHomePage(title: 'Expense Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TransactionsList list = TransactionsList();
  final LocalStorage storage = LocalStorage('transactions');
  bool initialized = false;

  // This logical function give the list transaction that happened
  // only last week. If there are transaction which are before the last week
  // those will not be included.
  // Then this generated list will be used to display on Weekly Chart.
  List<Transaction> get _recentTransaction {
    return list.transactions
        .where((transaction) => transaction.dates!
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();
  }

  // This logical function sum all the transaction on each day within the last
  // seven days. These values then are shown on the Weekly Chart.
  List<Map<String, Object>> get _groupedTrx {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(
        Duration(days: index),
      );

      double totalSum = 0.0;
      for (int i = 0; i < _recentTransaction.length; i++) {
        if (_recentTransaction[i].dates!.day == weekDay.day &&
            _recentTransaction[i].dates!.month == weekDay.month &&
            _recentTransaction[i].dates!.year == weekDay.year) {
          totalSum += _recentTransaction[i].amount as double;
        }
      }
      return {
        'date': weekDay,
        'amount': totalSum,
      };
    }).reversed.toList();
  }

  // global function to call setState
  void _setState() {
    setState(() {
      _saveToStorage();
    });
  }

  // function to add new transaction to the list and then update the state
  void _addNewTx({String? title, double? amount, DateTime? date}) {
    final newTx = Transaction(
      title: title,
      id: DateTime.now().toString(),
      amount: amount,
      dates: date,
    );
    list.transactions.add(newTx);
    _setState();
  }

  _saveToStorage() => storage.setItem('transactions', list.toJson());

  // builder widgets
  // This widget build the screen based on Portrait mode
  List<Widget> _builPortrait(MediaQueryData mediaQuery, AppBar appBar) {
    return [
      SizedBox(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            .35,
        child: Chart(transactions: _groupedTrx),
      ),
      SizedBox(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            .65,
        child: TransactionList(
          transactions: list.transactions,
          state: _setState,
        ),
      ),
    ];
  }

  // This widget build the screen based on the LandScape mode.
  // when the orientation will ba in landscape, then there
  // will an option to wether show chart or transaction list.
  bool? _showChart = false;
  List<Widget> _buildLandScapeContent(
      MediaQueryData mediaQuery, AppBar appBar) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Show Chart'),
          Switch(
              value: _showChart!,
              onChanged: (val) {
                _showChart = val;
                _setState();
              })
        ],
      ),
      _showChart!
          ? SizedBox(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  .67,
              child: Chart(transactions: _groupedTrx),
            )
          : SizedBox(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  .80,
              child: TransactionList(
                transactions: list.transactions,
                state: _setState,
              ),
            )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandScape = mediaQuery.orientation == Orientation.landscape;
    final appBar = AppBar(
      title: Text(
        'Expense Tracker',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
        future: storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Text(
                'Loading...',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Louis',
                  fontSize: 18,
                ),
              ),
            );
          }
          if (!initialized) {
            var items = storage.getItem('transactions');
            if (items != null) {
              list.transactions = List<Transaction>.from(
                (items as List).map(
                  (transaction) => Transaction(
                    title: transaction['title'],
                    amount: transaction['amount'],
                    id: transaction['id'],
                    dates: DateTime.parse(transaction['dates']),
                  ),
                ),
              );
            } else {
              initialized = true;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                if (isLandScape) ..._buildLandScapeContent(mediaQuery, appBar),
                if (!isLandScape) ..._builPortrait(mediaQuery, appBar),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (_) {
                return AddEdit(
                  action: 0,
                  transactions: list.transactions,
                  state: _addNewTx,
                );
              });
        },
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
