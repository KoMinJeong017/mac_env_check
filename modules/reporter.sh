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
# File Name:    reporter.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Fri 17 Jan 14:40:06 2025
#########################################################################
#!/bin/bash

# Import language module
source "${SCRIPT_DIR}/modules/language.sh"

# Generate all reports
generate_all_reports() {
    create_html_index
    create_summary
    create_analysis_report
    create_statistics_json
    create_trends_report
}

# Create HTML index
create_html_index() {
    cat > "$INDEX_HTML" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>$(get_message "ENV_CHECK_RESULTS")</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .section { margin-bottom: 20px; }
        .status-ok { color: green; }
        .status-warning { color: orange; }
        .status-error { color: red; }
        .log-link { text-decoration: none; color: #0066cc; }
        .log-link:hover { text-decoration: underline; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { padding: 8px; text-align: left; border: 1px solid #ddd; }
        th { background-color: #f5f5f5; }
        .summary { background-color: #f8f9fa; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>$(get_message "ENV_CHECK_RESULTS")</h1>
        <p>$(get_message "GENERATED_ON"): $(date)</p>

        <div class="summary">
            <h2>$(get_message "QUICK_SUMMARY")</h2>
            <p>$(get_message "TOTAL_CHECKS"): $(find "${OUTPUT_DIR}/logs" -type f -name "*.log" | wc -l)</p>
            <p>$(get_message "ERRORS"): $(grep -r "ERROR" "${OUTPUT_DIR}/logs" | wc -l)</p>
            <p>$(get_message "WARNINGS"): $(grep -r "WARNING" "${OUTPUT_DIR}/logs" | wc -l)</p>
        </div>

        <div class="section">
            <h2>$(get_message "CHECK_RESULTS")</h2>
            <table>
                <tr>
                    <th>$(get_message "COMPONENT")</th>
                    <th>$(get_message "STATUS")</th>
                    <th>$(get_message "DETAILS")</th>
                </tr>
EOF

    # Add entries for each log file
    for log_file in "${OUTPUT_DIR}"/logs/*.log; do
        if [ -f "$log_file" ]; then
            filename=$(basename "$log_file")
            component=$(echo "$filename" | sed -E 's/^[0-9]+_(.*)\.log$/\1/')

            if grep -q "ERROR" "$log_file" 2>/dev/null; then
                status="error"
                status_text="$(get_message "FAILED")"
            elif grep -q "WARNING\|✗" "$log_file" 2>/dev/null; then
                status="warning"
                status_text="$(get_message "WARNING")"
            else
                status="ok"
                status_text="$(get_message "PASSED")"
            fi

            cat >> "$INDEX_HTML" << EOF
                <tr>
                    <td>$(get_message "$component")</td>
                    <td class="status-${status}">${status_text}</td>
                    <td><a href="logs/${filename}" class="log-link">$(get_message "VIEW_DETAILS")</a></td>
                </tr>
EOF
        fi
    done

    cat >> "$INDEX_HTML" << EOF
            </table>
        </div>

        <div class="section">
            <h2>$(get_message "ANALYSIS_REPORTS")</h2>
            <ul>
                <li><a href="analysis/analysis_report.md" class="log-link">$(get_message "FULL_ANALYSIS")</a></li>
                <li><a href="analysis/statistics.json" class="log-link">$(get_message "STATISTICS")</a></li>
                <li><a href="analysis/trends.md" class="log-link">$(get_message "HISTORICAL_TRENDS")</a></li>
                <li><a href="summary.txt" class="log-link">$(get_message "SUMMARY_REPORT")</a></li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF
}

# Create summary report
create_summary() {
    {
        echo "$(get_message "ENV_CHECK_SUMMARY")"
        echo "$(get_message "GENERATED"): $(date)"
        echo "----------------------------------------"

        echo -e "\n$(get_message "SYSTEM_INFO"):"
        grep "System Version" "$SYSTEM_LOG" 2>/dev/null || echo "$(get_message "SYSTEM_INFO_NA")"

        echo -e "\n$(get_message "KEY_FINDINGS"):"

        # Add shell information
        echo "$(get_message "SHELL"): $SHELL"

        # Add Python version
        if command -v python3 >/dev/null 2>&1; then
            python3 --version
        else
            echo "$(get_message "PYTHON_NOT_INSTALLED")"
        fi

        # Add Node.js version
        if command -v node >/dev/null 2>&1; then
            node --version
        else
            echo "$(get_message "NODE_NOT_INSTALLED")"
        fi

        # Add Homebrew status
        if command -v brew >/dev/null 2>&1; then
            echo "$(get_message "HOMEBREW"): $(get_message "INSTALLED")"
            brew doctor 2>&1 | grep -i "error\|warning" || echo "$(get_message "NO_HOMEBREW_ISSUES")"
        else
            echo "$(get_message "HOMEBREW"): $(get_message "NOT_INSTALLED")"
        fi

        echo -e "\n$(get_message "ISSUES_FOUND"):"
        find "${OUTPUT_DIR}/logs" -type f -exec grep -H "ERROR\|WARNING\|✗" {} \; | \
            sed 's/.*logs\///' | sed 's/\.log:/: /'

        echo -e "\n$(get_message "RECOMMENDATIONS"):"
        if [ -s "$ERROR_LOG" ]; then
            echo "$(get_message "CRITICAL_ISSUES"):"
            grep "ERROR" "$ERROR_LOG"
        else
            echo "$(get_message "NO_CRITICAL_ISSUES")"
        fi
    } > "$SUMMARY_TXT"
}
