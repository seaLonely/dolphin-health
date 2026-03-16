#!/bin/bash
# 🌙 夜间开发任务 - Dolphin Health APP
# 启动时间: $(date)

PROJECT_DIR="/root/.openclaw/workspace/rice/ocean/projects/dolphin-health"
LOG_FILE="$PROJECT_DIR/logs/night-dev-$(date +%Y%m%d).log"

mkdir -p "$PROJECT_DIR/logs"

echo "🌙 启动夜间开发任务..." | tee -a "$LOG_FILE"
echo "时间: $(date)" | tee -a "$LOG_FILE"
echo "项目: Dolphin Health" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

cd "$PROJECT_DIR"

# 使用 Claude Code 进行开发
claude "请帮我完成这个 Flutter 健康管理 APP。

项目目录: $PROJECT_DIR

功能需求:
1. 💰 收支记录 - 记录每日收入和支出，分类统计
2. ⚖️ 体重记录 - 每日体重录入，趋势图，BMI计算
3. 🍽️ 饮食规划 - 饮食记录，卡路里计算，营养分析

技术要求:
- Flutter 3.x
- SQLite 本地数据库
- Provider 状态管理
- Material Design 3 UI
- 图表展示数据

请完成:
1. 项目结构和基础配置
2. 数据库模型和 CRUD
3. 三个主要功能模块
4. 数据统计和图表
5. 美观的 UI 界面
6. 测试和文档

完成后提交到 Git，并生成 APK。

详细记录开发日志到: $LOG_FILE" >> "$LOG_FILE" 2>&1 &

CLAUDE_PID=$!
echo "✅ Claude Code 已启动 (PID: $CLAUDE_PID)" | tee -a "$LOG_FILE"
echo "📝 日志文件: $LOG_FILE" | tee -a "$LOG_FILE"
echo "⏰ 预计明早完成" | tee -a "$LOG_FILE"
