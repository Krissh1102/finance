import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String userId;
  final bool isRecurring;
  final String? notes;
  final String? recurrenceFrequency; // Changed from recurringFrequency to match usage
  final DateTime? nextDueDate;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.userId,
    this.isRecurring = false,
    this.notes, // Changed from required to optional
    this.recurrenceFrequency, // Renamed from recurringFrequency
    this.nextDueDate,
  });

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      title: map['title'],
      amount: map['amount'],
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: map['categoryId'],
      date: (map['date'] as Timestamp).toDate(),
      userId: map['userId'],
      isRecurring: map['isRecurring'] ?? false,
      notes: map['notes'], // Added notes parameter
      recurrenceFrequency: map['recurrenceFrequency'], // Changed from recurringFrequency
      nextDueDate: map['nextDueDate'] != null ? (map['nextDueDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'userId': userId,
      'isRecurring': isRecurring,
      'notes': notes, // Added notes field
      'recurrenceFrequency': recurrenceFrequency, // Changed from recurringFrequency
      'nextDueDate': nextDueDate != null ? Timestamp.fromDate(nextDueDate!) : null,
    };
  }
}