import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/weight_record.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AppProvider>(context, listen: false).loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('体重记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWeightDialog(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildCurrentWeightCard(provider),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.weightRecords.length,
                  itemBuilder: (context, index) {
                    final record = provider.weightRecords[index];
                    return _buildWeightItem(record, index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentWeightCard(AppProvider provider) {
    final currentWeight = provider.currentWeight;
    final previousWeight = provider.weightRecords.length > 1 
        ? provider.weightRecords[1].weight 
        : currentWeight;
    final change = currentWeight - previousWeight;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '当前体重',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${currentWeight.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Text(
              'kg',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (change != 0)
              Text(
                '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: change > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightItem(WeightRecord record, int index) {
    return Dismissible(
      key: Key('weight_${record.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        Provider.of<AppProvider>(context, listen: false)
            .deleteWeightRecord(record.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录已删除')),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.scale, color: Colors.white),
        ),
        title: Text('${record.weight.toStringAsFixed(1)} kg'),
        subtitle: Text(record.date.toString().split(' ')[0]),
        trailing: index == 0 
            ? const Chip(
                label: Text('最新'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddWeightDialog(),
    );
  }
}

class AddWeightDialog extends StatefulWidget {
  const AddWeightDialog({super.key});

  @override
  State<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<AddWeightDialog> {
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('记录体重'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: '体重 (kg)',
              hintText: '65.5',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: '备注',
              hintText: '例如：早晨空腹',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final weight = double.tryParse(_weightController.text) ?? 0;
            
            if (weight > 0) {
              final record = WeightRecord(
                weight: weight,
                date: DateTime.now(),
                note: _noteController.text.isEmpty ? null : _noteController.text,
              );
              
              Provider.of<AppProvider>(context, listen: false)
                  .addWeightRecord(record);
              
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
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
