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

# Initialize configuration
init_config() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    OUTPUT_DIR="${NAME_PREFIX}_${TIMESTAMP}${NAME_SUFFIX:+_$NAME_SUFFIX}"

    # Define directory structure
    mkdir -p "${OUTPUT_DIR}/logs"
    mkdir -p "${OUTPUT_DIR}/analysis"

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

    # Initialize all log files
    for log_file in \
        "$SYSTEM_LOG" "$SHELL_LOG" "$PATH_LOG" "$HOMEBREW_LOG" \
        "$TOOLS_LOG" "$PYTHON_LOG" "$NODE_LOG" "$EDITOR_LOG" \
        "$GIT_LOG" "$DISK_LOG" "$NETWORK_LOG" "$SECURITY_LOG" \
        "$DEPS_LOG" "$CONFLICTS_LOG" "$PERFORMANCE_LOG" "$ERROR_LOG"; do
        touch "$log_file"
    done

    # Initialize analysis files
    touch "$ANALYSIS_REPORT" "$STATISTICS_JSON" "$TRENDS_MD" "$SUMMARY_TXT" "$INDEX_HTML"
}

# Archive management
archive_old_logs() {
    local archive_dir="$HOME/.env_check_history"
    mkdir -p "$archive_dir"

    find "$HOME" -maxdepth 1 -name "${NAME_PREFIX}_*" -type d -mtime "+${KEEP_DAYS}" -exec mv {} "$archive_dir/" \;

    cd "$archive_dir" || return
    for dir in ${NAME_PREFIX}_*; do
        if [ -d "$dir" ] && [ ! -f "$dir.tar.gz" ]; then
            tar czf "$dir.tar.gz" "$dir"
            rm -rf "$dir"
        fi
    done
}
