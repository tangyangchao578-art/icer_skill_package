---
name: eda-scripting
description: EDA工具脚本开发技能 - TCL/Python/Makefile 自动化流程最佳实践
description.zh: EDA工具脚本开发技能 - TCL/Python/Makefile 自动化流程最佳实践
origin: ICER
categories: tools
---

# EDA 工具脚本开发技能

当用户需要开发 EDA 工具自动化流程脚本时，启用此技能。涵盖 TCL 流程脚本、Python 结果分析、Makefile 流程管理。

## When to Activate

- 开发综合自动化脚本
- 开发布局布线流程脚本
- 开发仿真回归脚本
- 开发结果分析汇总脚本
- 开发全流程自动化

---

## 行业经验数值

### 脚本开发时间估算

| 脚本类型 | 代码行数 | 开发时间 | 测试时间 |
|----------|----------|----------|----------|
| 综合脚本 | 200-500 行 | 1-2 天 | 1 天 |
| 布局布线脚本 | 500-1000 行 | 2-3 天 | 2 天 |
| 仿真脚本 | 100-200 行 | 0.5 天 | 0.5 天 |
| 结果分析脚本 | 100-300 行 | 1 天 | 0.5 天 |
| Makefile | 50-200 行 | 0.5 天 | 0.5 天 |

### 脚本质量标准

| 指标 | 标准 | 说明 |
|------|------|------|
| 错误检查覆盖率 | 100% | 所有步骤都有错误检查 |
| 日志完整性 | 100% | 所有关键步骤都有日志 |
| 注释覆盖率 | > 20% | 关键代码有注释 |
| 参数化程度 | > 80% | 配置通过参数传入 |

---

## 故障诊断框架

### 症状1：脚本运行失败

**诊断步骤：**

```
1. 检查日志文件
2. 确认失败步骤
3. 分析错误信息
4. 定位根本原因
```

**常见错误分类：**

| 错误类型 | 诊断特征 | 解决方案 |
|----------|----------|----------|
| License 失败 | "License checkout failed" | 检查 license 配置 |
| 文件不存在 | "Cannot find file" | 检查文件路径 |
| 内存不足 | "Out of memory" | 增加内存或减少并行度 |
| 语法错误 | "Syntax error" | 检查脚本语法 |
| 超时 | "Timeout" | 增加超时时间 |

### 症状2：结果不符合预期

**诊断步骤：**

```
1. 对比预期结果
2. 检查输入文件
3. 检查约束文件
4. 检查脚本逻辑
```

**根本原因定位：**

| 根本原因 | 诊断特征 | 解决方案 |
|----------|----------|----------|
| 约束错误 | 时序/面积异常 | 检查 SDC 文件 |
| 输入错误 | 结果完全错误 | 检查输入文件 |
| 参数错误 | 结果部分错误 | 检查参数传递 |
| 版本不兼容 | 新版本结果不同 | 检查工具版本 |

---

## 步骤 1：需求分析

### 1.1 明确脚本目标

**做什么：** 确定脚本要实现的功能。

**怎么做：**
1. 明确工具名称（Design Compiler、IC Compiler、PrimeTime 等）
2. 明确流程阶段（综合、布局、布线、时序分析等）
3. 明确输入输出
4. 明确约束条件

**输出：** 脚本需求表

| 需求项 | 内容 |
|--------|------|
| 工具 | Design Compiler |
| 流程阶段 | 综合 |
| 输入 | RTL 文件、SDC 约束、工艺库 |
| 输出 | 网表、SDC、报告 |
| 约束 | 时序、面积、功耗 |
| 运行时间 | < 4 小时 |

### 1.2 确定脚本结构

**做什么：** 设计脚本的整体结构。

**脚本结构模板：**

```
脚本结构：
├── 配置区（变量定义）
├── 初始化区（创建目录、检查环境）
├── 主流程区（读取设计、综合、优化）
├── 报告区（生成报告）
├── 输出区（保存结果）
└── 清理区（可选）
```

### 1.3 确定参数化需求

**做什么：** 确定哪些参数需要可配置。

| 参数类型 | 参数化示例 |
|----------|------------|
| 设计相关 | TOP 模块名、文件列表 |
| 工艺相关 | 工艺库路径、操作条件 |
| 约束相关 | 时钟频率、面积目标 |
| 输出相关 | 输出目录、报告目录 |

---

## 步骤 2：TCL 脚本开发

