import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/weight_record.dart';
import '../models/diet_record.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Transaction> _transactions = [];
  List<WeightRecord> _weightRecords = [];
  List<DietRecord> _dietRecords = [];
  double? _userHeight;
  double _goalWeight = 0;

  List<Transaction> get transactions => _transactions;
  List<WeightRecord> get weightRecords => _weightRecords;
  List<DietRecord> get dietRecords => _dietRecords;
  double? get userHeight => _userHeight;
  double get goalWeight => _goalWeight;

  Future<void> loadData() async {
    _transactions = await _db.getTransactions();
    _weightRecords = await _db.getWeightRecords();
    _dietRecords = await _db.getDietRecords();
    _userHeight = await _db.getUserHeight();
    _goalWeight = await _db.getGoalWeight();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _db.insertTransaction(transaction);
    await loadData();
  }

  Future<void> addWeightRecord(WeightRecord record) async {
    await _db.insertWeightRecord(record);
    await loadData();
  }

  Future<void> addDietRecord(DietRecord record) async {
    await _db.insertDietRecord(record);
    await loadData();
  }

  // Delete methods
  Future<void> deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    await loadData();
  }

  Future<void> deleteWeightRecord(int id) async {
    await _db.deleteWeightRecord(id);
    await loadData();
  }

  Future<void> deleteDietRecord(int id) async {
    await _db.deleteDietRecord(id);
    await loadData();
  }

  // Update methods
  Future<void> updateTransaction(Transaction transaction) async {
    await _db.updateTransaction(transaction);
    await loadData();
  }

  Future<void> updateWeightRecord(WeightRecord record) async {
    await _db.updateWeightRecord(record);
    await loadData();
  }

  Future<void> updateDietRecord(DietRecord record) async {
    await _db.updateDietRecord(record);
    await loadData();
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;

  double get currentWeight {
    return _weightRecords.isNotEmpty ? _weightRecords.first.weight : 0;
  }

  double get todayCalories {
    final today = DateTime.now();
    return _dietRecords
        .where((d) => 
          d.date.year == today.year &&
          d.date.month == today.month &&
          d.date.day == today.day)
        .fold(0, (sum, d) => sum + d.calories);
  }

  Future<void> setUserHeight(double height) async {
    await _db.setUserHeight(height);
    _userHeight = height;
    notifyListeners();
  }

  Future<void> setGoalWeight(double weight) async {
    await _db.setGoalWeight(weight);
    _goalWeight = weight;
    notifyListeners();
  }
}
