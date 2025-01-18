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
# File Name:    config.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Fri 17 Jan 14:38:03 2025
#########################################################################
#!/bin/bash

# Import language module
source "${SCRIPT_DIR}/modules/language.sh"

# Default configuration values
NAME_PREFIX="mac_env_check"
NAME_SUFFIX=""
KEEP_DAYS=30
ANALYZE_ONLY=false
FAILED_CHECKS=0

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Help message translations
show_help() {
    if [ "$(get_current_lang)" = "zh" ]; then
        cat << EOF
MacOS 环境检查工具 v${VERSION}

用法: $(basename "$0") [选项]

选项:
  -n, --name 前缀     设置日志文件的自定义前缀
  -s, --suffix 后缀   设置日志文件的自定义后缀
  -k, --keep 天数     保留指定天数的日志（默认：30天）
  -a, --analyze-only  仅分析现有日志，不执行新的检查
  -h, --help         显示此帮助信息
EOF
    else
        cat << EOF
MacOS Environment Check Tool v${VERSION}

Usage: $(basename "$0") [OPTIONS]

Options:
  -n, --name PREFIX     Set custom prefix for log files
  -s, --suffix SUFFIX   Set custom suffix for log files
  -k, --keep DAYS      Keep logs for specified number of days (default: 30)
  -a, --analyze-only   Only analyze existing logs without running checks
  -h, --help           Show this help message
EOF
    fi
}

# Initialize configuration
init_config() {
    # Get project root directory
    PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    # Set history directory in project root
    HISTORY_DIR="${PROJECT_ROOT}/.env_check_history"
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    OUTPUT_DIR="${HISTORY_DIR}/active_checks/${NAME_PREFIX}_${TIMESTAMP}${NAME_SUFFIX:+_$NAME_SUFFIX}"
    
    # Define directory structure
    mkdir -p "${OUTPUT_DIR}/logs"
    mkdir -p "${OUTPUT_DIR}/analysis"
    mkdir -p "${HISTORY_DIR}/archives"
    
    # Define log files
    SYSTEM_LOG="${OUTPUT_DIR}/logs/01_system_info.log"
    SHELL_LOG="${OUTPUT_DIR}/logs/02_shell_env.log"
    PATH_LOG="${OUTPUT_DIR}/logs/03_path_config.log"
    HOMEBREW_LOG="${OUTPUT_DIR}/logs/04_homebrew.log"
    TOOLS_LOG="${OUTPUT_DIR}/logs/05_dev_tools.log"
    PYTHON_LOG="${OUTPUT_DIR}/logs/06_python_env.log"
    NODE_LOG="${OUTPUT_DIR}/logs/07_node_env.log"
    EDITOR_LOG="${OUTPUT_DIR}/logs/08_editor_config.log"
    GIT_LOG="${OUTPUT_DIR}/logs/09_git_config.log"
    DISK_LOG="${OUTPUT_DIR}/logs/10_disk_space.log"
    NETWORK_LOG="${OUTPUT_DIR}/logs/11_network.log"
    SECURITY_LOG="${OUTPUT_DIR}/logs/12_security.log"
    DEPS_LOG="${OUTPUT_DIR}/logs/13_dependencies.log"
    CONFLICTS_LOG="${OUTPUT_DIR}/logs/14_conflicts.log"
    PERFORMANCE_LOG="${OUTPUT_DIR}/logs/15_performance.log"
    ERROR_LOG="${OUTPUT_DIR}/logs/errors.log"

    # Analysis files
    ANALYSIS_REPORT="${OUTPUT_DIR}/analysis/analysis_report.md"
    STATISTICS_JSON="${OUTPUT_DIR}/analysis/statistics.json"
    TRENDS_MD="${OUTPUT_DIR}/analysis/trends.md"
    SUMMARY_TXT="${OUTPUT_DIR}/summary.txt"
    INDEX_HTML="${OUTPUT_DIR}/index.html"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                NAME_PREFIX="$2"
                shift 2
                ;;
            -s|--suffix)
                NAME_SUFFIX="$2"
                shift 2
                ;;
            -k|--keep)
                KEEP_DAYS="$2"
                shift 2
                ;;
            -a|--analyze-only)
                ANALYZE_ONLY=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                if [ "$(get_current_lang)" = "zh" ]; then
                    echo "未知选项: $1"
                else
                    echo "Unknown option: $1"
                fi
                show_help
                exit 1
                ;;
        esac
    done
}

# Archive management
archive_old_logs() {
    local archive_dir="${HISTORY_DIR}/archives"
    local active_dir="${HISTORY_DIR}/active_checks"
    
    find "$active_dir" -maxdepth 1 -name "${NAME_PREFIX}_*" -type d -mtime "+${KEEP_DAYS}" -exec mv {} "$archive_dir/" \;
    
    cd "$archive_dir" || return
    for dir in ${NAME_PREFIX}_*; do
        if [ -d "$dir" ] && [ ! -f "$dir.tar.gz" ]; then
            tar czf "$dir.tar.gz" "$dir"
            rm -rf "$dir"
        fi
    done
}

# Get current language helper function
get_current_lang() {
    if [ -f "$HOME/.env_check_config/language" ]; then
        cat "$HOME/.env_check_config/language"
    else
        echo "$DEFAULT_LANG"
    fi
}
