# MacOS环境检查工具

## 概述
这是一个用于MacOS开发环境的综合检查和分析工具。它采用模块化设计，可以帮助识别配置问题、分析依赖关系，并维护系统健康状况的历史记录。具有良好的可维护性和扩展性。

## 目录结构

### 安装布局
```
~/Scripts/env_check/                 # 安装目录
├── check_env_new.sh                # 主环境检查脚本
├── check_history.sh                # 历史记录管理工具
├── scheduled_check.sh              # 自动检查调度器
└── modules/                        # 核心模块
    ├── config.sh                   # 配置设置
    ├── language.sh                 # 语言本地化
    ├── logger.sh                   # 日志工具
    ├── checks.sh                   # 系统检查实现
    ├── reporter.sh                 # 报告生成
    └── analyzer.sh                 # 分析功能
```

### 历史存储
```
~/.env_check_history/               # 历史存储
├── scheduled_check.log             # 定期检查日志
├── active_checks/                  # 最近检查结果
│   └── mac_env_check_YYYYMMDD/    # 检查结果目录
└── archives/                       # 压缩的旧结果
    └── mac_env_check_YYYYMMDD.tar.gz
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
#### 检查输出结构
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

1. 创建目录：
```bash
# 创建脚本目录
mkdir -p ~/Scripts/env_check

# 创建历史记录和配置目录
mkdir -p ~/.env_check_history/{active_checks,archives}
mkdir -p ~/.env_check_config
```

2. 克隆和复制文件：
```bash
# 克隆仓库
git clone https://github.com/yourusername/mac_env_check.git
cd mac_env_check

# 复制所有文件到脚本目录
cp -r {check_env_new.sh,check_history.sh,scheduled_check.sh,modules} ~/Scripts/env_check/
```

3. 设置权限：
```bash
chmod +x ~/Scripts/env_check/*.sh
chmod +x ~/Scripts/env_check/modules/*.sh
```

4. 安装依赖：
```bash
brew install jq  # 需要用于JSON处理
```

## 语言设置

工具支持多语言输出，您可以使用以下命令切换语言：

```bash
# 初始化语言模块
source ~/Scripts/env_check/modules/language.sh

# 切换到中文
set_language zh

# 切换到英文
set_language en
```

语言设置会影响：
- 所有检查过程的输出
- 生成的报告内容
- 错误和警告信息
- HTML报告界面

语言偏好存储在 ~/.env_check_config/language 文件中，在会话之间保持不变。

## 使用方法

### 基本操作
```bash
# 运行环境检查
cd ~/Scripts/env_check
./check_env_new.sh

# 查看检查历史
./check_history.sh

# 仅运行分析
./check_env_new.sh -a
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

### 自动检查

#### 设置定期检查
```bash
# 编辑 crontab
crontab -e

# 每月检查（每月1日早上9点）
0 9 1 * * ~/Scripts/env_check/scheduled_check.sh

# 每周检查（每周一早上9点）
0 9 * * 1 ~/Scripts/env_check/scheduled_check.sh
```

#### 管理定期检查
```bash
# 查看当前计划
crontab -l

# 删除定期检查
crontab -l | grep -v "scheduled_check.sh" | crontab -
```

### 历史记录管理

#### 查看历史
```bash
# 查看历史摘要
./check_history.sh

# 查看特定检查结果
ls -l ~/.env_check_history/active_checks/

# 查看已归档的检查
ls -l ~/.env_check_history/archives/
```

#### 管理历史记录
```bash
# 清理旧归档（超过指定天数）
find ~/.env_check_history/archives -name "*.tar.gz" -mtime +90 -delete

# 手动归档检查结果
tar czf ~/.env_check_history/archives/check_result.tar.gz \
    ~/.env_check_history/active_checks/check_result/
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
- 可配置的保留期限（默认：30天）
- 自动归档旧日志
- 压缩存储以提高空间效率

### 归档管理
- 归档存储在 ~/.env_check_history/archives/
- 使用tar.gz格式压缩
- 建立索引便于检索

### 历史追踪
- 维护系统状态随时间的变化
- 追踪错误和警告趋势
- 记录性能指标历史
- 提供组件状态演变

## 故障排除

### 常见问题
1. 权限被拒绝
```bash
chmod +x ~/Scripts/env_check/*.sh
chmod +x ~/Scripts/env_check/modules/*.sh
```

2. 缺少依赖
```bash
brew install jq  # 需要用于JSON处理
```

3. 模块未找到
```bash
# 验证模块目录结构
ls -l ~/Scripts/env_check/modules/
```

4. 历史记录访问问题
```bash
# 检查历史目录权限
ls -la ~/.env_check_history/
# 修复权限（如果需要）
chmod -R 755 ~/.env_check_history/
```

5. 定期检查问题
```bash
# 检查 crontab 条目
crontab -l
# 验证脚本权限
ls -l ~/Scripts/env_check/scheduled_check.sh
# 检查定期检查日志
tail ~/.env_check_history/scheduled_check.log
```

## 贡献指南
1. Fork 项目仓库
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 开源协议
本项目采用 Apache License 2.0 许可证 - 查看 [LICENSE](LICENSE) 文件了解详细信息。
