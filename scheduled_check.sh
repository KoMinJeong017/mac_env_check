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
# File Name:    scheduled_check.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Sat 18 Jan 07:48:43 2025
#########################################################################
#!/bin/bash

# Get project root and set history directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
HISTORY_DIR="${PROJECT_ROOT}/.env_check_history"

# Set log file
LOG_FILE="${HISTORY_DIR}/scheduled_check.log"

# Ensure history directory exists
mkdir -p "${HISTORY_DIR}"

# Record run time
echo "Running scheduled check at $(date)" >> "$LOG_FILE"

# Run environment check with 90-day retention
cd "$SCRIPT_DIR"
./check_env_new.sh -k 90

# Record completion status
echo "Check completed at $(date)" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"