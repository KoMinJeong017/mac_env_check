# MacOS环境检查工具

## 概述
这是一个用于MacOS开发环境的综合检查和分析工具。它采用模块化设计，可以帮助识别配置问题、分析依赖关系，并维护系统健康状况的历史记录。具有良好的可维护性和扩展性。

## 工具结构
```
mac_env_check/
├── check_env_new.sh          # 主脚本
└── modules/
    ├── config.sh            # 配置模块
    ├── logger.sh            # 日志工具
    ├── checks.sh            # 系统检查实现
    ├── reporter.sh          # 报告生成
    └── analyzer.sh          # 分析功能
```

## 主要功能

### 1. 系统检查
- 系统信息验证
- Shell环境分析
- PATH配置验证
- 开发工具检查
- 安全配置审计
- 性能监控

### 2. 包管理
- Homebrew包分析
- Python包依赖检查
- Node.js包审计
- 版本兼容性验证
- 依赖冲突检测

### 3. 配置分析
- Shell配置验证
- 编辑器设置验证
- Git配置检查
- 网络设置审计
- 安全设置验证

### 4. 日志管理
#### 输出目录结构
```
{前缀}_{时间戳}_{后缀}/
├── logs/
│   ├── 01_system_info.log      # 系统信息
│   ├── 02_shell_env.log        # Shell环境
│   ├── 03_path_config.log      # PATH配置
│   ├── 04_homebrew.log         # Homebrew包
│   ├── 05_dev_tools.log        # 开发工具
│   ├── 06_python_env.log       # Python环境
│   ├── 07_node_env.log         # Node.js环境
│   ├── 08_editor_config.log    # 编辑器配置
│   ├── 09_git_config.log       # Git配置
│   ├── 10_disk_space.log       # 磁盘空间
│   ├── 11_network.log          # 网络设置
│   ├── 12_security.log         # 安全检查
│   ├── 13_dependencies.log     # 依赖分析
│   ├── 14_conflicts.log        # 冲突检测
│   ├── 15_performance.log      # 性能指标
│   └── errors.log              # 错误记录
├── analysis/
│   ├── analysis_report.md      # 详细分析
│   ├── statistics.json         # 统计数据
│   └── trends.md              # 历史趋势
├── index.html                 # 交互式报告
└── summary.txt               # 执行摘要
```

### 5. 分析工具
- 错误模式分析
- 警告类别统计
- 配置问题跟踪
- 历史趋势分析
- 组件状态概览
- 性能指标追踪

## 安装说明

1. 设置目录结构：
```bash
# 创建脚本目录
mkdir -p ~/Scripts/env_check

# 克隆代码仓库
git clone https://github.com/yourusername/mac_env_check.git
cd mac_env_check

# 复制文件到脚本目录
cp -r {check_env_new.sh,modules} ~/Scripts/env_check/

# 创建历史记录目录
mkdir -p ~/.env_check_history
```

2. 设置执行权限：
```bash
chmod +x ~/Scripts/env_check/check_env_new.sh
chmod +x ~/Scripts/env_check/modules/*.sh
```

3. 设置定期检查（可选）：
```bash
# 保存定期检查脚本
cat > ~/Scripts/env_check/scheduled_check.sh << 'EOF'
#!/bin/bash
LOG_FILE=~/.env_check_history/scheduled_check.log
echo "开始执行定期检查：$(date)" >> "$LOG_FILE"
cd ~/Scripts/env_check
./check_env_new.sh -k 90
echo "检查完成时间：$(date)" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
EOF

# 设置执行权限
chmod +x ~/Scripts/env_check/scheduled_check.sh

# 添加到 crontab（每月1日早上9点运行）
(crontab -l 2>/dev/null; echo "0 9 1 * * ~/Scripts/env_check/scheduled_check.sh") | crontab -
```

## 使用方法

### 基本用法
```bash
./check_env_new.sh
```

### 高级选项
```bash
选项说明：
  -n, --name PREFIX     设置日志文件前缀
  -s, --suffix SUFFIX   设置日志文件后缀
  -k, --keep DAYS      设置日志保留天数（默认30天）
  -a, --analyze-only   仅分析现有日志，不进行新的检查
  -h, --help           显示帮助信息
```

### 使用示例
1. 自定义命名：
```bash
./check_env_new.sh -n myproject -s prod
# 生成: myproject_20250117_143000_prod/
```

2. 分析现有日志：
```bash
./check_env_new.sh -a
```

3. 设置保留期限：
```bash
./check_env_new.sh -k 60  # 保留60天的日志
```

### 定期检查
您可以设置自动月度检查：
```bash
# 编辑 crontab 修改计划
crontab -e

# 示例条目：
# 每月运行（每月1日早上9点）
0 9 1 * * ~/Scripts/env_check/scheduled_check.sh

# 每周运行（每周一早上9点）
0 9 * * 1 ~/Scripts/env_check/scheduled_check.sh
```

### 历史记录管理
使用包含的工具脚本查看检查历史：
```bash
# 保存历史检查脚本
cat > ~/Scripts/env_check/check_history.sh << 'EOF'
#!/bin/bash
HISTORY_DIR=~/.env_check_history
echo "环境检查历史记录摘要"
echo "--------------------"
echo "最近的检查："
[ -f "$HISTORY_DIR/scheduled_check.log" ] && tail -n 10 "$HISTORY_DIR/scheduled_check.log"
echo -e "\n存档报告："
find "$HISTORY_DIR" -name "mac_env_check_*" -type d -o -name "mac_env_check_*.tar.gz" | \
    sort -r | \
    while read -r file; do
        if [ -d "$file" ]; then
            echo "$(basename "$file") (活动)"
        else
            echo "$(basename "$file") (已归档)"
        fi
    done
echo -e "\n存储使用情况："
du -sh "$HISTORY_DIR"
EOF

# 设置执行权限
chmod +x ~/Scripts/env_check/check_history.sh

# 查看历史
~/Scripts/env_check/check_history.sh
```

## 输出报告

### 1. 交互式HTML报告 (index.html)
- 所有检查结果的可导航界面
- 颜色编码状态指示
- 快速访问详细日志
- 实时摘要仪表板

### 2. 摘要报告 (summary.txt)
- 所有检查的执行摘要
- 关键问题和警告
- 组件状态概览
- 建议采取的措施

### 3. 分析报告
- 全面的markdown分析报告
- JSON格式的统计数据
- 历史趋势分析
- 随时间变化的性能指标

## 日志管理

### 自动日志轮转
- 可配置的保留期限（默认：30天，推荐：90天）
- 自动将旧日志归档到 ~/.env_check_history/
- 压缩存储以提高空间效率
- 通过 cron 任务实现自动月度检查

### 归档管理
- 归档存储在 ~/.env_check_history/
- 使用tar.gz格式压缩
- 建立索引便于检索
- 包含定期检查日志和历史趋势

### 历史追踪
- 维护系统状态随时间的变化
- 追踪错误和警告趋势
- 记录性能指标历史
- 提供组件状态演变

## 故障排除

### 常见问题
1. 权限被拒绝
```bash
chmod +x check_env_new.sh
chmod +x modules/*.sh
```

2. 缺少依赖
```bash
brew install jq  # 需要用于JSON处理
```

3. 模块未找到
```bash
# 确保所有模块文件存在于modules目录
ls -l modules/
```

## 贡献指南
1. Fork 项目仓库
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 开源协议
本项目采用 Apache License 2.0 许可证 - 查看 [LICENSE](LICENSE) 文件了解详细信息。
