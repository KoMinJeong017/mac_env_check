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
# File Name:    analyzer.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Fri 17 Jan 14:40:40 2025
#########################################################################
#!/bin/bash

# Import language module
source "${SCRIPT_DIR}/modules/language.sh"

# Run all analysis
run_analysis() {
    create_analysis_report
    create_statistics_json
    create_trends_report
}

# Create detailed analysis report
create_analysis_report() {
    {
        echo "# $(get_message "ANALYSIS_REPORT_TITLE")"
        echo "$(get_message "GENERATED_ON"): $(date)"
        echo
        
        echo "## $(get_message "ERROR_ANALYSIS")"
        if [ -f "$ERROR_LOG" ]; then
            echo "\`\`\`"
            echo "$(get_message "TOTAL_ERRORS"): $(grep -c 'ERROR' "$ERROR_LOG")"
            echo "$(get_message "ERROR_CATEGORIES"):"
            grep 'ERROR' "$ERROR_LOG" | cut -d '-' -f2- | sort | uniq -c | sort -nr
            echo "\`\`\`"
        else
            echo "$(get_message "NO_ERRORS_FOUND")"
        fi
        echo
        
        echo "## $(get_message "WARNING_ANALYSIS")"
        echo "\`\`\`"
        echo "$(get_message "WARNINGS_BY_CATEGORY"):"
        find "${OUTPUT_DIR}/logs" -type f -name "*.log" -exec grep -H 'WARNING' {} \; | \
            awk -F: '{print $1}' | sort | uniq -c | sort -nr
        echo "\`\`\`"
        echo
        
        echo "## $(get_message "CONFIG_ISSUES")"
        echo "\`\`\`"
        find "${OUTPUT_DIR}/logs" -type f -name "*.log" -exec grep -H '✗' {} \; | \
            awk -F: '{print $1}' | sort | uniq -c | sort -nr
        echo "\`\`\`"
        echo
        
        echo "## $(get_message "COMPONENT_STATUS")"
        echo "\`\`\`"
        for log_file in "${OUTPUT_DIR}"/logs/*.log; do
            if [ -f "$log_file" ]; then
                component=$(basename "$log_file" .log | sed 's/^[0-9]*_//')
                if grep -q "ERROR" "$log_file" 2>/dev/null; then
                    status="$(get_message "FAILED")"
                elif grep -q "WARNING\|✗" "$log_file" 2>/dev/null; then
                    status="$(get_message "WARNING")"
                else
                    status="$(get_message "PASSED")"
                fi
                printf "%-20s %s\n" "$(get_message "$component"):" "$status"
            fi
        done
        echo "\`\`\`"
    } > "$ANALYSIS_REPORT"
}

# Create statistics JSON
create_statistics_json() {
    {
        echo "{"
        echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
        echo "  \"system_info\": {"
        echo "    \"os_version\": \"$(sw_vers -productVersion)\","
        echo "    \"hostname\": \"$(hostname)\""
        echo "  },"
        
        echo "  \"checks\": {"
        echo "    \"total\": $(find "${OUTPUT_DIR}/logs" -type f -name "*.log" | wc -l),"
        echo "    \"passed\": $(find "${OUTPUT_DIR}/logs" -type f -exec grep -L "ERROR\|WARNING\|✗" {} \; | wc -l),"
        echo "    \"failed\": $(find "${OUTPUT_DIR}/logs" -type f -exec grep -l "ERROR" {} \; | wc -l),"
        echo "    \"warnings\": $(find "${OUTPUT_DIR}/logs" -type f -exec grep -l "WARNING\|✗" {} \; | wc -l)"
        echo "  },"
        
        echo "  \"components\": {"
        for log_file in "${OUTPUT_DIR}"/logs/*.log; do
            if [ -f "$log_file" ]; then
                component=$(basename "$log_file" .log | sed 's/^[0-9]*_//')
                status="ok"
                if grep -q "ERROR" "$log_file" 2>/dev/null; then
                    status="error"
                elif grep -q "WARNING\|✗" "$log_file" 2>/dev/null; then
                    status="warning"
                fi
                echo "    \"${component}\": \"${status}\","
            fi
        done
        sed -i '' '$ s/,$//' "$STATISTICS_JSON"
        echo "  },"
        
        echo "  \"performance\": {"
        echo "    \"cpu_usage\": $(ps -A -o %cpu | awk '{s+=$1} END {print s}'),"
        echo "    \"memory_usage\": $(ps -A -o %mem | awk '{s+=$1} END {print s}'),"
        echo "    \"load_average\": \"$(sysctl -n vm.loadavg | sed 's/{ //;s/ }//')\""
        echo "  }"
        echo "}"
    } > "$STATISTICS_JSON"
}

# Create trends report
create_trends_report() {
    {
        echo "# $(get_message "TRENDS_ANALYSIS_TITLE")"
        echo "$(get_message "GENERATED_ON"): $(date)"
        echo
        
        echo "## $(get_message "ISSUE_TRENDS")"
        echo "\`\`\`"
        if [ -d "$HOME/.env_check_history" ]; then
            for prev_check in "$HOME/.env_check_history"/*; do
                if [ -d "$prev_check" ]; then
                    check_date=$(basename "$prev_check" | grep -o "[0-9]\{8\}")
                    if [ -n "$check_date" ]; then
                        formatted_date=$(date -j -f "%Y%m%d" "$check_date" "+%Y-%m-%d" 2>/dev/null)
                        error_count=$(find "$prev_check" -type f -exec grep -l "ERROR" {} \; 2>/dev/null | wc -l)
                        warning_count=$(find "$prev_check" -type f -exec grep -l "WARNING\|✗" {} \; 2>/dev/null | wc -l)
                        echo "${formatted_date}: $(get_message "ERRORS"): ${error_count}, $(get_message "WARNINGS"): ${warning_count}"
                    fi
                fi
            done
        fi
        echo "\`\`\`"
        echo
        
        echo "## $(get_message "COMPONENT_TRENDS")"
        echo "\`\`\`"
        if [ -d "$HOME/.env_check_history" ]; then
            echo "$(get_message "COMPONENT_STATUS_CHANGES"):"
            for component in system_info shell_env path_config homebrew dev_tools python_env node_env editor_config git_config; do
                echo
                echo "$(get_message "$component"):"
                for prev_check in "$HOME/.env_check_history"/*; do
                    if [ -d "$prev_check" ]; then
                        check_date=$(basename "$prev_check" | grep -o "[0-9]\{8\}")
                        if [ -n "$check_date" ]; then
                            formatted_date=$(date -j -f "%Y%m%d" "$check_date" "+%Y-%m-%d" 2>/dev/null)
                            status="$(get_message "OK")"
                            log_file=$(find "$prev_check" -name "*${component}.log" -type f)
                            if [ -f "$log_file" ]; then
                                if grep -q "ERROR" "$log_file" 2>/dev/null; then
                                    status="$(get_message "ERROR")"
                                elif grep -q "WARNING\|✗" "$log_file" 2>/dev/null; then
                                    status="$(get_message "WARNING")"
                                fi
                            fi
                            echo "  ${formatted_date}: ${status}"
                        fi
                    fi
                done
            done
        else
            echo "$(get_message "NO_HISTORY_DATA")"
        fi
        echo "\`\`\`"
        echo
        
        echo "## $(get_message "PERFORMANCE_TRENDS")"
        echo "\`\`\`"
        if [ -d "$HOME/.env_check_history" ]; then
            echo "$(get_message "SYSTEM_PERFORMANCE_OVER_TIME"):"
            for prev_check in "$HOME/.env_check_history"/*; do
                if [ -d "$prev_check" ]; then
                    check_date=$(basename "$prev_check" | grep -o "[0-9]\{8\}")
                    if [ -n "$check_date" ]; then
                        formatted_date=$(date -j -f "%Y%m%d" "$check_date" "+%Y-%m-%d" 2>/dev/null)
                        perf_file=$(find "$prev_check" -name "*performance.log" -type f)
                        if [ -f "$perf_file" ]; then
                            cpu_load=$(grep "CPU" "$perf_file" | head -1 | awk '{print $1}')
                            mem_usage=$(grep "Memory" "$perf_file" | head -1 | awk '{print $1}')
                            echo "${formatted_date}:"
                            echo "  $(get_message "CPU_LOAD"): ${cpu_load:-N/A}"
                            echo "  $(get_message "MEMORY_USAGE"): ${mem_usage:-N/A}"
                        fi
                    fi
                fi
            done
        else
            echo "$(get_message "NO_PERFORMANCE_DATA")"
        fi
        echo "\`\`\`"
    } > "$TRENDS_MD"
}
