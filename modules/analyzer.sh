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

# Run all analysis
run_analysis() {
    create_analysis_report
    create_statistics_json
    create_trends_report
}

# Create detailed analysis report
create_analysis_report() {
    {
        echo "# Environment Check Analysis Report"
        echo "Generated on: $(date)"
        echo
        
        echo "## Error Analysis"
        if [ -f "$ERROR_LOG" ]; then
            echo "\`\`\`"
            echo "Total Errors: $(grep -c 'ERROR' "$ERROR_LOG")"
            echo "Error Categories:"
            grep 'ERROR' "$ERROR_LOG" | cut -d '-' -f2- | sort | uniq -c | sort -nr
            echo "\`\`\`"
        else
            echo "No errors found."
        fi
        echo
        
        echo "## Warning Analysis"
        echo "\`\`\`"
        echo "Warnings by category:"
        find "${OUTPUT_DIR}/logs" -type f -name "*.log" -exec grep -H 'WARNING' {} \; | \
            awk -F: '{print $1}' | sort | uniq -c | sort -nr
        echo "\`\`\`"
        echo
        
        echo "## Configuration Issues"
        echo "\`\`\`"
        find "${OUTPUT_DIR}/logs" -type f -name "*.log" -exec grep -H '✗' {} \; | \
            awk -F: '{print $1}' | sort | uniq -c | sort -nr
        echo "\`\`\`"
        echo
        
        echo "## Component Status Summary"
        echo "\`\`\`"
        for log_file in "${OUTPUT_DIR}"/logs/*.log; do
            if [ -f "$log_file" ]; then
                component=$(basename "$log_file" .log | sed 's/^[0-9]*_//')
                if grep -q "ERROR" "$log_file" 2>/dev/null; then
                    status="Failed"
                elif grep -q "WARNING\|✗" "$log_file" 2>/dev/null; then
                    status="Warning"
                else
                    status="Passed"
                fi
                printf "%-20s %s\n" "$component:" "$status"
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
        # Remove trailing comma from last component
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
        echo "# Historical Trends Analysis"
        echo "Generated on: $(date)"
        echo
        
        echo "## Issue Trends"
        echo "\`\`\`"
        if [ -d "$HOME/.env_check_history" ]; then
            for prev_check in "$HOME/.env_check_history"/*; do
                if [ -d "$prev_check" ]; then
                    check_date=$(basename "$prev_check" | grep -o "[0-9]\{8\}")
                    if [ -n "$check_date" ]; then
                        formatted_date=$(date -j -f "%Y%m%d" "$check_date" "+%Y-%m-%d" 2>/dev/null)
                        error_count=$(find "$prev_check" -type f -exec grep -l "ERROR" {} \; 2>/dev/null | wc -l)
                        warning_count=$(find "$prev_check" -type f -exec grep -l "WARNING\|✗" {} \; 2>/dev/null | wc -l)
                        echo "${formatted_date}: Errors: ${error_count}, Warnings: ${warning_count}"
                    fi
                fi
            done
        fi
        echo "\`\`\`"
        echo
        
        echo "## Component Trends"
        echo "\`\`\`"
        if [ -d "$HOME/.env_check_history" ]; then
            echo "Component status changes over time:"
            for component in system_info shell_env path_config homebrew dev_tools python_env node_env editor_config git_config; do
                echo
                echo "$component:"
                for prev_check in "$HOME/.env_check_history"/*; do
                    if [ -d "$prev_check" ]; then
                        check_date=$(basename "$prev_check" | grep -o "[0-9]\{8\}")
                        if [ -n "$check_date" ]; then
                            formatted_date=$(date -j -f "%Y%m%d" "$check_date" "+%Y-%m-%d" 2>/dev/null)
                            status="OK"
                            log_file=$(find "$prev_check" -name "*${component}.log" -type f)
                            if [ -f "$log_file" ]; then
                                if grep -q "ERROR" "$log_file" 2>/dev/null; then
                                    status="Error"
                                elif grep -q "WARNING\|✗" "$log_file" 2>/dev/null; then
                                    status="Warning"
                                fi
                            fi
                            echo "  ${formatted_date}: ${status}"
                        fi
                    fi
                done
            done
        else
            echo "No historical data available"
        fi
        echo "\`\`\`"
        echo
        
        echo "## Performance Trends"
        echo "\`\`\`"
        if [ -d "$HOME/.env_check_history" ]; then
            echo "System performance over time:"
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
                            echo "  CPU Load: ${cpu_load:-N/A}"
                            echo "  Memory Usage: ${mem_usage:-N/A}"
                        fi
                    fi
                fi
            done
        else
            echo "No historical performance data available"
        fi
        echo "\`\`\`"
    } > "$TRENDS_MD"
}
