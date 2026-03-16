import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<AppProvider>(context, listen: false).loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 统计分析'),
      ),
      body: Column(
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('收支')),
              ButtonSegment(value: 1, label: Text('体重')),
              ButtonSegment(value: 2, label: Text('饮食')),
            ],
            selected: {_selectedTab},
            onSelectionChanged: (value) {
              setState(() {
                _selectedTab = value.first;
              });
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: const [
                FinanceStatisticsTab(),
                WeightStatisticsTab(),
                DietStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FinanceStatisticsTab extends StatelessWidget {
  const FinanceStatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final monthlyData = _calculateMonthlyData(provider.transactions);
        final categoryData = _calculateCategoryData(provider.transactions);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMonthlySummaryCard(provider),
            const SizedBox(height: 16),
            if (monthlyData.isNotEmpty)
              _buildMonthlyTrendChart(monthlyData),
            const SizedBox(height: 16),
            if (categoryData.isNotEmpty)
              _buildCategoryPieChart(categoryData),
          ],
        );
      },
    );
  }

  Widget _buildMonthlySummaryCard(AppProvider provider) {
    final now = DateTime.now();
    final monthTransactions = provider.transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();

    final monthIncome = monthTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final monthExpense = monthTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${now.month}月收支汇总',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('收入', monthIncome, Colors.green),
                _buildSummaryItem('支出', monthExpense, Colors.red),
                _buildSummaryItem('结余', monthIncome - monthExpense, Colors.blue),
              ],
            ),
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

  Widget _buildMonthlyTrendChart(Map<String, Map<String, double>> data) {
    final months = data.keys.toList().reversed.take(6).toList();
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (int i = 0; i < months.length; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), data[months[i]]!['income'] ?? 0));
      expenseSpots.add(FlSpot(i.toDouble(), data[months[i]]!['expense'] ?? 0));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '收支趋势',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < months.length) {
                            return Text(months[value.toInt()].substring(5));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('收入', Colors.green),
                const SizedBox(width: 16),
                _buildLegend('支出', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> data) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    final entries = data.entries.toList();
    final total = data.values.fold(0.0, (sum, v) => sum + v);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '支出分类占比',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: List.generate(
                    entries.length,
                    (index) => PieChartSectionData(
                      value: entries[index].value,
                      title: '${(entries[index].value / total * 100).toStringAsFixed(1)}%',
                      color: colors[index % colors.length],
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                entries.length,
                (index) => _buildLegend(
                  '${entries[index].key} ¥${entries[index].value.toStringAsFixed(0)}',
                  colors[index % colors.length],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, double>> _calculateMonthlyData(List transactions) {
    final data = <String, Map<String, double>>{};
    for (final t in transactions) {
      final month = DateFormat('yyyy-MM').format(t.date);
      data.putIfAbsent(month, () => {'income': 0, 'expense': 0});
      if (t.type == 'income') {
        data[month]!['income'] = (data[month]!['income'] ?? 0) + t.amount;
      } else {
        data[month]!['expense'] = (data[month]!['expense'] ?? 0) + t.amount;
      }
    }
    return data;
  }

  Map<String, double> _calculateCategoryData(List transactions) {
    final data = <String, double>{};
    for (final t in transactions.where((t) => t.type == 'expense')) {
      data[t.category] = (data[t.category] ?? 0) + t.amount;
    }
    return data;
  }
}

class WeightStatisticsTab extends StatelessWidget {
  const WeightStatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final records = provider.weightRecords;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBMICard(provider),
            const SizedBox(height: 16),
            _buildWeightGoalCard(provider),
            const SizedBox(height: 16),
            if (records.length >= 2)
              _buildWeightTrendChart(records),
          ],
        );
      },
    );
  }

  Widget _buildBMICard(AppProvider provider) {
    final height = provider.userHeight ?? 170.0;
    final weight = provider.currentWeight;
    final bmi = weight > 0 && height > 0 ? weight / ((height / 100) * (height / 100)) : 0;
    
    String bmiStatus;
    Color bmiColor;
    if (bmi < 18.5) {
      bmiStatus = '偏瘦';
      bmiColor = Colors.blue;
    } else if (bmi < 24) {
      bmiStatus = '正常';
      bmiColor = Colors.green;
    } else if (bmi < 28) {
      bmiStatus = '偏胖';
      bmiColor = Colors.orange;
    } else {
      bmiStatus = '肥胖';
      bmiColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BMI 指数',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _showHeightDialog(context, provider),
                  child: Text('身高: ${height.toStringAsFixed(1)}cm'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    bmi > 0 ? bmi.toStringAsFixed(1) : '--',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(bmiStatus),
                    backgroundColor: bmiColor.withOpacity(0.2),
                    labelStyle: TextStyle(color: bmiColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '健康范围: 18.5 - 23.9',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightGoalCard(AppProvider provider) {
    final goalWeight = provider.goalWeight;
    final currentWeight = provider.currentWeight;
    final progress = goalWeight > 0 && currentWeight > 0
        ? (currentWeight / goalWeight).clamp(0.0, 2.0)
        : 0.0;
    final diff = currentWeight - goalWeight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '体重目标',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _showGoalDialog(context, provider),
                  child: const Text('设置目标'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (goalWeight > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${currentWeight.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text(' / ', style: TextStyle(fontSize: 24)),
                  Text(
                    '${goalWeight.toStringAsFixed(1)} kg',
                    style: TextStyle(fontSize: 24, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress > 1 ? 1 : progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  diff > 0 ? Colors.orange : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                diff > 0 ? '还需减重 ${diff.toStringAsFixed(1)} kg' : '已达标!',
                style: TextStyle(
                  color: diff > 0 ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ] else
              const Center(
                child: Text('点击"设置目标"来设定你的目标体重'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTrendChart(List records) {
    final spots = <FlSpot>[];
    final displayRecords = records.reversed.take(30).toList();
    
    for (int i = 0; i < displayRecords.length; i++) {
      spots.add(FlSpot(i.toDouble(), displayRecords[i].weight));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '体重趋势 (最近30条)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showShownTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHeightDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(
      text: provider.userHeight?.toString() ?? '170',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置身高'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '身高 (cm)',
            hintText: '170',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final height = double.tryParse(controller.text);
              if (height != null && height > 0) {
                provider.setUserHeight(height);
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(
      text: provider.goalWeight > 0 ? provider.goalWeight.toString() : '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置目标体重'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '目标体重 (kg)',
            hintText: '65',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight != null && weight > 0) {
                provider.setGoalWeight(weight);
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class DietStatisticsTab extends StatelessWidget {
  const DietStatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final nutrition = _calculateNutrition(provider.dietRecords);
        final weeklyCalories = _calculateWeeklyCalories(provider.dietRecords);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNutritionCard(nutrition),
            const SizedBox(height: 16),
            _buildNutritionAdvice(nutrition),
            const SizedBox(height: 16),
            if (weeklyCalories.isNotEmpty)
              _buildWeeklyCaloriesChart(weeklyCalories),
          ],
        );
      },
    );
  }

  Widget _buildNutritionCard(Map<String, double> nutrition) {
    final total = nutrition['protein']! + nutrition['carbs']! + nutrition['fat']!;
    final proteinPct = total > 0 ? (nutrition['protein']! / total * 100) : 0;
    final carbsPct = total > 0 ? (nutrition['carbs']! / total * 100) : 0;
    final fatPct = total > 0 ? (nutrition['fat']! / total * 100) : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日营养摄入',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutritionItem('蛋白质', nutrition['protein']!, proteinPct, Colors.red),
                _buildNutritionItem('碳水', nutrition['carbs']!, carbsPct, Colors.orange),
                _buildNutritionItem('脂肪', nutrition['fat']!, fatPct, Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    flex: proteinPct.round(),
                    child: Container(height: 8, color: Colors.red),
                  ),
                  Expanded(
                    flex: carbsPct.round(),
                    child: Container(height: 8, color: Colors.orange),
                  ),
                  Expanded(
                    flex: fatPct.round(),
                    child: Container(height: 8, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('蛋白质 ${proteinPct.toStringAsFixed(0)}%', Colors.red),
                const SizedBox(width: 8),
                _buildLegend('碳水 ${carbsPct.toStringAsFixed(0)}%', Colors.orange),
                const SizedBox(width: 8),
                _buildLegend('脂肪 ${fatPct.toStringAsFixed(0)}%', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, double value, double percentage, Color color) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}g',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildNutritionAdvice(Map<String, double> nutrition) {
    final total = nutrition['protein']! + nutrition['carbs']! + nutrition['fat']!;
    if (total == 0) return const SizedBox.shrink();

    final proteinPct = nutrition['protein']! / total;
    final carbsPct = nutrition['carbs']! / total;
    final fatPct = nutrition['fat']! / total;

    final List<String> advice = [];
    if (proteinPct < 0.15) advice.add('蛋白质摄入偏低，建议增加肉类、蛋类');
    if (proteinPct > 0.35) advice.add('蛋白质摄入偏高，注意肾脏负担');
    if (carbsPct < 0.45) advice.add('碳水化合物偏低，可适当增加主食');
    if (carbsPct > 0.65) advice.add('碳水化合物偏高，注意控制糖分摄入');
    if (fatPct > 0.35) advice.add('脂肪摄入偏高，建议减少油腻食物');
    if (advice.isEmpty) advice.add('营养摄入比例合理，继续保持!');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 饮食建议',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...advice.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(a)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCaloriesChart(Map<String, double> data) {
    final entries = data.entries.toList();
    final spots = <BarChartGroupData>[];

    for (int i = 0; i < entries.length; i++) {
      spots.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entries[i].value,
              color: entries[i].value > 2000 ? Colors.red : Colors.orange,
              width: 20,
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '近7天卡路里摄入',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < entries.length) {
                            return Text(
                              entries[value.toInt()].key.substring(5),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: spots,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '红线: 2000千卡 (建议日摄入量)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateNutrition(List records) {
    final now = DateTime.now();
    final todayRecords = records.where((r) {
      return r.date.year == now.year &&
          r.date.month == now.month &&
          r.date.day == now.day;
    });

    return {
      'protein': todayRecords.fold(0.0, (sum, r) => sum + r.protein),
      'carbs': todayRecords.fold(0.0, (sum, r) => sum + r.carbs),
      'fat': todayRecords.fold(0.0, (sum, r) => sum + r.fat),
    };
  }

  Map<String, double> _calculateWeeklyCalories(List records) {
    final data = <String, double>{};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('MM-dd').format(date);
      final dayRecords = records.where((r) {
        return r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day;
      });
      data[dateStr] = dayRecords.fold(0.0, (sum, r) => sum + r.calories);
    }
    
    return data;
  }
}