### 2.1 编写配置区

**做什么：** 定义所有配置变量。

```tcl
# #################################################
# 设计配置
# #################################################

# ---------- 基本配置 ----------
set DESIGN             "async_fifo"      # 设计名称
set TOP                "async_fifo"      # 顶层模块
set OUTPUT_DIR         "./output"        # 输出目录
set REPORTS_DIR        "./reports"       # 报告目录
set LOG_DIR            "./logs"          # 日志目录

# ---------- 工艺库配置 ----------
# 从环境变量获取，不要硬编码
set STD_CELL_LIBRARY   $env(STD_CELL_LIBRARY)
set TARGET_LIBRARY     $env(TARGET_LIBRARY)
set LINK_LIBRARY       $env(LINK_LIBRARY)

# ---------- 约束配置 ----------
set CLOCK_NAME         "clk"
set CLOCK_PERIOD       10.0              # ns
set INPUT_DELAY        2.0               # ns
set OUTPUT_DELAY       2.0               # ns

# ---------- 优化目标 ----------
set OPTIMIZATION_GOAL  "timing"          # timing, area, power
set MAX_AREA           0                 # 0 表示无限制
```

### 2.2 编写初始化区

**做什么：** 创建目录、检查环境、设置工具选项。

```tcl
# #################################################
# 初始化
# #################################################

# ---------- 创建输出目录 ----------
file mkdir $OUTPUT_DIR
file mkdir $REPORTS_DIR
file mkdir $LOG_DIR

# ---------- 检查环境变量 ----------
if {![info exists env(STD_CELL_LIBRARY)]} {
    error "ERROR: STD_CELL_LIBRARY not set"
    exit 1
}

# ---------- 设置库文件 ----------
set_app_var target_library $TARGET_LIBRARY
set_app_var link_library   $LINK_LIBRARY
set_app_var search_path    [concat $search_path $STD_CELL_LIBRARY]

puts "✓ 初始化完成"
```

### 2.3 编写主流程区

**做什么：** 实现主要功能逻辑。

```tcl
# #################################################
# 主流程
# #################################################

# ---------- Step 1: 读取设计 ----------
puts "========================================"
puts "Step 1: Reading RTL design..."
puts "========================================"

read_verilog {
    ../src/async_fifo.sv
    ../src/sync_two_stage.sv
}

hierarchy -top $TOP

# ---------- 检查错误 ----------
if {![current_design]} {
    error "ERROR: Failed to read design"
    exit 1
}
puts "✓ 设计读取完成"

# ---------- Step 2: 读取约束 ----------
puts "========================================"
puts "Step 2: Reading constraints..."
puts "========================================"

read_sdc ../constraints/${TOP}.sdc
puts "✓ 约束读取完成"

# ---------- Step 3: 综合 ----------
puts "========================================"
puts "Step 3: Synthesis..."
puts "========================================"

compile_ultra
puts "✓ 综合完成"

# ---------- Step 4: 生成报告 ----------
puts "========================================"
puts "Step 4: Generating reports..."
puts "========================================"

report_area > $REPORTS_DIR/${TOP}.area.rpt
report_qor  > $REPORTS_DIR/${TOP}.qor.rpt
puts "✓ 报告生成完成"

# ---------- Step 5: 输出结果 ----------
puts "========================================"
puts "Step 5: Writing output..."
puts "========================================"

write_verilog -hierarchy -output $OUTPUT_DIR/${TOP}.netlist.v
write_sdc                -output $OUTPUT_DIR/${TOP}.sdc
puts "✓ 结果输出完成"

puts ""
puts "========================================"
puts "✅ 全部完成！"
puts "========================================"
```

### 2.4 TCL 编码准则

✅ **推荐：**
- 变量使用 `snake_case` 小写加下划线
- 每个步骤输出日志 `puts "Step ..."`
- 每个步骤检查错误，失败立即退出
- 创建输出目录如果不存在
- 使用环境变量获取工艺库路径，**不要硬编码绝对路径**
- 对大块注释使用 `# ----------` 分隔，清晰可读

❌ **避免：**
- 不要硬编码绝对路径 `/projects/chip/libs/...` → 换机器就不能用
- 不要不检查错误继续运行 → 失败了还继续，最后找不到哪里错了
- 不要没有日志 → 运行完不知道哪一步错了

---

## 步骤 3：Python 脚本开发

Python 用于：结果数据分析、流程控制、批量处理、报告生成。

