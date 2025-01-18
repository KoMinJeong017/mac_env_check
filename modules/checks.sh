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

# Reset and show initial progress
reset_progress() {
    CURRENT_CHECK=0
    printf "\n%s\n" "Starting environment checks..."
}

# Show completion status
show_completion() {
    local total_errors=$(grep -c "ERROR" "$ERROR_LOG" 2>/dev/null || echo "0")
    local total_warnings=$(find "${OUTPUT_DIR}/logs" -type f -exec grep -l "WARNING\|✗" {} \; | wc -l)
    
    printf "\n%s\n" "Check completion status:"
    printf "${GREEN}✓ Completed ${TOTAL_CHECKS} checks${NC}\n"
    if [ $total_errors -gt 0 ]; then
        printf "${RED}✗ Found %d errors${NC}\n" "$total_errors"
    fi
    if [ $total_warnings -gt 0 ]; then
        printf "${YELLOW}! Found %d warnings${NC}\n" "$total_warnings"
    fi
    if [ $total_errors -eq 0 ] && [ $total_warnings -eq 0 ]; then
        printf "${GREEN}✓ No issues found${NC}\n"
    fi
}

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
    log_progress "System Information"
    {
        system_profiler SPSoftwareDataType | grep "System Version"
        system_profiler SPHardwareDataType | grep -E "Model Name|Processor|Memory"
    } >> "$SYSTEM_LOG"
}

# Shell Environment Check
check_shell() {
    log_progress "Shell Environment"
    {
        echo "Current Shell: $SHELL"
        check_file ~/.zshrc "$SHELL_LOG"
        check_file ~/.bashrc "$SHELL_LOG"
        check_file ~/.bash_profile "$SHELL_LOG"
        
        echo -e "\nShell Configurations:"
        for file in ~/.{zshrc,bashrc,bash_profile,profile}; do
            if [ -f "$file" ]; then
                echo "Content of $file:"
                grep -v "^#" "$file" | grep -v "^$"
            fi
        done
    } >> "$SHELL_LOG"
}

# PATH Configuration Check
check_path() {
    log_progress "PATH Configuration"
    {
        echo "PATH directories:"
        echo "$PATH" | tr ':' '\n' | while read -r line; do
            if [ -d "$line" ]; then
                echo "${GREEN}✓ $line${NC}"
            else
                echo "${RED}✗ $line (not found)${NC}"
            fi
        done
    } >> "$PATH_LOG"
}

# Homebrew Check
check_homebrew() {
    log_progress "Homebrew"
    if command -v brew >/dev/null 2>&1; then
        {
            echo "Homebrew is installed"
            echo "Homebrew version: $(brew --version)"
            echo -e "\nRunning brew doctor..."
            brew doctor 2>&1
            
            echo -e "\nInstalled packages:"
            brew list --versions
            
            echo -e "\nOutdated packages:"
            brew outdated
        } >> "$HOMEBREW_LOG"
    else
        log_error "Homebrew is not installed" >> "$HOMEBREW_LOG"
    fi
}

# Development Tools Check
check_dev_tools() {
    log_progress "Development Tools"
    local tools=(git make gcc python3 pip3 node npm java docker)
    for tool in "${tools[@]}"; do
        check_command "$tool" "$TOOLS_LOG"
    done
}

# Python Environment Check
check_python() {
    log_progress "Python Environment"
    {
        if command -v python3 >/dev/null 2>&1; then
            echo "Python installation:"
            which python3
            python3 --version
            
            if command -v pip3 >/dev/null 2>&1; then
                echo -e "\nInstalled pip packages:"
                pip3 list
                
                echo -e "\nChecking for outdated packages:"
                pip3 list --outdated
            fi
            
            # Check virtual environments
            if command -v pyenv >/dev/null 2>&1; then
                echo -e "\nPyenv versions:"
                pyenv versions
            fi
        else
            log_error "Python3 is not installed"
        fi
    } >> "$PYTHON_LOG"
}

# Node.js Environment Check
check_node() {
    log_progress "Node.js Environment"
    {
        if command -v node >/dev/null 2>&1; then
            echo "Node.js installation:"
            which node
            node --version
            
            if command -v npm >/dev/null 2>&1; then
                echo -e "\nGlobally installed npm packages:"
                npm list -g --depth=0
                
                echo -e "\nChecking for security vulnerabilities:"
                if [ -f "package-lock.json" ]; then
                    npm audit
                else
                    echo "Skipping npm audit (no package-lock.json found)"
                fi
            fi
        else
            log_error "Node.js is not installed"
        fi
    } >> "$NODE_LOG"
}

