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
    <title>Environment Check Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
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
        <h1>Environment Check Results</h1>
        <p>Generated on: $(date)</p>

        <div class="summary">
            <h2>Quick Summary</h2>
            <p>Total Checks: $(find "${OUTPUT_DIR}/logs" -type f -name "*.log" | wc -l)</p>
            <p>Errors: $(grep -r "ERROR" "${OUTPUT_DIR}/logs" | wc -l)</p>
            <p>Warnings: $(grep -r "WARNING" "${OUTPUT_DIR}/logs" | wc -l)</p>
        </div>

        <div class="section">
            <h2>Check Results:</h2>
            <table>
                <tr>
                    <th>Component</th>
                    <th>Status</th>
                    <th>Details</th>
                </tr>
EOF

    # Add entries for each log file
    for log_file in "${OUTPUT_DIR}"/logs/*.log; do
        if [ -f "$log_file" ]; then
            filename=$(basename "$log_file")
            component=$(echo "$filename" | sed -E 's/^[0-9]+_(.*)\.log$/\1/')

            if grep -q "ERROR" "$log_file" 2>/dev/null; then
                status="error"
                status_text="Failed"
            elif grep -q "WARNING\|✗" "$log_file" 2>/dev/null; then
                status="warning"
                status_text="Warning"
            else
                status="ok"
                status_text="Passed"
            fi

            cat >> "$INDEX_HTML" << EOF
                <tr>
                    <td>$component</td>
                    <td class="status-${status}">${status_text}</td>
                    <td><a href="logs/${filename}" class="log-link">View Details</a></td>
                </tr>
EOF
        fi
    done

    cat >> "$INDEX_HTML" << EOF
            </table>
        </div>

        <div class="section">
            <h2>Analysis Reports</h2>
            <ul>
                <li><a href="analysis/analysis_report.md" class="log-link">Full Analysis Report</a></li>
                <li><a href="analysis/statistics.json" class="log-link">Statistics</a></li>
                <li><a href="analysis/trends.md" class="log-link">Historical Trends</a></li>
                <li><a href="summary.txt" class="log-link">Summary Report</a></li>
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
        echo "Environment Check Summary"
        echo "Generated: $(date)"
        echo "----------------------------------------"

        echo -e "\nSystem Information:"
        grep "System Version" "$SYSTEM_LOG" 2>/dev/null || echo "System information not available"

        echo -e "\nKey Findings:"

        # Add shell information
        echo "Shell: $SHELL"

        # Add Python version
        if command -v python3 >/dev/null 2>&1; then
            python3 --version
        else
            echo "Python3 not installed"
        fi

        # Add Node.js version
        if command -v node >/dev/null 2>&1; then
            node --version
        else
            echo "Node.js not installed"
        fi

        # Add Homebrew status
        if command -v brew >/dev/null 2>&1; then
            echo "Homebrew: Installed"
            brew doctor 2>&1 | grep -i "error\|warning" || echo "No Homebrew issues found"
        else
            echo "Homebrew: Not installed"
        fi

        echo -e "\nIssues Found:"
        find "${OUTPUT_DIR}/logs" -type f -exec grep -H "ERROR\|WARNING\|✗" {} \; | \
            sed 's/.*logs\///' | sed 's/\.log:/: /'

        echo -e "\nRecommendations:"
        if [ -s "$ERROR_LOG" ]; then
            echo "Critical issues that need attention:"
            grep "ERROR" "$ERROR_LOG"
        else
            echo "No critical issues found."
        fi
    } > "$SUMMARY_TXT"
}
