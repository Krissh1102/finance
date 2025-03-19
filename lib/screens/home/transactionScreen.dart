import 'package:finance/services/categoryService.dart';
import 'package:finance/services/trasactionService.dart';
import 'package:finance/widgets/addTransaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  TransactionType _filterType = TransactionType.expense;
  String? _filterCategoryId;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  bool _isFiltered = false;

  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  @override
  void initState() {
    super.initState();
    // Default filter for current month
    _filterStartDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _filterEndDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final filteredTransactions =
        transactionProvider.transactions.where((transaction) {
          // Filter by type
          if (_filterType != null && transaction.type != _filterType) {
            return false;
          }

          // Filter by category
          if (_filterCategoryId != null &&
              transaction.categoryId != _filterCategoryId) {
            return false;
          }

          // Filter by date range
          if (_filterStartDate != null &&
              transaction.date.isBefore(_filterStartDate!)) {
            return false;
          }

          if (_filterEndDate != null &&
              transaction.date.isAfter(
                _filterEndDate!.add(Duration(days: 1)),
              )) {
            return false;
          }

          return true;
        }).toList();

    // Calculate total income and expenses
    double totalAmount = 0;
    for (var transaction in filteredTransactions) {
      if (transaction.type == TransactionType.income) {
        totalAmount += transaction.amount;
      } else {
        totalAmount -= transaction.amount;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, categoryProvider),
          ),
        ],
      ),
      body:
          transactionProvider.isLoading || categoryProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Summary card
                  Card(
                    margin: EdgeInsets.all(16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Balance',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              _isFiltered
                                  ? Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Filtered',
                                      style: TextStyle(
                                        color: Colors.blue[800],
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            currencyFormat.format(totalAmount),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color:
                                  totalAmount >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            DateFormat('MMMM yyyy').format(_filterStartDate!),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Transaction list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await transactionProvider.fetchTransactions();
                      },
                      child:
                          filteredTransactions.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No transactions found',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed:
                                          () => _showAddTransactionBottomSheet(
                                            context,
                                          ),
                                      child: Text('Add your first transaction'),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  final transaction =
                                      filteredTransactions[index];
                                  

                                  // Group transactions by date
                                  final bool isFirstOfDay =
                                      index == 0 ||
                                      !DateUtils.isSameDay(
                                        transaction.date,
                                        filteredTransactions[index - 1].date,
                                      );

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isFirstOfDay) ...[
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: index == 0 ? 0 : 24,
                                            bottom: 8,
                                            left: 8,
                                          ),
                                          child: Text(
                                            DateFormat(
                                              'EEEE, MMMM d',
                                            ).format(transaction.date),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                        Divider(),
                                      ],
                                      Card(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                Colors.grey,
                                            child: Icon(
                                              transaction.type ==
                                                      TransactionType.income
                                                  ? Icons.arrow_upward
                                                  : Icons.arrow_downward,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text(
                                            transaction.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 4),
                                              Text(
                                               
                                                    'Unknown category',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              if (transaction.isRecurring)
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.repeat,
                                                      size: 14,
                                                      color: Colors.blue[700],
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Recurring',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blue[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          trailing: Text(
                                            currencyFormat.format(
                                              transaction.amount,
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  transaction.type ==
                                                          TransactionType.income
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                            ),
                                          ),
                                          onTap: () {
                                            // Navigate to transaction detail
                                          },
                                          onLongPress: () {
                                            _showTransactionActions(
                                              context,
                                              transaction,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _showAddTransactionBottomSheet(context),
      ),
    );
  }

  void _showAddTransactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: AddTransactionScreen(
              onTransactionAdded: () {
                // Refresh the list or handle the transaction added
                setState(() {});
              },
            ),
          ),
    );
  }

  void _showTransactionActions(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Transaction'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to edit transaction
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Delete Transaction',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteTransaction(context, transaction);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _confirmDeleteTransaction(
    BuildContext context,
    Transaction transaction,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Transaction'),
            content: Text('Are you sure you want to delete this transaction?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  // Delete the transaction
                  Navigator.pop(context);
                },
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    CategoryProvider categoryProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Transactions'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Type:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Radio<TransactionType>(
                          value: TransactionType.expense,
                          groupValue: _filterType,
                          onChanged: (value) {
                            setState(() {
                              _filterType = value!;
                            });
                          },
                        ),
                        Text('Expenses'),
                        Radio<TransactionType>(
                          value: TransactionType.income,
                          groupValue: _filterType,
                          onChanged: (value) {
                            setState(() {
                              _filterType = value!;
                            });
                          },
                        ),
                        Text('Income'),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Category:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String?>(
                      isExpanded: true,
                      value: _filterCategoryId,
                      hint: Text('All Categories'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _filterCategoryId = newValue;
                        });
                      },
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...categoryProvider.categories.map((category) {
                          return DropdownMenuItem<String?>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Presets:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip(setState, 'This Month', () {
                          final now = DateTime.now();
                          _filterStartDate = DateTime(now.year, now.month, 1);
                          _filterEndDate = DateTime(now.year, now.month + 1, 0);
                        }),
                        _buildFilterChip(setState, 'Last Month', () {
                          final now = DateTime.now();
                          _filterStartDate = DateTime(
                            now.year,
                            now.month - 1,
                            1,
                          );
                          _filterEndDate = DateTime(now.year, now.month, 0);
                        }),
                        _buildFilterChip(setState, 'Last 3 Months', () {
                          final now = DateTime.now();
                          _filterStartDate = DateTime(
                            now.year,
                            now.month - 3,
                            1,
                          );
                          _filterEndDate = DateTime(now.year, now.month + 1, 0);
                        }),
                        _buildFilterChip(setState, 'This Year', () {
                          final now = DateTime.now();
                          _filterStartDate = DateTime(now.year, 1, 1);
                          _filterEndDate = DateTime(now.year, 12, 31);
                        }),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Custom Date Range:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _filterStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _filterStartDate = picked;
                                });
                              }
                            },
                            child: Text(
                              _filterStartDate == null
                                  ? 'Start Date'
                                  : DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_filterStartDate!),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _filterEndDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _filterEndDate = picked;
                                });
                              }
                            },
                            child: Text(
                              _filterEndDate == null
                                  ? 'End Date'
                                  : DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_filterEndDate!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filterType = TransactionType.expense;
                      _filterCategoryId = null;
                      _filterStartDate = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        1,
                      );
                      _filterEndDate = DateTime(
                        DateTime.now().year,
                        DateTime.now().month + 1,
                        0,
                      );
                    });
                  },
                  child: Text('Reset'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      _isFiltered =
                          _filterCategoryId != null ||
                          _filterType != TransactionType.expense ||
                          _filterStartDate!.month != DateTime.now().month;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(
    StateSetter setState,
    String label,
    VoidCallback onPressed,
  ) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.grey[200],
      onPressed: () {
        setState(() {
          onPressed();
        });
      },
    );
  }
}
