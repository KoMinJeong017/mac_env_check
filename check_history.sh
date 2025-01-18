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
# File Name:    check_history.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Sat 18 Jan 07:49:55 2025
#########################################################################
#!/bin/bash

# Get project root and set history directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
HISTORY_DIR="${PROJECT_ROOT}/.env_check_history"

# Import language module
source "${SCRIPT_DIR}/modules/language.sh"

echo "$(get_message "ENV_CHECK_SUMMARY")"
echo "--------------------------------"

# Display recent checks
echo "$(get_message "RECENT_CHECKS"):"
if [ -f "$HISTORY_DIR/scheduled_check.log" ]; then
    tail -n 10 "$HISTORY_DIR/scheduled_check.log"
fi

# Display archive statistics
echo -e "\n$(get_message "ARCHIVED_REPORTS"):"
{
    # Display active checks
    if [ -d "$HISTORY_DIR/active_checks" ]; then
        find "$HISTORY_DIR/active_checks" -maxdepth 1 -name "mac_env_check_*" -type d | \
        sort -r | while read -r file; do
            echo "$(basename "$file") ($(get_message "ACTIVE"))"
        done
    fi

    # Display archived checks
    if [ -d "$HISTORY_DIR/archives" ]; then
        find "$HISTORY_DIR/archives" -name "mac_env_check_*.tar.gz" | \
        sort -r | while read -r file; do
            echo "$(basename "$file" .tar.gz) ($(get_message "ARCHIVED"))"
        done
    fi
} | head -n 10  # Only show last 10 records

# Display storage usage
echo -e "\n$(get_message "STORAGE_USAGE"):"
if [ -d "$HISTORY_DIR" ]; then
    for dir in active_checks archives; do
        if [ -d "$HISTORY_DIR/$dir" ]; then
            du -sh "$HISTORY_DIR/$dir" 2>/dev/null || echo "0B $HISTORY_DIR/$dir"
        fi
    done
fi

# Display total statistics
echo -e "\n$(get_message "TOTAL_STATISTICS"):"
active_count=$(find "$HISTORY_DIR/active_checks" -maxdepth 1 -name "mac_env_check_*" -type d 2>/dev/null | wc -l | tr -d ' ')
archive_count=$(find "$HISTORY_DIR/archives" -name "mac_env_check_*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
echo "$(get_message "ACTIVE_CHECKS"): $active_count"
echo "$(get_message "ARCHIVED_CHECKS"): $archive_count"