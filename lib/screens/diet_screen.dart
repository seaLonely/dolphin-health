import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/diet_record.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AppProvider>(context, listen: false).loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('饮食记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDietDialog(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildTodayCaloriesCard(provider),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.dietRecords.length,
                  itemBuilder: (context, index) {
                    final record = provider.dietRecords[index];
                    return _buildDietItem(record);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodayCaloriesCard(AppProvider provider) {
    final todayCalories = provider.todayCalories;
    final goalCalories = 2000.0;
    final progress = todayCalories / goalCalories;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '今日摄入',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${todayCalories.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const Text(
              '千卡',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0, 1),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                progress > 1 ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '目标: ${goalCalories.toStringAsFixed(0)} 千卡',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietItem(DietRecord record) {
    final mealTypeIcons = {
      '早餐': Icons.breakfast_dining,
      '午餐': Icons.lunch_dining,
      '晚餐': Icons.dinner_dining,
      '加餐': Icons.cookie,
    };
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange,
        child: Icon(
          mealTypeIcons[record.mealType] ?? Icons.restaurant,
          color: Colors.white,
        ),
      ),
      title: Text(record.foodName),
      subtitle: Text('${record.mealType ?? '其他'} · ${record.calories.toStringAsFixed(0)} 千卡'),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '蛋白质: ${record.protein.toStringAsFixed(1)}g',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '碳水: ${record.carbs.toStringAsFixed(1)}g',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '脂肪: ${record.fat.toStringAsFixed(1)}g',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showAddDietDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddDietDialog(),
    );
  }
}

class AddDietDialog extends StatefulWidget {
  const AddDietDialog({super.key});

  @override
  State<AddDietDialog> createState() => _AddDietDialogState();
}

class _AddDietDialogState extends State<AddDietDialog> {
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  String _mealType = '午餐';

  final List<String> _mealTypes = ['早餐', '午餐', '晚餐', '加餐'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('记录饮食'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _mealType,
              decoration: const InputDecoration(labelText: '餐次'),
              items: _mealTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _mealType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: '食物名称',
                hintText: '例如：米饭、鸡胸肉',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: '卡路里 (千卡)',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: '蛋白质 (g)',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: '碳水 (g)',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fatController,
                    decoration: const InputDecoration(
                      labelText: '脂肪 (g)',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
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
            final foodName = _foodNameController.text;
            final calories = double.tryParse(_caloriesController.text) ?? 0;
            final protein = double.tryParse(_proteinController.text) ?? 0;
            final carbs = double.tryParse(_carbsController.text) ?? 0;
            final fat = double.tryParse(_fatController.text) ?? 0;
            
            if (foodName.isNotEmpty && calories > 0) {
              final record = DietRecord(
                foodName: foodName,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                date: DateTime.now(),
                mealType: _mealType,
              );
              
              Provider.of<AppProvider>(context, listen: false)
                  .addDietRecord(record);
              
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
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }
}
