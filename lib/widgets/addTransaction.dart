import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../services/categoryService.dart';
import '../../services/trasactionService.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function? onTransactionAdded;
  final Transaction? transaction; // Pass this to edit existing transaction

  const AddTransactionScreen({
    Key? key,
    this.onTransactionAdded,
    this.transaction,
  }) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Transaction fields
  TransactionType _transactionType = TransactionType.expense;
  String _title = '';
  double _amount = 0.0;
  DateTime _date = DateTime.now();
  String? _categoryId;
  String _notes = '';
  bool _isRecurring = false;
  String _recurrenceFrequency = 'monthly';

  // Controller for amount input
  final TextEditingController _amountController = TextEditingController();

  // Focus nodes
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // If editing existing transaction, populate fields
    if (widget.transaction != null) {
      _transactionType = widget.transaction!.type;
      _title = widget.transaction!.title;
      _amount = widget.transaction!.amount;
      _amountController.text = _amount.toString();
      _date = widget.transaction!.date;
      _categoryId = widget.transaction!.categoryId;
      _notes = widget.transaction!.notes ?? '';
      _isRecurring = widget.transaction!.isRecurring;
      _recurrenceFrequency =
          widget.transaction!.recurrenceFrequency ?? 'monthly';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleFocus.dispose();
    _amountFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Transaction type toggle
              Row(
                children: [
                  Expanded(
                    child: _buildTypeToggle(
                      title: 'Expense',
                      icon: Icons.arrow_downward,
                      isSelected: _transactionType == TransactionType.expense,
                      onTap: () {
                        setState(() {
                          _transactionType = TransactionType.expense;
                          // Reset category selection when changing transaction type
                          _categoryId = null;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTypeToggle(
                      title: 'Income',
                      icon: Icons.arrow_upward,
                      isSelected: _transactionType == TransactionType.income,
                      onTap: () {
                        setState(() {
                          _transactionType = TransactionType.income;
                          // Reset category selection when changing transaction type
                          _categoryId = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Transaction title
              TextFormField(
                focusNode: _titleFocus,
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value) {
                  _title = value;
                },
                onFieldSubmitted: (_) {
                  _amountFocus.requestFocus();
                },
              ),
              SizedBox(height: 16),

              // Amount
              TextFormField(
                focusNode: _amountFocus,
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  _amount = double.tryParse(value) ?? 0.0;
                },
              ),
              SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _date = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('EEEE, MMMM d, yyyy').format(_date)),
                ),
              ),
              SizedBox(height: 16),

              // Category selector
              categoryProvider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildCategorySelector(categoryProvider),
              SizedBox(height: 16),

              // Notes
              TextFormField(
                focusNode: _notesFocus,
                initialValue: _notes,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.note),
                ),
                onChanged: (value) {
                  _notes = value;
                },
              ),
              SizedBox(height: 16),

              // Recurring transaction
              SwitchListTile(
                title: Text('Recurring Transaction'),
                subtitle: Text(
                  _isRecurring
                      ? 'This transaction will repeat $_recurrenceFrequency'
                      : 'One-time transaction',
                ),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
                secondary: Icon(Icons.repeat),
              ),

              // Recurrence frequency (only shown when recurring is enabled)
              if (_isRecurring) ...[
                SizedBox(height: 8),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Recurrence',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _recurrenceFrequency,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _recurrenceFrequency = newValue;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('Monthly'),
                        ),
                        DropdownMenuItem(
                          value: 'yearly',
                          child: Text('Yearly'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 32),

              // Save button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: transactionProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          // Check if category is selected
                          if (_categoryId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a category'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Create transaction object
                          final transaction = Transaction(
                            id: widget.transaction?.id ??
                                DateTime.now().millisecondsSinceEpoch.toString(),
                            title: _title,
                            amount: _amount,
                            date: _date,
                            type: _transactionType,
                            categoryId: _categoryId!, // Safe to use ! now since we validated it's not null
                            notes: _notes,
                            isRecurring: _isRecurring,
                            recurrenceFrequency:
                                _isRecurring ? _recurrenceFrequency : null,
                            userId: '',
                          );

                          try {
                            // // Save transaction
                            // if (widget.transaction == null) {
                            //   await transactionProvider.addTransaction(transaction.);
                            // } else {
                            //   await transactionProvider.updateTransaction(transaction);
                            // }

                            // Notify parent and close
                            if (widget.onTransactionAdded != null) {
                              widget.onTransactionAdded!();
                            }
                            Navigator.of(context).pop();
                          } catch (e) {
                            // Show error message if saving fails
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error saving transaction: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: transactionProvider.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.transaction == null
                            ? 'Add Transaction'
                            : 'Update Transaction',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (title == 'Expense' ? Colors.red[100] : Colors.green[100])
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (title == 'Expense' ? Colors.red : Colors.green)
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (title == 'Expense' ? Colors.red : Colors.green)
                  : Colors.grey[600],
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? (title == 'Expense' ? Colors.red : Colors.green)
                    : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(CategoryProvider categoryProvider) {
    // Filter categories based on transaction type
    final filteredCategories = categoryProvider.categories
        .where((category) => category.color== _transactionType) // Changed from category.name to category.type
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          height: 120,
          child: filteredCategories.isEmpty
              ? Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final isSelected = category.id == _categoryId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          // Safe handling of potentially null category.id
                          if (category.id != null) {
                            _categoryId = category.id;
                          } else {
                            // Show error if category has no ID
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Invalid category'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category.color.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? category.color
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: category.color,
                              child: Icon(
                                Icons.category,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}