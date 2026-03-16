import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AppProvider>(context, listen: false).loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收支记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildSummaryCard(provider),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = provider.transactions[index];
                    return _buildTransactionItem(transaction);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(AppProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('收入', provider.totalIncome, Colors.green),
            _buildSummaryItem('支出', provider.totalExpense, Colors.red),
            _buildSummaryItem('结余', provider.balance, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == 'income';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green : Colors.red,
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: Colors.white,
        ),
      ),
      title: Text(transaction.title),
      subtitle: Text('${transaction.category} · ${transaction.date.toString().split(' ')[0]}'),
      trailing: Text(
        '${isIncome ? '+' : '-'}¥${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'expense';
  String _category = '餐饮';

  final List<String> _categories = ['餐饮', '交通', '购物', '娱乐', '工资', '其他'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('记一笔'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('支出')),
                ButtonSegment(value: 'income', label: Text('收入')),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() {
                  _type = value.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '例如：午餐、工资',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '金额',
                hintText: '0.00',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: '分类'),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text;
            final amount = double.tryParse(_amountController.text) ?? 0;
            
            if (title.isNotEmpty && amount > 0) {
              final transaction = Transaction(
                title: title,
                amount: amount,
                type: _type,
                category: _category,
                date: DateTime.now(),
              );
              
              Provider.of<AppProvider>(context, listen: false)
                  .addTransaction(transaction);
              
              Navigator.pop(context);
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
