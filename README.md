# Transaction Management App

This Flutter application manages transactions using Firestore as a backend. It allows users to add and update transactions, following best practices in state management with `Provider`.

## Features
- Add new transactions
- Update existing transactions
- Firebase Firestore integration
- State management using `Provider`

---

## Setup Instructions

### Prerequisites
Before running the project, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- Android Studio or VS Code (with Flutter plugin)
- Firebase project set up with Firestore enabled

### Clone the Repository
```sh
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### Install Dependencies
```sh
flutter pub get
```

### Configure Firebase
1. Create a Firebase project in [Firebase Console](https://console.firebase.google.com/).
2. Enable Firestore in the Firebase project.
3. Download the `google-services.json` file for Android and place it in `android/app/`.
4. Download the `GoogleService-Info.plist` file for iOS and place it in `ios/Runner/`.
5. Enable Firestore rules for reading/writing as needed.

### Run the Application
```sh
flutter run
```

---

## Project Structure
```
lib/
│── main.dart          # Entry point of the application
│── models/
│   ├── transaction.dart  # Model for transactions
│── providers/
│   ├── transaction_provider.dart  # State management for transactions
│── screens/
│   ├── home_screen.dart  # Main screen
│   ├── transaction_form.dart  # Form to add/update transactions
│── widgets/
│   ├── transaction_card.dart  # UI component for displaying transactions
```

---

## Provider Implementation

### Transaction Model (`models/transaction.dart`)
```dart
class Transaction {
  final String id;
  final String title;
  final double amount;

  Transaction({required this.id, required this.title, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
    };
  }
}
```

### Transaction Provider (`providers/transaction_provider.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTransaction(Transaction transaction) async {
    await _firestore.collection('transactions').add(transaction.toMap());
    notifyListeners();
  }

  Future<void> updateTransaction(String transactionId, Transaction transaction) async {
    await _firestore.collection('transactions').doc(transactionId).update(transaction.toMap());
    notifyListeners();
  }
}
```

### Usage in Widget
```dart
final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

try {
  if (widget.transaction == null) {
    await transactionProvider.addTransaction(transaction);
  } else {
    await transactionProvider.updateTransaction(widget.transaction.id, transaction);
  }
} catch (e) {
  print('Transaction error: $e');
}
```

---

## Deployment
To generate an APK:
```sh
flutter build apk
```

To run on the web:
```sh
flutter build web
```

---

## License
This project is licensed under the MIT License. Feel free to use and modify it.