### 3.1 脚本结构设计

```python
#!/usr/bin/env python3
"""
时序报告分析脚本
功能：从 STA 报告提取 WNS/TNS，生成汇总报告
"""

import argparse
import logging
from pathlib import Path
from typing import Dict, Optional

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def parse_arguments():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(
        description='Extract timing stats from STA reports'
    )
    parser.add_argument(
        '--input', '-i',
        required=True,
        type=Path,
        help='Input report directory'
    )
    parser.add_argument(
        '--output', '-o',
        required=True,
        type=Path,
        help='Output summary file'
    )
    return parser.parse_args()

def extract_timing(report_file: Path) -> Dict:
    """从时序报告提取关键数据"""
    data = {'wns': None, 'tns': None, 'np': None}
    
    with open(report_file, 'r') as f:
        for line in f:
            if 'WNS' in line:
                data['wns'] = float(line.split()[-1])
            if 'TNS' in line:
                data['tns'] = float(line.split()[-1])
            if 'NP' in line or 'Number of paths' in line:
                try:
                    data['np'] = int(line.split()[-1])
                except ValueError:
                    pass
    
    return data

def main():
    args = parse_arguments()
    
    # 验证输入
    if not args.input.exists():
        logger.error(f"Input directory not found: {args.input}")
        return 1
    
    results = {}
    for report_file in args.input.glob('*.rpt'):
        logger.info(f"Processing {report_file.name}")
        results[report_file.stem] = extract_timing(report_file)
    
    # 输出汇总
    with open(args.output, 'w') as f:
        f.write("Design,WNS,TNS,NP\n")
        for design, data in results.items():
            wns = data.get('wns', 'N/A')
            tns = data.get('tns', 'N/A')
            np_val = data.get('np', 'N/A')
            f.write(f"{design},{wns},{tns},{np_val}\n")
    
    logger.info(f"Summary written to {args.output}")
    return 0

if __name__ == '__main__':
    exit(main())
```

### 3.2 Python 编码准则

✅ **推荐：**
- 使用函数组织代码，一个函数做一件事
- 使用 `argparse` 处理命令行参数
- 使用 `logging` 输出日志，不要到处 `print`
- 使用类型提示增加可读性
- 使用 `pathlib` 处理路径，比字符串好
- 异常处理，给用户清晰错误信息

❌ **避免：**
- 不要硬编码文件名，使用参数
- 不要忽略异常，出问题用户不知道

---

## 步骤 4：Makefile 流程管理

使用 Makefile 管理整个流程，支持增量编译。

### 4.1 Makefile 基本结构

```makefile
# #################################################
# IC 设计流程 Makefile
# #################################################

# ---------- Configuration ----------
DESIGN = my_design
TOP = top_module
TOOL = dc_shell

# ---------- Directories ----------
SCRIPTS_DIR = scripts
OUTPUT_DIR = output
REPORTS_DIR = reports
LOGS_DIR = logs

# ---------- Default target ----------
all: synth place route signoff

# ---------- Synthesis ----------
synth: $(SCRIPTS_DIR)/synth.tcl
	@echo "========================================"
	@echo "Step 1: Synthesis"
	@echo "========================================"
	mkdir -p $(OUTPUT_DIR) $(REPORTS_DIR) $(LOGS_DIR)
	$(TOOL) -f $< | tee $(LOGS_DIR)/synth.log
	@echo "✓ Synthesis completed"

# ---------- Placement ----------
place: synth $(SCRIPTS_DIR)/place.tcl
	@echo "========================================"
	@echo "Step 2: Placement"
	@echo "========================================"
	icc2_shell -f $(SCRIPTS_DIR)/place.tcl | tee $(LOGS_DIR)/place.log
	@echo "✓ Placement completed"

# ---------- Routing ----------
route: place $(SCRIPTS_DIR)/route.tcl
	@echo "========================================"
	@echo "Step 3: Routing"
	@echo "========================================"
	icc2_shell -f $(SCRIPTS_DIR)/route.tcl | tee $(LOGS_DIR)/route.log
	@echo "✓ Routing completed"

# ---------- Signoff ----------
signoff: route $(SCRIPTS_DIR)/signoff.tcl
	@echo "========================================"
	@echo "Step 4: Signoff"
	@echo "========================================"
	pt_shell -f $(SCRIPTS_DIR)/signoff.tcl | tee $(LOGS_DIR)/signoff.log
	@echo "✓ Signoff completed"

# ---------- Clean ----------
clean:
	rm -rf $(OUTPUT_DIR)/* $(REPORTS_DIR)/* $(LOGS_DIR)/*

.PHONY: all synth place route signoff clean
```

