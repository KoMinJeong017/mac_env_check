# MacOS Environment Check Tool

## Overview
This tool provides comprehensive environment checking and analysis for MacOS development setups. It helps identify configuration issues, analyzes dependencies, and maintains historical records of system health. The tool is modularly designed for better maintenance and extensibility.

## Directory Structure

```
mac_env_check/                      # Project root
├── check_env_new.sh                # Main check script
├── check_history.sh                # History management utility
├── scheduled_check.sh              # Automated check scheduler
├── modules/                        # Core modules
│   ├── config.sh                   # Configuration settings
│   ├── language.sh                 # Language localization
│   ├── logger.sh                   # Logging utilities
│   ├── checks.sh                   # System check implementations
│   ├── reporter.sh                 # Report generation
│   └── analyzer.sh                 # Analysis functions
└── .env_check_history/            # History storage (auto-generated)
    ├── scheduled_check.log         # Scheduled checks log
    ├── active_checks/             # Recent check results
    │   └── mac_env_check_YYYYMMDD/ # Check result directories
    └── archives/                  # Compressed old results
        └── mac_env_check_YYYYMMDD.tar.gz
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
#### Check Output Structure
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

# Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mac_env_check.git
cd mac_env_check
```

2. Set up the directory structure:
```bash
# Create history directories
mkdir -p .env_check_history/{active_checks,archives}
```

3. Set execution permissions:
```bash
chmod +x check_env_new.sh check_history.sh scheduled_check.sh
chmod +x modules/*.sh
```

4. Install dependencies:
```bash
brew install jq  # Required for JSON processing
```

## Language Settings

The tool supports multilingual output. You can switch between languages using:

```bash
# Initialize language module
source ~/Scripts/env_check/modules/language.sh

# Switch to Chinese
set_language zh

# Switch to English
set_language en
```

Language settings affect:
- All check process outputs
- Generated reports
- Error and warning messages
- HTML report interface

The language preference is stored in ~/.env_check_config/language and persists between sessions.

## Usage

### Basic Operations
```bash
# Run environment check
cd ~/Scripts/env_check
./check_env_new.sh

# View check history
./check_history.sh

# Run analysis only
./check_env_new.sh -a
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

### Automated Checks

#### Setting Up Scheduled Checks
```bash
# Edit crontab
crontab -e

# Monthly check (1st of each month at 9 AM)
0 9 1 * * ~/Scripts/env_check/scheduled_check.sh

# Weekly check (Every Monday at 9 AM)
0 9 * * 1 ~/Scripts/env_check/scheduled_check.sh
```

#### Managing Scheduled Checks
```bash
# View current schedule
crontab -l

# Remove scheduled checks
crontab -l | grep -v "scheduled_check.sh" | crontab -
```

### History Management

#### Viewing History
```bash
# View history summary
./check_history.sh

# View specific check result
ls -l ~/.env_check_history/active_checks/

# View archived checks
ls -l ~/.env_check_history/archives/
```

#### Managing History
```bash
# Clean old archives (older than specified days)
find ~/.env_check_history/archives -name "*.tar.gz" -mtime +90 -delete

# Manually archive a check result
tar czf ~/.env_check_history/archives/check_result.tar.gz \
    ~/.env_check_history/active_checks/check_result/
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
- Configurable retention period (default: 30 days)
- Automatic archiving of old logs
- Compressed storage for space efficiency

### Archive Management
- Archives stored in ~/.env_check_history/archives/
- Compressed using tar.gz format
- Indexed for easy retrieval

### History Tracking
- Maintains system state changes over time
- Tracks error and warning trends
- Records performance metrics history
- Provides component status evolution

## Troubleshooting

### Common Issues
1. Permission Denied
```bash
chmod +x ~/Scripts/env_check/*.sh
chmod +x ~/Scripts/env_check/modules/*.sh
```

2. Missing Dependencies
```bash
brew install jq  # Required for JSON processing
```

3. Module Not Found
```bash
# Verify module directory structure
ls -l ~/Scripts/env_check/modules/
```

4. History Access Issues
```bash
# Check history directory permissions
ls -la ~/.env_check_history/
# Fix permissions if needed
chmod -R 755 ~/.env_check_history/
```

5. Scheduled Check Issues
```bash
# Check crontab entries
crontab -l
# Verify script permissions
ls -l ~/Scripts/env_check/scheduled_check.sh
# Check scheduled check log
tail ~/.env_check_history/scheduled_check.log
```

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.
