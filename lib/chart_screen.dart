import 'package:finance/category_list.dart';
import 'package:finance/entry_list.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'models.dart';
import 'package:intl/intl.dart';

enum Filter { lastDay, lastWeek, lastMonth, allTime }

class ChartScreen extends StatefulWidget {
  final EntryList entries;
  final CategoryList categories;

  const ChartScreen({super.key, required this.entries, required this.categories});

  @override
  // ignore: library_private_types_in_public_api
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  Filter _selectedFilter = Filter.allTime;

  List<DoughnutSeries<MapEntry<String, double>, String>> _createSeries(List<Entry> entries, bool isIncome, Filter filter) {
    Map<String, double> groupedEntries = _groupEntriesByCategory(entries);

    return [
      DoughnutSeries<MapEntry<String, double>, String>(
        dataSource: groupedEntries.entries.toList(),
        xValueMapper: (MapEntry<String, double> entry, _) => entry.key,
        yValueMapper: (MapEntry<String, double> entry, _) => entry.value,
        pointColorMapper: (MapEntry<String, double> entry, _) {
          Category category = widget.categories.categories.where((category) => category.name == entry.key).toList().first;
          return category.color;
        },
        dataLabelMapper: (MapEntry<String, double> entry, _) => '${entry.key}\n${entry.value}',
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          connectorLineSettings: ConnectorLineSettings(length: '5%', type: ConnectorType.line),
          textStyle: TextStyle(color: Colors.white), // Добавлено для настройки цвета текста подписей
        ),
      ),
    ];
  }



  Map<String, double> _groupEntriesByCategory(List<Entry> entries) {
    Map<String, double> categoryTotals = {};

    for (Entry entry in entries) {
      if (categoryTotals.containsKey(entry.category.name)) {
        categoryTotals[entry.category.name] = categoryTotals[entry.category.name]! + entry.price;
      } else {
        categoryTotals[entry.category.name] = entry.price;
      }
    }

    return categoryTotals;
  }
  
  List<Entry> _filterEntriesByType(bool isIncome, Filter filter) {
    List<Entry> filteredEntries = widget.entries.where((entry) => entry.category.isIncome == isIncome).toList();

    switch (filter) {
      case Filter.lastDay:
        filteredEntries = filteredEntries.where((entry) => entry.date.isAfter(DateTime.now().subtract(Duration(days: 1)))).toList();
        break;
      case Filter.lastWeek:
        filteredEntries = filteredEntries.where((entry) => entry.date.isAfter(DateTime.now().subtract(Duration(days: 7)))).toList();
        break;
      case Filter.lastMonth:
        filteredEntries = filteredEntries.where((entry) => entry.date.isAfter(DateTime.now().subtract(Duration(days: 30)))).toList();
        break;
      case Filter.allTime:
        break;
    }

    return filteredEntries;
  }

  Future<void> _loadData() async {
    await widget.entries.loadEntries();
    await widget.categories.loadCategories();
  }  

  String _getFilterLabel(Filter filter) {
  switch (filter) {
    case Filter.lastDay:
      return 'Last Day';
    case Filter.lastWeek:
      return 'Last Week';
    case Filter.lastMonth:
      return 'Last Month';
    case Filter.allTime:
      return 'All Time';
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Entry> incomeEntries = _filterEntriesByType(true, _selectedFilter);
          List<Entry> expenseEntries = _filterEntriesByType(false, _selectedFilter);

          double totalIncome = incomeEntries.fold(0, (previousValue, entry) => previousValue + entry.price);
          double totalExpense = expenseEntries.fold(0, (previousValue, entry) => previousValue + entry.price);

          double balance = totalIncome - totalExpense;
          String balanceText = '';

          if (balance > 0) {
            balanceText = 'Вы ушли в плюс на ${balance.toStringAsFixed(2)}';
          } else if (balance < 0) {
            balanceText = 'Вы ушли в минус на ${balance.toStringAsFixed(2)}';
          } else {
            balanceText = 'Ваш баланс в ноль';
          }
        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/back.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.0),
                  SegmentedButton<Filter>(
                    segments: <Filter>{
                      Filter.lastDay,
                      Filter.lastWeek,
                      Filter.lastMonth,
                      Filter.allTime,
                    }.map<ButtonSegment<Filter>>((Filter filter) {
                      return ButtonSegment<Filter>(
                        value: filter,
                        label: Text(
                          _getFilterLabel(filter),
                          style: TextStyle(
                            color: _selectedFilter == filter ? Colors.white : Colors.grey,
                            fontSize: 16.0,
                          ),
                        ),
                      );
                    }).toList(),
                    selected: <Filter>{_selectedFilter},
                    onSelectionChanged: (Set<Filter>? newSelection) {
                      if (newSelection != null && newSelection.isNotEmpty) {
                        setState(() {
                          _selectedFilter = newSelection.first;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text('Доходы', style: TextStyle(color: Colors.white, fontSize: 24.0)),
                  SizedBox(height: 16.0),
                  Container(
                    height: 300,
                    color: Colors.black.withOpacity(0.5),
                    child: SfCircularChart(series: _createSeries(incomeEntries, true, _selectedFilter)),
                  ),
                  SizedBox(height: 16.0),
                  Text('Расходы', style: TextStyle(color: Colors.white, fontSize: 24.0)),
                  SizedBox(height: 16.0),
                  Container(
                    height: 300,
                    color: Colors.black.withOpacity(0.5),
                    child: SfCircularChart(series: _createSeries(expenseEntries, false, _selectedFilter)),
                  ),
                  SizedBox(height: 16.0),
                  Text(balanceText, style: TextStyle(color: Colors.white, fontSize: 24.0)), // Добавлено для отображения баланса
                  SizedBox(height: 16.0),
                  Text('Последние записи', style: TextStyle(color: Colors.white, fontSize: 24.0)),
                  SizedBox(height: 16.0),
                  ...widget.entries.reversed.take(5).map((entry) {
                    return Container(
                      color: Colors.black.withOpacity(0.5),
                      child: ListTile(
                        title: Text(entry.category.name, style: TextStyle(color: Colors.white, fontSize: 18.0)),
                        subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a', 'ru_RU').format(entry.date), style: TextStyle(color: Colors.white, fontSize: 16.0)),
                        trailing: Icon(entry.category.isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
                      ),
                    );
                  }),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        );
      }
    });
  }
}