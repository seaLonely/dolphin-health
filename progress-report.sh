#!/bin/bash
# 🔔 Dolphin Health 开发进度汇报脚本
# 每20分钟执行一次

PROJECT_DIR="/root/.openclaw/workspace/rice/ocean/projects/dolphin-health"
LOG_FILE="$PROJECT_DIR/logs/night-dev-20260316.log"
REPORT_FILE="$PROJECT_DIR/logs/progress-report.txt"

# 获取当前时间
TIME=$(date "+%H:%M")

# 检查进程状态
if pgrep -f "claude" > /dev/null; then
    STATUS="🟢 开发中"
else
    STATUS="🔴 已停止"
fi

# 统计代码文件
FILE_COUNT=$(find "$PROJECT_DIR/lib" -name "*.dart" 2>/dev/null | wc -l)
LINE_COUNT=$(find "$PROJECT_DIR/lib" -name "*.dart" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')

# 检查关键文件
CHECKLIST=""
[ -f "$PROJECT_DIR/lib/main.dart" ] && CHECKLIST="${CHECKLIST}✅ main.dart\n"
[ -f "$PROJECT_DIR/lib/models/database.dart" ] && CHECKLIST="${CHECKLIST}✅ 数据库\n"
[ -f "$PROJECT_DIR/lib/screens/home_screen.dart" ] && CHECKLIST="${CHECKLIST}✅ 首页\n"
[ -f "$PROJECT_DIR/lib/screens/finance_screen.dart" ] && CHECKLIST="${CHECKLIST}✅ 收支模块\n"
[ -f "$PROJECT_DIR/lib/screens/weight_screen.dart" ] && CHECKLIST="${CHECKLIST}✅ 体重模块\n"
[ -f "$PROJECT_DIR/lib/screens/diet_screen.dart" ] && CHECKLIST="${CHECKLIST}✅ 饮食模块\n"
[ -f "$PROJECT_DIR/pubspec.yaml" ] && CHECKLIST="${CHECKLIST}✅ 配置\n"

# 生成报告
REPORT="🐬 Dolphin Health 开发进度汇报

⏰ 时间: $TIME
📊 状态: $STATUS
📁 文件数: $FILE_COUNT 个 Dart 文件
📝 代码行: $LINE_COUNT 行

📋 完成清单:
$CHECKLIST

🌊 项目位置: $PROJECT_DIR
📝 日志文件: $LOG_FILE

💪 继续加油！明早见成果～"

# 保存报告
echo -e "$REPORT" > "$REPORT_FILE"

# 发送报告（通过 OpenClaw）
echo -e "$REPORT"