### 4.2 Makefile 优点

| 优点 | 说明 |
|------|------|
| 增量编译 | 只重新运行修改过的步骤 |
| 依赖管理 | 自动处理步骤依赖关系 |
| 并行执行 | 可以并行运行独立任务 |
| 易于使用 | 大家都熟悉 make 命令 |

---

## 步骤 5：环境管理

### 5.1 环境变量配置

使用环境变量指定外部依赖路径：

```bash
# ~/.bashrc 或者环境配置文件
export PDK_ROOT=/opt/pdk/sky130A
export STD_CELL_LIBRARY=$(PDK_ROOT)/libs.ref/sky130_fd_sc_hd/default
export TARGET_LIBRARY=$(PDK_ROOT)/libs.ref/sky130_fd_sc_hd/fast
export LINK_LIBRARY=$(PDK_ROOT)/libs.ref/sky130_fd_sc_hd/slow
```

### 5.2 工具版本管理

使用 `modules` 工具管理不同工具版本：

```bash
module load synopsys/dc/2021.03
module load synopsys/icc2/2021.03
module load synopsys/pt/2021.03
```

---

## 步骤 6：错误处理和日志

### 6.1 TCL 错误处理

```tcl
# 检查命令执行结果
if {[catch {read_verilog design.v} result]} {
    puts "ERROR: Failed to read design: $result"
    exit 1
}

# 检查设计是否有效
if {![current_design]} {
    puts "ERROR: No current design"
    exit 1
}
```

### 6.2 常见错误处理

| 错误类型 | 检测方法 | 处理方式 |
|----------|----------|----------|
| License 失败 | "License checkout failed" | 立即退出，提示用户 |
| 文件不存在 | file exists 检查 | 立即退出，提示用户 |
| 内存不足 | "Out of memory" | 立即退出，建议减少并行度 |
| 超时 | 超时检查 | 立即退出，建议增加超时时间 |

---

## 步骤 7：结果收集和追踪

### 7.1 QoR 数据收集

每次运行收集关键指标：

| 指标 | 来源 | 收集方法 |
|------|------|----------|
| 总面积 | report_area | 正则提取 |
| WNS | report_timing | 正则提取 |
| TNS | report_timing | 正则提取 |
| 功耗 | report_power | 正则提取 |

### 7.2 回归对比

- 每次 RTL 修改自动运行全流程回归
- 对比结果，发现回归
- 夜间自动运行
- 邮件通知失败结果

---

## 步骤 8：版本控制

### 8.1 版本控制最佳实践

- ✅ 所有脚本纳入 git 版本控制
- ❌ 不要提交二进制结果（报告、网表、日志）
- ✅ 记录工具版本在 README
- ✅ 每个修改提交，方便回溯

### 8.2 项目目录结构

```
scripts/
├── synth.tcl          # 综合脚本
├── place.tcl          # 布局脚本
├── route.tcl          # 布线脚本
├── cts.tcl            # 时钟树综合
├── signoff.tcl        # 签出脚本
└── analyze_timing.py  # 时序结果分析

reports/               # 汇总报告
output/                # 输出文件（netlist, sdc 等）
logs/                  # 运行日志
```

---

## 检查清单

脚本写完检查：

- [ ] 不硬编码绝对路径 → 使用环境变量
- [ ] 每个步骤检查错误，失败退出
- [ ] 每个步骤输出日志 → 知道运行到哪了
- [ ] 创建输出目录如果不存在
- [ ] 支持增量运行 → 节省时间
- [ ] 结果可以收集汇总 → 方便对比
- [ ] 脚本有注释 → 别人能看懂

---

## 反模式（要避免）

❌ **硬编码绝对路径** → 换一台机器就不能运行

❌ **不检查错误** → 失败了还继续，最后找不到哪里错

❌ **没有日志** → 出问题不知道怎么错的

❌ **所有步骤从头跑** → 修改一点等几小时，浪费时间

❌ **二进制结果提交 git** → git 很快变大

---

## 代理协作

- 使用 `eda-scripting-developer` 代理进行 EDA 脚本开发
- 复杂流程分解为多个脚本，每个脚本做一件事
- 版本控制所有脚本，方便追溯
