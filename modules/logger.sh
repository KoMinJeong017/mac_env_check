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
# File Name:    logger.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Fri 17 Jan 14:38:34 2025
#########################################################################
#!/bin/bash

# Import language module
source "${SCRIPT_DIR}/modules/language.sh"

# Function to ensure directory exists with proper permissions
ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || {
            echo "$(get_message "DIR_CREATE_ERROR"): $dir" >&2
            return 1
        }
    fi
    chmod 755 "$dir" || {
        echo "$(get_message "DIR_PERMISSION_ERROR"): $dir" >&2
        return 1
    }
    return 0
}

# Function to ensure file exists with proper permissions
ensure_file() {
    local file="$1"
    local dir="$(dirname "$file")"
    
    # First ensure parent directory exists
    ensure_directory "$dir" || return 1
    
    # Create or check file
    if [ ! -f "$file" ]; then
        touch "$file" || {
            echo "$(get_message "FILE_CREATE_ERROR"): $file" >&2
            return 1
        }
    fi
    
    # Set file permissions
    chmod 644 "$file" || {
        echo "$(get_message "FILE_PERMISSION_ERROR"): $file" >&2
        return 1
    }
    return 0
}

# Setup logging
setup_logging() {
    # Ensure log directory exists with proper permissions
    ensure_directory "$(dirname "$ERROR_LOG")" || return 1
    ensure_file "$ERROR_LOG" || return 1
}

# Progress tracking variables
TOTAL_CHECKS=15
CURRENT_CHECK=0

# Log progress to console with progress bar
log_progress() {
    CURRENT_CHECK=$((CURRENT_CHECK + 1))
    local title="$1"
    local percent=$((CURRENT_CHECK * 100 / TOTAL_CHECKS))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    # Create the progress bar
    printf "\r["
    printf "%${filled}s" "" | tr ' ' '='
    printf ">"
    printf "%${empty}s" "" | tr ' ' ' '
    printf "] %3d%% " "$percent"
    
    # Print the check title
    printf "${GREEN}%s: %-30s${NC}" "$(get_message "CHECKING")" "$title..."
    
    # Move to new line if it's the last check
    if [ $CURRENT_CHECK -eq $TOTAL_CHECKS ]; then
        printf "\n"
    fi
}

# Log message to specific file
log_to_file() {
    local log_file="$1"
    shift
    
    # Ensure file exists and has proper permissions
    ensure_file "$log_file" || return 1
    
    # Try to write to file
    if ! echo -e "$@" >> "$log_file" 2>/dev/null; then
        echo "$(get_message "FILE_WRITE_ERROR"): $log_file" >&2
        return 1
    fi
    return 0
}

# Log error message
log_error() {
    local message="$1"
    if ! echo -e "${RED}[$(get_message "ERROR")] $(date '+%Y-%m-%d %H:%M:%S') - $message${NC}" | tee -a "$ERROR_LOG" >&2; then
        echo "$(get_message "ERROR_LOG_WRITE_ERROR")" >&2
    fi
    ((FAILED_CHECKS++))
}

# Log warning message
log_warning() {
    local message="$1"
    if ! echo -e "${YELLOW}[$(get_message "WARNING")] $(date '+%Y-%m-%d %H:%M:%S') - $message${NC}" | tee -a "$ERROR_LOG"; then
        echo "$(get_message "WARNING_LOG_WRITE_ERROR")" >&2
    fi
}

# Log success message
log_success() {
    local message="$1"
    echo -e "${GREEN}[$(get_message "SUCCESS")] $message${NC}"
}

# Function to check command and log
check_command() {
    local cmd="$1"
    local log_file="$2"
    if command -v $cmd >/dev/null 2>&1; then
        log_to_file "$log_file" "${GREEN}✓ $(get_message "CMD_INSTALLED") $cmd${NC}" || return 1
        $cmd --version 2>/dev/null | grep . >> "$log_file" || \
        $cmd -v 2>/dev/null | grep . >> "$log_file" || \
        log_to_file "$log_file" "$(get_message "VERSION_NA")" || return 1
        return 0
    else
        log_to_file "$log_file" "${RED}✗ $(get_message "CMD_NOT_INSTALLED") $cmd${NC}" || return 1
        return 1
    fi
}

# Function to check file existence and log
check_file() {
    local file="$1"
    local log_file="$2"
    if [ -f "$file" ]; then
        log_to_file "$log_file" "${GREEN}✓ $(get_message "FILE_EXISTS") $file${NC}" || return 1
        return 0
    else
        log_to_file "$log_file" "${RED}✗ $(get_message "FILE_NOT_EXISTS") $file${NC}" || return 1
        return 1
    fi
}

# Function to check directory existence and log
check_directory() {
    local dir="$1"
    local log_file="$2"
    if [ -d "$dir" ]; then
        log_to_file "$log_file" "${GREEN}✓ $(get_message "DIR_EXISTS") $dir${NC}" || return 1
        return 0
    else
        log_to_file "$log_file" "${RED}✗ $(get_message "DIR_NOT_EXISTS") $dir${NC}" || return 1
        return 1
    fi
}

# Reset and show initial progress
reset_progress() {
    CURRENT_CHECK=0
    printf "\n%s\n" "$(get_message "START_CHECKS")"
}

# Show completion status
show_completion() {
    # 确保初始值为整数
    local total_errors=0
    local total_warnings=0
    
    # 统计错误数量并确保是整数
    if [ -f "$ERROR_LOG" ]; then
        total_errors=$(grep -c "ERROR" "$ERROR_LOG" 2>/dev/null | tr -d '[:space:]' || echo "0")
    fi
    
    # 统计警告数量并确保是整数
    if [ -d "${OUTPUT_DIR}/logs" ]; then
        total_warnings=$(find "${OUTPUT_DIR}/logs" -type f -exec grep -l "WARNING\|✗" {} \; 2>/dev/null | wc -l | tr -d '[:space:]' || echo "0")
    fi
    
    # 清理可能的非数字字符
    total_errors=$(echo "$total_errors" | tr -cd '0-9')
    total_warnings=$(echo "$total_warnings" | tr -cd '0-9')
    
    # 确保值为整数（如果为空则设为0）
    : "${total_errors:=0}"
    : "${total_warnings:=0}"
    
    # 显示完成状态
    printf "\n%s\n" "$(get_message "COMPLETION_STATUS")"
    printf "${GREEN}✓ $(get_message "CHECKS_COMPLETED") ${TOTAL_CHECKS}${NC}\n"
    
    # 使用(()) 进行数值比较
    if ((total_errors > 0)); then
        printf "${RED}✗ $(get_message "ERRORS_FOUND") %d${NC}\n" "${total_errors}"
    fi
    
    if ((total_warnings > 0)); then
        printf "${YELLOW}! $(get_message "WARNINGS_FOUND") %d${NC}\n" "${total_warnings}"
    fi
    
    if ((total_errors == 0 && total_warnings == 0)); then
        printf "${GREEN}✓ $(get_message "NO_ISSUES")${NC}\n"
    fi
    
    # 添加完成消息和报告链接
    printf "\n${GREEN}%s${NC}\n" "$(get_message "CHECK_COMPLETE_MSG")"
    printf "%s %s\n" "$(get_message "REPORT_SAVED_AT")" "$OUTPUT_DIR"
    
    # 创建可点击的HTML报告链接
    local html_path="file://${INDEX_HTML}"
    printf "\n%s " "$(get_message "CLICK_TO_VIEW")"
    printf "\e]8;;%s\e\\%s\e]8;;\e\\\n" "$html_path" "$html_path"
}