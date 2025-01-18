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
source "${SCRIPT_DIR}/modules/language.sh"

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
                echo "$(get_message "UNKNOWN_OPTION"): $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Help message
show_help() {
    echo "$(get_message "TOOL_TITLE") v${VERSION}"
    echo
    echo "$(get_message "USAGE"): $(basename "$0") [$(get_message "OPTIONS")]"
    echo
    echo "$(get_message "OPTIONS_TITLE"):"
    echo "  -n, --name $(get_message "PREFIX")     $(get_message "HELP_PREFIX")"
    echo "  -s, --suffix $(get_message "SUFFIX")   $(get_message "HELP_SUFFIX")"
    echo "  -k, --keep $(get_message "DAYS")      $(get_message "HELP_KEEP")"
    echo "  -a, --analyze-only   $(get_message "HELP_ANALYZE")"
    echo "  -h, --help           $(get_message "HELP_HELP")"
}

# Main execution
main() {
    parse_arguments "$@"
    init_config
    setup_logging

    echo "$(get_message "START_CHECK")"
    echo "$(get_message "RESULTS_PATH"): ${OUTPUT_DIR}"

    if [ "$ANALYZE_ONLY" = true ]; then
        echo "$(get_message "ANALYZING_LOGS")"
        run_analysis
        echo -e "${GREEN}$(get_message "ANALYSIS_COMPLETED")${NC}"
        exit 0
    fi

    # Run all checks
    run_all_checks

    # Generate reports
    generate_all_reports

    # Archive old logs
    archive_old_logs

    echo -e "\n${GREEN}$(get_message "ENV_CHECK_COMPLETED")${NC}"
    echo "$(get_message "RESULTS_AVAILABLE"): ${OUTPUT_DIR}"
    echo "$(get_message "VIEW_REPORT"): ${OUTPUT_DIR}/index.html"

    if [ $FAILED_CHECKS -gt 0 ]; then
        echo -e "\n${RED}$(get_message "WARNING_CHECKS_FAILED") $FAILED_CHECKS $(get_message "CHECKS_FAILED_DETAILS")${NC}"
        exit 1
    fi
}

# Execute main with all arguments
main "$@"
