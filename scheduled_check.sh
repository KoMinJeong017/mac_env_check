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
# File Name:    scheduled_check.sh
# Author:       Ko Minjeong
# mail:         kominjeong017@gmail.com
# Created Time: Sat 18 Jan 07:48:43 2025
#########################################################################
#!/bin/bash

#!/bin/bash

# 设置日志文件
LOG_FILE=~/.env_check_history/scheduled_check.log

# 记录运行时间
echo "Running scheduled check at $(date)" >> "$LOG_FILE"

# 切换到脚本目录
cd ~/Scripts/env_check

# 运行环境检查，保留90天的历史记录
./check_env_new.sh -k 90

# 记录完成状态
echo "Check completed at $(date)" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