# Editor Configurations Check
check_editors() {
    log_progress "Editor Configurations"
    {
        # Check Vim configuration
        check_file ~/.vimrc "$EDITOR_LOG"
        check_directory ~/.vim "$EDITOR_LOG"
        
        # Check VS Code
        if [ -d "/Applications/Visual Studio Code.app" ]; then
            echo "${GREEN}✓ VS Code is installed${NC}"
            if command -v code >/dev/null 2>&1; then
                echo -e "\nVS Code extensions:"
                code --list-extensions
            fi
        else
            echo "${RED}✗ VS Code is not installed${NC}"
        fi
    } >> "$EDITOR_LOG"
}

# Git Configuration Check
check_git() {
    log_progress "Git Configuration"
    {
        if command -v git >/dev/null 2>&1; then
            echo "Git configuration:"
            git config --list
        else
            log_error "Git is not installed"
        fi
    } >> "$GIT_LOG"
}

# Disk Space Check
check_disk() {
    log_progress "Disk Space"
    {
        echo "Disk space usage:"
        df -h /
        
        echo -e "\nLarge files in home directory:"
        find ~ -type f -size +100M -exec ls -lh {} \; 2>/dev/null
    } >> "$DISK_LOG"
}

# Network Configuration Check
check_network() {
    log_progress "Network Configuration"
    {
        echo "Network interfaces:"
        ifconfig | grep -A 4 "^[a-zA-Z]"
        
        echo -e "\nDNS configuration:"
        cat /etc/resolv.conf
        
        echo -e "\nActive network ports:"
        lsof -i -P -n | grep LISTEN
    } >> "$NETWORK_LOG"
}

# Security Check
check_security() {
    log_progress "Security Settings"
    {
        # Check FileVault
        if fdesetup status | grep -q "FileVault is On"; then
            echo "${GREEN}✓ FileVault is enabled${NC}"
        else
            echo "${RED}✗ FileVault is not enabled${NC}"
        fi
        
        # Check Firewall
        if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q "enabled"; then
            echo "${GREEN}✓ Firewall is enabled${NC}"
        else
            echo "${RED}✗ Firewall is not enabled${NC}"
        fi
        
        # Check SIP Status
        if csrutil status | grep -q "enabled"; then
            echo "${GREEN}✓ System Integrity Protection is enabled${NC}"
        else
            echo "${RED}✗ System Integrity Protection is disabled${NC}"
        fi
    } >> "$SECURITY_LOG"
}

# Dependencies Check
check_dependencies() {
    log_progress "Dependencies"
    {
        echo "Checking package dependencies..."
        
        if command -v brew >/dev/null 2>&1; then
            echo -e "\nHomebrew dependencies:"
            brew deps --installed
        fi
        
        if command -v pip3 >/dev/null 2>&1; then
            echo -e "\nPython package dependencies:"
            pip3 check
        fi
        
        if command -v npm >/dev/null 2>&1; then
            echo -e "\nNode.js package dependencies:"
            npm ls -g --depth=0
        fi
    } >> "$DEPS_LOG"
}

# Configuration Conflicts Check
check_conflicts() {
    log_progress "Configuration Conflicts"
    {
        echo "Checking for PATH duplicates:"
        echo "$PATH" | tr ':' '\n' | sort | uniq -d
        
        echo -e "\nChecking for alias conflicts:"
        for file in ~/.{bashrc,zshrc,bash_aliases,zsh_aliases}; do
            if [ -f "$file" ]; then
                echo "Checking $file for duplicate aliases:"
                grep "^alias" "$file" | sort | uniq -d
            fi
        done
        
        if command -v java >/dev/null 2>&1; then
            echo -e "\nChecking Java versions:"
            /usr/libexec/java_home -V 2>&1
        fi
    } >> "$CONFLICTS_LOG"
}

# Performance Check
check_performance() {
    log_progress "System Performance"
    {
        echo "Top CPU-consuming processes:"
        ps aux | head -1
        ps aux | sort -nr -k 3 | head -5
        
        echo -e "\nTop Memory-consuming processes:"
        ps aux | head -1
        ps aux | sort -nr -k 4 | head -5
        
        echo -e "\nSystem load averages:"
        uptime
        
        if command -v vm_stat >/dev/null 2>&1; then
            echo -e "\nVirtual memory statistics:"
            vm_stat
        fi
    } >> "$PERFORMANCE_LOG"
}
