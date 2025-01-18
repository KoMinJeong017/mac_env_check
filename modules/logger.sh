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

# Setup logging
setup_logging() {
    # Ensure log directory exists
    mkdir -p "$(dirname "$ERROR_LOG")"
    touch "$ERROR_LOG"
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
    printf "${GREEN}Checking: %-30s${NC}" "$title..."
    
    # Move to new line if it's the last check
    if [ $CURRENT_CHECK -eq $TOTAL_CHECKS ]; then
        printf "\n"
    fi
}

# Log message to specific file
log_to_file() {
    local log_file="$1"
    shift
    if [ -f "$log_file" ]; then
        echo -e "$@" >> "$log_file"
    else
        echo "Error: Could not write to log file: $log_file" >&2
        return 1
    fi
}

# Log error message
log_error() {
    local message="$1"
    echo -e "${RED}[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $message${NC}" | tee -a "$ERROR_LOG" >&2
    ((FAILED_CHECKS++))
}

# Log warning message
log_warning() {
    local message="$1"
    echo -e "${YELLOW}[WARNING] $(date '+%Y-%m-%d %H:%M:%S') - $message${NC}" | tee -a "$ERROR_LOG"
}

# Log success message
log_success() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS] $message${NC}"
}

# Function to check command and log
check_command() {
    local cmd="$1"
    local log_file="$2"
    if command -v $cmd >/dev/null 2>&1; then
        log_to_file "$log_file" "${GREEN}✓ $cmd is installed${NC}"
        $cmd --version 2>/dev/null | grep . >> "$log_file" || \
        $cmd -v 2>/dev/null | grep . >> "$log_file" || \
        log_to_file "$log_file" "Version not available"
        return 0
    else
        log_to_file "$log_file" "${RED}✗ $cmd is not installed${NC}"
        return 1
    fi
}

# Function to check file existence and log
check_file() {
    local file="$1"
    local log_file="$2"
    if [ -f "$file" ]; then
        log_to_file "$log_file" "${GREEN}✓ $file exists${NC}"
        return 0
    else
        log_to_file "$log_file" "${RED}✗ $file does not exist${NC}"
        return 1
    fi
}

# Function to check directory existence and log
check_directory() {
    local dir="$1"
    local log_file="$2"
    if [ -d "$dir" ]; then
        log_to_file "$log_file" "${GREEN}✓ $dir exists${NC}"
        return 0
    else
        log_to_file "$log_file" "${RED}✗ $dir does not exist${NC}"
        return 1
    fi
}
