import 'package:flutter/material.dart';
import 'category_list.dart';
import 'category_screen.dart';
import 'entry_list.dart';
import 'chart_screen.dart';
import 'history_screen.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  initializeDateFormatting('ru_RU', null).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Финансовый менеджер',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ru', 'RU'), // Добавьте русский язык
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Финансовый менеджер'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final EntryList _entryList = EntryList();
  final CategoryList _categoryList = CategoryList();

  @override
  void initState() {
    super.initState();
    _entryList.loadEntries();
    _categoryList.loadCategories();
  }

  void _updateState() {
    _entryList.loadEntries();
    _categoryList.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ChartScreen(entries: _entryList, categories: _categoryList),
          CategoryScreen(categoryList: _categoryList),
          HistoryScreen(entryList: _entryList, categoryList: _categoryList),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Категории',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), 
            label: 'История',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _updateState(); // Вызов метода для обновления состояния
          });
        },
      ),
    );
  }
}
