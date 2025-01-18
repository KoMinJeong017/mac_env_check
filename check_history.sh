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

# Import language module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/modules/language.sh"

HISTORY_DIR=~/.env_check_history

echo "$(get_message "ENV_CHECK_SUMMARY")"
echo "--------------------------------"

# Display recent checks
echo "$(get_message "RECENT_CHECKS"):"
if [ -f "$HISTORY_DIR/scheduled_check.log" ]; then
    tail -n 10 "$HISTORY_DIR/scheduled_check.log"
fi

# Display archive statistics
echo -e "\n$(get_message "ARCHIVED_REPORTS"):"
find "$HISTORY_DIR" -name "mac_env_check_*" -type d -o -name "mac_env_check_*.tar.gz" | \
    sort -r | \
    while read -r file; do
        if [ -d "$file" ]; then
            echo "$(basename "$file") ($(get_message "ACTIVE"))"
        else
            echo "$(basename "$file") ($(get_message "ARCHIVED"))"
        fi
    done

# Display storage usage
echo -e "\n$(get_message "STORAGE_USAGE"):"
du -sh "$HISTORY_DIR"
