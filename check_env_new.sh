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
# File Name:    check_env_new.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Fri 17 Jan 14:37:19 2025
#########################################################################
#!/bin/bash

# Import modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/modules/config.sh"
source "${SCRIPT_DIR}/modules/logger.sh"
source "${SCRIPT_DIR}/modules/checks.sh"
source "${SCRIPT_DIR}/modules/reporter.sh"
source "${SCRIPT_DIR}/modules/analyzer.sh"

# Script version
VERSION="2.0.0"

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                NAME_PREFIX="$2"
                shift 2
                ;;
            -s|--suffix)
                NAME_SUFFIX="$2"
                shift 2
                ;;
            -k|--keep)
                KEEP_DAYS="$2"
                shift 2
                ;;
            -a|--analyze-only)
                ANALYZE_ONLY=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Help message
show_help() {
    cat << EOF
MacOS Environment Check Tool v${VERSION}

Usage: $(basename "$0") [OPTIONS]

Options:
  -n, --name PREFIX     Set custom prefix for log files
  -s, --suffix SUFFIX   Set custom suffix for log files
  -k, --keep DAYS      Keep logs for specified number of days (default: 30)
  -a, --analyze-only   Only analyze existing logs without running checks
  -h, --help           Show this help message
EOF
}

# Main execution
main() {
    parse_arguments "$@"
    init_config
    setup_logging

    echo "Starting MacBook environment check..."
    echo "Results will be saved in: ${OUTPUT_DIR}"

    if [ "$ANALYZE_ONLY" = true ]; then
        echo "Analyzing existing logs..."
        run_analysis
        echo -e "${GREEN}Analysis completed!${NC}"
        exit 0
    fi

    # Run all checks
    run_all_checks

    # Generate reports
    generate_all_reports

    # Archive old logs
    archive_old_logs

    echo -e "\n${GREEN}Environment check completed!${NC}"
    echo "Results are available in: ${OUTPUT_DIR}"
    echo "View the report by opening: ${OUTPUT_DIR}/index.html"

    if [ $FAILED_CHECKS -gt 0 ]; then
        echo -e "\n${RED}Warning: $FAILED_CHECKS checks failed. Check the logs for details.${NC}"
        exit 1
    fi
}

# Execute main with all arguments
main "$@"
