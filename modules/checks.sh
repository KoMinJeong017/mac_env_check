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
# File Name:    checks.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Fri 17 Jan 14:38:55 2025
#########################################################################
#!/bin/bash

#!/bin/bash

# Import language module
source "${SCRIPT_DIR}/modules/language.sh"

# Run all system checks
run_all_checks() {
    reset_progress
    
    check_system
    check_shell
    check_path
    check_homebrew
    check_dev_tools
    check_python
    check_node
    check_editors
    check_git
    check_disk
    check_network
    check_security
    check_dependencies
    check_conflicts
    check_performance
    
    show_completion
}

# System Information Check
check_system() {
    log_progress "$(get_message "system_info")"
    {
        system_profiler SPSoftwareDataType | grep "System Version"
        system_profiler SPHardwareDataType | grep -E "Model Name|Processor|Memory"
    } >> "$SYSTEM_LOG"
}

# Shell Environment Check
check_shell() {
    log_progress "$(get_message "shell_env")"
    {
        echo "$(get_message "CURRENT_SHELL"): $SHELL"
        check_file ~/.zshrc "$SHELL_LOG"
        check_file ~/.bashrc "$SHELL_LOG"
        check_file ~/.bash_profile "$SHELL_LOG"
        
        echo -e "\n$(get_message "SHELL_CONFIGS"):"
        for file in ~/.{zshrc,bashrc,bash_profile,profile}; do
            if [ -f "$file" ]; then
                echo "$(get_message "CONTENT_OF") $file:"
                grep -v "^#" "$file" | grep -v "^$"
            fi
        done
    } >> "$SHELL_LOG"
}

# PATH Configuration Check
check_path() {
    log_progress "$(get_message "path_config")"
    {
        echo "$(get_message "PATH_DIRS"):"
        echo "$PATH" | tr ':' '\n' | while read -r line; do
            if [ -d "$line" ]; then
                echo "${GREEN}✓ $line${NC}"
            else
                echo "${RED}✗ $line ($(get_message "NOT_FOUND"))${NC}"
            fi
        done
    } >> "$PATH_LOG"
}

# Homebrew Check
check_homebrew() {
    log_progress "$(get_message "homebrew")"
    if command -v brew >/dev/null 2>&1; then
        {
            echo "$(get_message "HOMEBREW_INSTALLED")"
            echo "$(get_message "HOMEBREW_VERSION"): $(brew --version)"
            
            echo -e "\n$(get_message "RUNNING_BREW_DOCTOR")..."
            brew doctor 2>&1
            
            echo -e "\n$(get_message "INSTALLED_PACKAGES"):"
            brew list --versions
            
            echo -e "\n$(get_message "OUTDATED_PACKAGES"):"
            brew outdated
        } >> "$HOMEBREW_LOG"
    else
        log_error "$(get_message "HOMEBREW_NOT_INSTALLED")" >> "$HOMEBREW_LOG"
    fi
}

# Development Tools Check
check_dev_tools() {
    log_progress "$(get_message "dev_tools")"
    local tools=(git make gcc python3 pip3 node npm java docker)
    for tool in "${tools[@]}"; do
        check_command "$tool" "$TOOLS_LOG"
    done
}

# Python Environment Check
check_python() {
    log_progress "$(get_message "python_env")"
    {
        if command -v python3 >/dev/null 2>&1; then
            echo "$(get_message "PYTHON_INSTALL"):"
            which python3
            python3 --version
            
            if command -v pip3 >/dev/null 2>&1; then
                echo -e "\n$(get_message "INSTALLED_PIP_PACKAGES"):"
                pip3 list
                
                echo -e "\n$(get_message "CHECKING_OUTDATED"):"
                pip3 list --outdated
            fi
            
            # Check virtual environments
            if command -v pyenv >/dev/null 2>&1; then
                echo -e "\n$(get_message "PYENV_VERSIONS"):"
                pyenv versions
            fi
        else
            log_error "$(get_message "PYTHON_NOT_INSTALLED")"
        fi
    } >> "$PYTHON_LOG"
}

# Node.js Environment Check
check_node() {
    log_progress "$(get_message "node_env")"
    {
        if command -v node >/dev/null 2>&1; then
            echo "$(get_message "NODE_INSTALL"):"
            which node
            node --version
            
            if command -v npm >/dev/null 2>&1; then
                echo -e "\n$(get_message "GLOBAL_NPM_PACKAGES"):"
                npm list -g --depth=0
                
                echo -e "\n$(get_message "CHECKING_VULNERABILITIES"):"
                if [ -f "package-lock.json" ]; then
                    npm audit
                else
                    echo "$(get_message "SKIP_NPM_AUDIT")"
                fi
            fi
        else
            log_error "$(get_message "NODE_NOT_INSTALLED")"
        fi
    } >> "$NODE_LOG"
}

