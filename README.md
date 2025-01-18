# MacOS Environment Check Tool

## Overview
This tool provides comprehensive environment checking and analysis for MacOS development setups. It helps identify configuration issues, analyzes dependencies, and maintains historical records of system health. The tool is modularly designed for better maintenance and extensibility.

## Tool Structure
```
mac_env_check/
├── check_env_new.sh          # Main script
└── modules/
    ├── config.sh            # Configuration module
    ├── logger.sh            # Logging utilities
    ├── checks.sh            # System check implementations
    ├── reporter.sh          # Report generation
    └── analyzer.sh          # Analysis functions
```

## Features

### 1. System Checks
- System information verification
- Shell environment analysis
- PATH configuration validation
- Development tools check
- Security configuration audit
- Performance monitoring

### 2. Package Management
- Homebrew package analysis
- Python package dependency check
- Node.js package audit
- Version compatibility verification
- Dependency conflict detection

### 3. Configuration Analysis
- Shell configuration validation
- Editor setup verification
- Git configuration check
- Network settings audit
- Security settings verification

### 4. Log Management
#### Output Directory Structure
```
{PREFIX}_{TIMESTAMP}_{SUFFIX}/
├── logs/
│   ├── 01_system_info.log      # System information
│   ├── 02_shell_env.log        # Shell environment
│   ├── 03_path_config.log      # PATH configuration
│   ├── 04_homebrew.log         # Homebrew packages
│   ├── 05_dev_tools.log        # Development tools
│   ├── 06_python_env.log       # Python environment
│   ├── 07_node_env.log         # Node.js environment
│   ├── 08_editor_config.log    # Editor configuration
│   ├── 09_git_config.log       # Git configuration
│   ├── 10_disk_space.log       # Disk space usage
│   ├── 11_network.log          # Network settings
│   ├── 12_security.log         # Security checks
│   ├── 13_dependencies.log     # Dependency analysis
│   ├── 14_conflicts.log        # Conflict detection
│   ├── 15_performance.log      # Performance metrics
│   └── errors.log              # Error records
├── analysis/
│   ├── analysis_report.md      # Detailed analysis
│   ├── statistics.json         # Statistical data
│   └── trends.md              # Historical trends
├── index.html                 # Interactive report
└── summary.txt               # Executive summary
```

### 5. Analysis Tools
- Error pattern analysis
- Warning category statistics
- Configuration issue tracking
- Historical trend analysis
- Component status overview
- Performance metrics tracking

## Installation

1. Set up the directory structure:
```bash
# Create script directory
mkdir -p ~/Scripts/env_check

# Clone the repository
git clone https://github.com/yourusername/mac_env_check.git
cd mac_env_check

# Copy files to script directory
cp -r {check_env_new.sh,modules} ~/Scripts/env_check/

# Create history directory
mkdir -p ~/.env_check_history
```

2. Set execution permissions:
```bash
chmod +x ~/Scripts/env_check/check_env_new.sh
chmod +x ~/Scripts/env_check/modules/*.sh
```

3. Set up scheduled checks (optional):
```bash
# Save the scheduled check script
cat > ~/Scripts/env_check/scheduled_check.sh << 'EOF'
#!/bin/bash
LOG_FILE=~/.env_check_history/scheduled_check.log
echo "Running scheduled check at $(date)" >> "$LOG_FILE"
cd ~/Scripts/env_check
./check_env_new.sh -k 90
echo "Check completed at $(date)" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
EOF

# Set execution permission
chmod +x ~/Scripts/env_check/scheduled_check.sh

# Add to crontab (runs at 9 AM on the 1st of each month)
(crontab -l 2>/dev/null; echo "0 9 1 * * ~/Scripts/env_check/scheduled_check.sh") | crontab -
```

## Usage

### Basic Usage
```bash
cd ~/Scripts/env_check
./check_env_new.sh
```

### Advanced Options
```bash
Options:
  -n, --name PREFIX     Set custom prefix for log files
  -s, --suffix SUFFIX   Set custom suffix for log files
  -k, --keep DAYS      Keep logs for specified number of days (default: 30)
  -a, --analyze-only   Only analyze existing logs without running checks
  -h, --help           Show this help message
```

### Examples
1. Custom naming:
```bash
./check_env_new.sh -n myproject -s prod
# Creates: myproject_20250117_143000_prod/
```

2. Analyze existing logs:
```bash
./check_env_new.sh -a
```

3. Set retention period:
```bash
./check_env_new.sh -k 60  # Keep logs for 60 days
```

### Scheduled Checks
You can set up automatic monthly checks with:
```bash
# Edit crontab to modify schedule
crontab -e

# Example entries:
# Run monthly (1st of each month at 9 AM)
0 9 1 * * ~/Scripts/env_check/scheduled_check.sh

# Run weekly (Every Monday at 9 AM)
0 9 * * 1 ~/Scripts/env_check/scheduled_check.sh
```

### History Management
View check history using the included utility script:
```bash
# Save the history check script
cat > ~/Scripts/env_check/check_history.sh << 'EOF'
#!/bin/bash
HISTORY_DIR=~/.env_check_history
echo "Environment Check History Summary"
echo "--------------------------------"
echo "Recent Checks:"
[ -f "$HISTORY_DIR/scheduled_check.log" ] && tail -n 10 "$HISTORY_DIR/scheduled_check.log"
echo -e "\nArchived Reports:"
find "$HISTORY_DIR" -name "mac_env_check_*" -type d -o -name "mac_env_check_*.tar.gz" | \
    sort -r | \
    while read -r file; do
        if [ -d "$file" ]; then
            echo "$(basename "$file") (active)"
        else
            echo "$(basename "$file") (archived)"
        fi
    done
echo -e "\nStorage Usage:"
du -sh "$HISTORY_DIR"
EOF

# Set execution permission
chmod +x ~/Scripts/env_check/check_history.sh

# View history
~/Scripts/env_check/check_history.sh
```

## Output Reports

### 1. Interactive HTML Report (index.html)
- Navigable interface for all check results
- Color-coded status indicators
- Quick access to detailed logs
- Real-time summary dashboard

### 2. Summary Report (summary.txt)
- Executive summary of all checks
- Critical issues and warnings
- Component status overview
- Recommended actions

### 3. Analysis Reports
- Comprehensive markdown analysis report
- JSON-formatted statistics
- Historical trend analysis
- Performance metrics over time

## Log Management

### Automatic Log Rotation
- Configurable retention period (default: 30 days, recommended: 90 days)
- Automatic archiving of old logs to ~/.env_check_history/
- Compressed storage for space efficiency
- Automated monthly checks through cron jobs

### Archive Management
- Archives stored in ~/.env_check_history/
- Compressed using tar.gz format
- Indexed for easy retrieval
- Includes scheduled check logs and historical trends

### History Tracking
- Maintains system state changes over time
- Tracks error and warning trends
- Records performance metrics history
- Provides component status evolution

## Troubleshooting

### Common Issues
1. Permission Denied
```bash
chmod +x check_env_new.sh
chmod +x modules/*.sh
```

2. Missing Dependencies
```bash
brew install jq  # Required for JSON processing
```

3. Module Not Found
```bash
# Ensure all module files exist in the modules directory
ls -l modules/
```

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.
