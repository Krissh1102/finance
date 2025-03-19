import 'package:finance/screens/home/categoryScreen.dart';
import 'package:finance/screens/home/dashboardScreen.dart';
import 'package:finance/screens/home/profileScreen.dart';
import 'package:finance/screens/home/transactionScreen.dart';
import 'package:finance/services/categoryService.dart';
import 'package:finance/services/trasactionService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    DashboardScreen(),
    TransactionListScreen(),
    CategoryScreen(),
    ProfileScreen(),
  ];

    @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    await categoryProvider.fetchCategories();
    await transactionProvider.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}