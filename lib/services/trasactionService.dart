import 'package:finance/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => [..._transactions];
  bool get isLoading => _isLoading;

  Future<void> fetchTransactions() async {
    if (_auth.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore
              .collection('transactions')
              .where('userId', isEqualTo: _auth.currentUser!.uid)
              .orderBy('date', descending: true)
              .get();

      _transactions =
          snapshot.docs
              .map((doc) => Transaction.fromMap(doc.data(), doc.id))
              .toList();
    } catch (e) {
      print('Error fetching transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(
    String title,
    double amount,
    TransactionType type,
    String categoryId,
    DateTime date,
    bool isRecurring,
    String? recurringFrequency,
    DateTime? nextDueDate,
  ) async {
    if (_auth.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final docRef = await _firestore.collection('transactions').add({
        'title': title,
        'amount': amount,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'categoryId': categoryId,
        'date': Timestamp.fromDate(date),
        'userId': _auth.currentUser!.uid,
        'isRecurring': isRecurring,
        'recurringFrequency': recurringFrequency,
        'nextDueDate':
            nextDueDate != null ? Timestamp.fromDate(nextDueDate) : null,
      });

      final transaction = Transaction(
        id: docRef.id,
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        date: date,
        userId: _auth.currentUser!.uid,
        isRecurring: isRecurring,
       
        nextDueDate: nextDueDate,
      );

      _transactions.insert(0, transaction);

      if (isRecurring && nextDueDate != null) {
        await NotificationService().scheduleNotification(
          id: docRef.id.hashCode,
          title: 'Payment Reminder',
          body: '$title is due soon',
          scheduledDate: nextDueDate.subtract(Duration(days: 1)),
        );
      }
    } catch (e) {
      print('Error adding transaction: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTransaction(
    String id,
    String title,
    double amount,
    TransactionType type,
    String categoryId,
    DateTime date,
    bool isRecurring,
    String? recurringFrequency,
    DateTime? nextDueDate,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('transactions').doc(id).update({
        'title': title,
        'amount': amount,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'categoryId': categoryId,
        'date': Timestamp.fromDate(date),
        'isRecurring': isRecurring,
        'recurringFrequency': recurringFrequency,
        'nextDueDate':
            nextDueDate != null ? Timestamp.fromDate(nextDueDate) : null,
      });

      final index = _transactions.indexWhere((trans) => trans.id == id);
      if (index != -1) {
        _transactions[index] = Transaction(
          id: id,
          title: title,
          amount: amount,
          type: type,
          categoryId: categoryId,
          date: date,
          userId: _transactions[index].userId,
          isRecurring: isRecurring,
        
          nextDueDate: nextDueDate,
        );
      }

      if (isRecurring && nextDueDate != null) {
        await NotificationService().cancelNotification(id.hashCode);
        await NotificationService().scheduleNotification(
          id: id.hashCode,
          title: 'Payment Reminder',
          body: '$title is due soon',
          scheduledDate: nextDueDate.subtract(Duration(days: 1)),
        );
      } else {
        await NotificationService().cancelNotification(id.hashCode);
      }
    } catch (e) {
      print('Error updating transaction: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('transactions').doc(id).delete();
      _transactions.removeWhere((trans) => trans.id == id);
      await NotificationService().cancelNotification(id.hashCode);
    } catch (e) {
      print('Error deleting transaction: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  double getTotalIncome(DateTime startDate, DateTime endDate) {
    return _transactions
        .where(
          (trans) =>
              trans.type == TransactionType.income &&
              trans.date.isAfter(startDate) &&
              trans.date.isBefore(endDate.add(Duration(days: 1))),
        )
        .fold(0, (sum, trans) => sum + trans.amount);
  }

  double getTotalExpense(DateTime startDate, DateTime endDate) {
    return _transactions
        .where(
          (trans) =>
              trans.type == TransactionType.expense &&
              trans.date.isAfter(startDate) &&
              trans.date.isBefore(endDate.add(Duration(days: 1))),
        )
        .fold(0, (sum, trans) => sum + trans.amount);
  }

  Map<String, double> getCategoryTotals(DateTime startDate, DateTime endDate) {
    final Map<String, double> result = {};

    for (var transaction in _transactions.where(
      (trans) =>
          trans.type == TransactionType.expense &&
          trans.date.isAfter(startDate) &&
          trans.date.isBefore(endDate.add(Duration(days: 1))),
    )) {
      if (result.containsKey(transaction.categoryId)) {
        result[transaction.categoryId] =
            result[transaction.categoryId]! + transaction.amount;
      } else {
        result[transaction.categoryId] = transaction.amount;
      }
    }

    return result;
  }
}
