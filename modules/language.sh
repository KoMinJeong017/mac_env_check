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
DEFAULT_LANG="en"

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
                    echo "检查完成时间"
                    ;;
                "ACTIVE")
                    echo "活动"
                    ;;
                "ARCHIVED")
                    echo "已归档"
                    ;;
                *)
                    echo "$key"
                    ;;
            esac
            ;;
        *)  # Default English
            case "$key" in
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