# Editor Configurations Check
check_editors() {
    log_progress "$(get_message "editor_config")"
    {
        check_file ~/.vimrc "$EDITOR_LOG"
        check_directory ~/.vim "$EDITOR_LOG"
        
        if [ -d "/Applications/Visual Studio Code.app" ]; then
            echo "${GREEN}✓ $(get_message "VSCODE_INSTALLED")${NC}"
            if command -v code >/dev/null 2>&1; then
                echo -e "\n$(get_message "VSCODE_EXTENSIONS"):"
                code --list-extensions
            fi
        else
            echo "${RED}✗ $(get_message "VSCODE_NOT_INSTALLED")${NC}"
        fi
    } >> "$EDITOR_LOG"
}

# Git Configuration Check
check_git() {
    log_progress "$(get_message "git_config")"
    {
        if command -v git >/dev/null 2>&1; then
            echo "$(get_message "GIT_CONFIG"):"
            git config --list
        else
            log_error "$(get_message "GIT_NOT_INSTALLED")"
        fi
    } >> "$GIT_LOG"
}

# Disk Space Check
check_disk() {
    log_progress "$(get_message "disk_space")"
    {
        echo "$(get_message "DISK_USAGE"):"
        df -h /
        
        echo -e "\n$(get_message "LARGE_FILES"):"
        find ~ -type f -size +100M -exec ls -lh {} \; 2>/dev/null
    } >> "$DISK_LOG"
}

# Network Configuration Check
check_network() {
    log_progress "$(get_message "network")"
    {
        echo "$(get_message "NETWORK_INTERFACES"):"
        ifconfig | grep -A 4 "^[a-zA-Z]"
        
        echo -e "\n$(get_message "DNS_CONFIG"):"
        cat /etc/resolv.conf
        
        echo -e "\n$(get_message "ACTIVE_PORTS"):"
        lsof -i -P -n | grep LISTEN
    } >> "$NETWORK_LOG"
}

# Security Check
check_security() {
    log_progress "$(get_message "security")"
    {
        # Check FileVault
        if fdesetup status | grep -q "FileVault is On"; then
            echo "${GREEN}✓ $(get_message "FILEVAULT_ENABLED")${NC}"
        else
            echo "${RED}✗ $(get_message "FILEVAULT_DISABLED")${NC}"
        fi
        
        # Check Firewall
        if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q "enabled"; then
            echo "${GREEN}✓ $(get_message "FIREWALL_ENABLED")${NC}"
        else
            echo "${RED}✗ $(get_message "FIREWALL_DISABLED")${NC}"
        fi
        
        # Check SIP Status
        if csrutil status | grep -q "enabled"; then
            echo "${GREEN}✓ $(get_message "SIP_ENABLED")${NC}"
        else
            echo "${RED}✗ $(get_message "SIP_DISABLED")${NC}"
        fi
    } >> "$SECURITY_LOG"
}

# Dependencies Check
check_dependencies() {
    log_progress "$(get_message "dependencies")"
    {
        echo "$(get_message "CHECKING_DEPENDENCIES")..."
        
        if command -v brew >/dev/null 2>&1; then
            echo -e "\n$(get_message "HOMEBREW_DEPS"):"
            brew deps --installed
        fi
        
        if command -v pip3 >/dev/null 2>&1; then
            echo -e "\n$(get_message "PYTHON_DEPS"):"
            pip3 check
        fi
        
        if command -v npm >/dev/null 2>&1; then
            echo -e "\n$(get_message "NODE_DEPS"):"
            npm ls -g --depth=0
        fi
    } >> "$DEPS_LOG"
}

# Configuration Conflicts Check
check_conflicts() {
    log_progress "$(get_message "conflicts")"
    {
        echo "$(get_message "CHECKING_PATH_DUPLICATES"):"
        echo "$PATH" | tr ':' '\n' | sort | uniq -d
        
        echo -e "\n$(get_message "CHECKING_ALIAS_CONFLICTS"):"
        for file in ~/.{bashrc,zshrc,bash_aliases,zsh_aliases}; do
            if [ -f "$file" ]; then
                echo "$(get_message "CHECKING_FILE_ALIASES") $file:"
                grep "^alias" "$file" | sort | uniq -d
            fi
        done
        
        if command -v java >/dev/null 2>&1; then
            echo -e "\n$(get_message "CHECKING_JAVA_VERSIONS"):"
            /usr/libexec/java_home -V 2>&1
        fi
    } >> "$CONFLICTS_LOG"
}

# Performance Check
check_performance() {
    log_progress "$(get_message "performance")"
    {
        echo "$(get_message "TOP_CPU_PROCESSES"):"
        ps aux | head -1
        ps aux | sort -nr -k 3 | head -5
        
        echo -e "\n$(get_message "TOP_MEMORY_PROCESSES"):"
        ps aux | head -1
        ps aux | sort -nr -k 4 | head -5
        
        echo -e "\n$(get_message "SYSTEM_LOAD"):"
        uptime
        
        if command -v vm_stat >/dev/null 2>&1; then
            echo -e "\n$(get_message "VM_STATS"):"
            vm_stat
        fi
    } >> "$PERFORMANCE_LOG"
}
