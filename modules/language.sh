# Copyright 2025 Ko Minjeong
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#########################################################################
# File Name:    language.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Sat 18 Jan 08:25:55 2025
#########################################################################
#!/bin/bash

# Default language setting
LANG_FILE="$HOME/.env_check_config/language"
DEFAULT_LANG="zh"

# Create config directory if not exists
mkdir -p "$HOME/.env_check_config"

# Initialize or load language setting
init_language() {
    if [ ! -f "$LANG_FILE" ]; then
        echo "$DEFAULT_LANG" > "$LANG_FILE"
    fi
    CURRENT_LANG=$(cat "$LANG_FILE")
}

# Get localized message
get_message() {
    local key="$1"
    init_language

    case "$CURRENT_LANG" in
        "zh")
            case "$key" in
                # New messages
                "ANALYZING_LOGS")
                    echo "正在分析现有日志..."
                    ;;
                "ANALYSIS_COMPLETED")
                    echo "分析完成！"
                    ;;
                "ENV_CHECK_COMPLETED")
                    echo "环境检查完成！"
                    ;;
                "RESULTS_AVAILABLE")
                    echo "结果保存在"
                    ;;
                "VIEW_REPORT")
                    echo "查看报告请打开"
                    ;;
                "WARNING_CHECKS_FAILED")
                    echo "警告："
                    ;;
                "CHECKS_FAILED_DETAILS")
                    echo "项检查失败。请查看日志了解详情。"
                    ;;
                
                # System messages
                "ENV_CHECK_SUMMARY")
                    echo "环境检查历史记录摘要"
                    ;;
                "RECENT_CHECKS")
                    echo "最近的检查"
                    ;;
                "ARCHIVED_REPORTS")
                    echo "存档报告"
                    ;;
                "STORAGE_USAGE")
                    echo "存储使用情况"
                    ;;
                "CHECK_STARTED")
                    echo "开始执行定期检查"
                    ;;
                "CHECK_COMPLETED")
                    echo "检查完成"
                    ;;
                "ACTIVE")
                    echo "活动"
                    ;;
                "ARCHIVED")
                    echo "已归档"
                    ;;
                
                # Logger messages
                "CHECKING")
                    echo "正在检查"
                    ;;
                "LOG_FILE_ERROR")
                    echo "无法写入日志文件"
                    ;;
                "ERROR")
                    echo "错误"
                    ;;
                "WARNING")
                    echo "警告"
                    ;;
                "SUCCESS")
                    echo "成功"
                    ;;
                "CMD_INSTALLED")
                    echo "已安装"
                    ;;
                "CMD_NOT_INSTALLED")
                    echo "未安装"
                    ;;
                "VERSION_NA")
                    echo "版本信息不可用"
                    ;;
                "FILE_EXISTS")
                    echo "文件存在"
                    ;;
                "FILE_NOT_EXISTS")
                    echo "文件不存在"
                    ;;
                "DIR_EXISTS")
                    echo "目录存在"
                    ;;
                "DIR_NOT_EXISTS")
                    echo "目录不存在"
                    ;;
                "START_CHECKS")
                    echo "开始环境检查..."
                    ;;
                "CHECK_COMPLETION")
                    echo "检查完成状态："
                    ;;
                "COMPLETED_CHECKS")
                    echo "已完成检查项目："
                    ;;
                "FOUND_ERRORS")
                    echo "发现错误数量："
                    ;;
                "FOUND_WARNINGS")
                    echo "发现警告数量："
                    ;;
                "NO_ISSUES")
                    echo "未发现任何问题"
                    ;;
                
                # Checks messages
                "CURRENT_SHELL")
                    echo "当前终端"
                    ;;
                "SHELL_CONFIGS")
                    echo "终端配置"
                    ;;
                "CONTENT_OF")
                    echo "文件内容"
                    ;;
                "PATH_DIRS")
                    echo "PATH 目录"
                    ;;
                "NOT_FOUND")
                    echo "未找到"
                    ;;
                "HOMEBREW_INSTALLED")
                    echo "Homebrew 已安装"
                    ;;
                "HOMEBREW_VERSION")
                    echo "Homebrew 版本"
                    ;;
                "RUNNING_BREW_DOCTOR")
                    echo "运行 brew doctor"
                    ;;
                "INSTALLED_PACKAGES")
                    echo "已安装的包"
                    ;;
                "OUTDATED_PACKAGES")
                    echo "过期的包"
                    ;;
                "HOMEBREW_NOT_INSTALLED")
                    echo "Homebrew 未安装"
                    ;;
                "PYTHON_INSTALL")
                    echo "Python 安装"
                    ;;
                "INSTALLED_PIP_PACKAGES")
                    echo "已安装的 pip 包"
                    ;;
                "CHECKING_OUTDATED")
                    echo "检查过期包"
                    ;;
                "PYENV_VERSIONS")
                    echo "PyEnv 版本"
                    ;;
                "NODE_INSTALL")
                    echo "Node.js 安装"
                    ;;
                "GLOBAL_NPM_PACKAGES")
                    echo "全局 NPM 包"
                    ;;
                "CHECKING_VULNERABILITIES")
                    echo "检查安全漏洞"
                    ;;
                "SKIP_NPM_AUDIT")
                    echo "跳过 NPM 审计（未找到 package-lock.json）"
                    ;;
                "VSCODE_INSTALLED")
                    echo "VS Code 已安装"
                    ;;
                "VSCODE_EXTENSIONS")
                    echo "VS Code 扩展"
                    ;;
                "VSCODE_NOT_INSTALLED")
                    echo "VS Code 未安装"
                    ;;
                "GIT_CONFIG")
                    echo "Git 配置"
                    ;;
                "GIT_NOT_INSTALLED")
                    echo "Git 未安装"
                    ;;
                "DISK_USAGE")
                    echo "磁盘使用情况"
                    ;;
                "LARGE_FILES")
                    echo "大文件（>100MB）"
                    ;;
                "NETWORK_INTERFACES")
                    echo "网络接口"
                    ;;
                "DNS_CONFIG")
                    echo "DNS 配置"
                    ;;
                "ACTIVE_PORTS")
                    echo "活动端口"
                    ;;
                "FILEVAULT_ENABLED")
                    echo "FileVault 已启用"
                    ;;
                "FILEVAULT_DISABLED")
                    echo "FileVault 未启用"
                    ;;
                "FIREWALL_ENABLED")
                    echo "防火墙已启用"
                    ;;
                "FIREWALL_DISABLED")
                    echo "防火墙未启用"
                    ;;
                "SIP_ENABLED")
                    echo "系统完整性保护已启用"
                    ;;
                "SIP_DISABLED")
                    echo "系统完整性保护未启用"
                    ;;
                "CHECKING_DEPENDENCIES")
                    echo "检查依赖关系"
                    ;;
                "HOMEBREW_DEPS")
                    echo "Homebrew 依赖"
                    ;;
                "PYTHON_DEPS")
                    echo "Python 依赖"
                    ;;
                "NODE_DEPS")
                    echo "Node.js 依赖"
                    ;;
                "CHECKING_PATH_DUPLICATES")
                    echo "检查 PATH 重复"
                    ;;
                "CHECKING_ALIAS_CONFLICTS")
                    echo "检查别名冲突"
                    ;;
                "CHECKING_FILE_ALIASES")
                    echo "检查文件别名"
                    ;;
                "CHECKING_JAVA_VERSIONS")
                    echo "检查 Java 版本"
                    ;;
                "TOP_CPU_PROCESSES")
                    echo "CPU 占用最高的进程"
                    ;;
                "TOP_MEMORY_PROCESSES")
                    echo "内存占用最高的进程"
                    ;;
                "SYSTEM_LOAD")
                    echo "系统负载"
                    ;;
                "VM_STATS")
                    echo "虚拟内存统计"
                    ;;
                
                # Report headers
                "ENV_CHECK_RESULTS")
                    echo "环境检查结果"
                    ;;
                "GENERATED_ON")
                    echo "生成时间"
                    ;;
                "QUICK_SUMMARY")
                    echo "快速摘要"
                    ;;
                "TOTAL_CHECKS")
                    echo "总检查数"
                    ;;
                "ERRORS")
                    echo "错误"
                    ;;
                "WARNINGS")
                    echo "警告"
                    ;;
                "CHECK_RESULTS")
                    echo "检查结果"
                    ;;
                "COMPONENT")
                    echo "组件"
                    ;;
                "STATUS")
                    echo "状态"
                    ;;
                "DETAILS")
                    echo "详情"
                    ;;
                
                # Status messages
                "PASSED")
                    echo "通过"
                    ;;
                "FAILED")
                    echo "失败"
                    ;;
                "WARNING")
                    echo "警告"
                    ;;
                "VIEW_DETAILS")
                    echo "查看详情"
                    ;;
                
                # Analysis sections
                "ANALYSIS_REPORTS")
                    echo "分析报告"
                    ;;
                "FULL_ANALYSIS")
                    echo "完整分析"
                    ;;
                "STATISTICS")
                    echo "统计数据"
                    ;;
                "HISTORICAL_TRENDS")
                    echo "历史趋势"
                    ;;
                "SUMMARY_REPORT")
                    echo "摘要报告"
                    ;;
                
                # System components
                "SYSTEM_INFO")
                    echo "系统信息"
                    ;;
                "SHELL")
                    echo "终端环境"
                    ;;
                "PYTHON_ENV")
                    echo "Python环境"
                    ;;
                "NODE_ENV")
                    echo "Node.js环境"
                    ;;
                "HOMEBREW")
                    echo "Homebrew"
                    ;;
                
                # Status messages
                "INSTALLED")
                    echo "已安装"
                    ;;
                "NOT_INSTALLED")
                    echo "未安装"
                    ;;
                "SYSTEM_INFO_NA")
                    echo "系统信息不可用"
                    ;;
                "NO_HOMEBREW_ISSUES")
                    echo "Homebrew运行正常"
                    ;;
                "PYTHON_NOT_INSTALLED")
                    echo "Python未安装"
                    ;;
                "NODE_NOT_INSTALLED")
                    echo "Node.js未安装"
                    ;;
                
                # Report sections
                "KEY_FINDINGS")
                    echo "主要发现"
                    ;;
                "ISSUES_FOUND")
                    echo "发现的问题"
                    ;;
                "RECOMMENDATIONS")
                    echo "建议"
                    ;;
                "CRITICAL_ISSUES")
                    echo "严重问题"
                    ;;
                "NO_CRITICAL_ISSUES")
                    echo "没有发现严重问题"
                    ;;
                
                # Component names
                "system_info")
                    echo "系统信息"
                    ;;
                "shell_env")
                    echo "终端环境"
                    ;;
                "path_config")
                    echo "路径配置"
                    ;;
                "homebrew")
                    echo "Homebrew"
                    ;;
                "dev_tools")
                    echo "开发工具"
                    ;;
                "python_env")
                    echo "Python环境"
                    ;;
                "node_env")
                    echo "Node.js环境"
                    ;;
                "editor_config")
                    echo "编辑器配置"
                    ;;
                "git_config")
                    echo "Git配置"
                    ;;
                "disk_space")
                    echo "磁盘空间"
                    ;;
                "network")
                    echo "网络"
                    ;;
                "security")
                    echo "安全设置"
                    ;;
                "dependencies")
                    echo "依赖项"
                    ;;
                "conflicts")
                    echo "配置冲突"
                    ;;
                "performance")
                    echo "系统性能"
                    ;;
                
                *)
                    echo "$key"
                    ;;
            esac
            ;;
        *)  # Default English
            case "$key" in
                # Keep existing English messages...
                "ENV_CHECK_SUMMARY")
                    echo "Environment Check History Summary"
                    ;;
                "RECENT_CHECKS")
                    echo "Recent Checks"
                    ;;
                "ARCHIVED_REPORTS")
                    echo "Archived Reports"
                    ;;
                "STORAGE_USAGE")
                    echo "Storage Usage"
                    ;;
                "CHECK_STARTED")
                    echo "Running scheduled check"
                    ;;
                "CHECK_COMPLETED")
                    echo "Check completed"
                    ;;
                "ACTIVE")
                    echo "active"
                    ;;
                "ARCHIVED")
                    echo "archived"
                    ;;
                *)
                    echo "$key"
                    ;;
            esac
            ;;
    esac
}

# Set language
set_language() {
    local lang="$1"
    case "$lang" in
        "en"|"zh")
            echo "$lang" > "$LANG_FILE"
            ;;
        *)
            echo "Unsupported language: $lang"
            echo "Supported languages: en, zh"
            return 1
            ;;
    esac
}
