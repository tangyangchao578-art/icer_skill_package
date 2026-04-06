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

## TCL 脚本最佳实践（EDA 工具流程）

### 推荐脚本结构

```tcl
# #################################################
# UCM 异步 FIFO 综合脚本
# #################################################

# ---------- Configuration ----------
set DESIGN             "async_fifo"
set TOP               "async_fifo"
set OUTPUT_DIR        "./output"
set REPORTS_DIR       "./reports"

# 从环境变量获取工艺库
set STD_CELL_LIBRARY $env(STD_CELL_LIBRARY)

# ---------- Create output directories ----------
file mkdir $OUTPUT_DIR
file mkdir $REPORTS_DIR

# ---------- Read design ----------
puts "========================================"
puts "Step 1: Reading RTL design..."
puts "========================================"

read_verilog {
  ../src/async_fifo.sv
  ../src/sync_two_stage.sv
}

hierarchy -top $TOP

# ---------- Check for errors ----------
if {![current_design]} {
  error "ERROR: Failed to read design, current_design is null"
  exit 1
}

puts "✓ Design read OK"

# ---------- Read constraints ----------
puts ""
puts "Step 2: Reading constraints..."
read_sdc ../constraints/${TOP}.sdc

# ---------- Synthesis ----------
puts ""
puts "Step 3: Synthesis..."
compile_ultra

# ---------- Check area ----------
report_area > $REPORTS_DIR/${TOP}.area.rpt
report_qor  > $REPORTS_DIR/${TOP}.qor.rpt

# ---------- Output ----------
puts ""
puts "Step 4: Writing output..."
write_verilog -hierarchy -output $OUTPUT_DIR/${TOP}.netlist.v
write_sdc                -output $OUTPUT_DIR/${TOP}.sdc
write_parasitics         -output $OUTPUT_DIR/${TOP}.spef

puts ""
puts "========================================"
puts "✅ Synthesis completed OK!"
puts "========================================"
```

### TCL 编码准则

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

## Python 脚本最佳实践（结果分析）

Python 用于：结果数据分析、流程控制、批量处理、报告生成。

### 推荐结构

```python
#!/usr/bin/env python3
import argparse
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

def parse_arguments():
    parser = argparse.ArgumentParser(
        description='Extract WNS/TNS from STA report and compare with previous'
    )
    parser.add_argument('--input', '-i',
                        required=True,
                        help='Input STA report file')
    parser.add_argument('--output', '-o',
                        help='Output JSON summary')
    return parser.parse_args()

def extract_timing_stats(report_path):
    """Extract WNS and TNS from timing report"""
    wns = None
    tns = None
    with open(report_path, 'r') as f:
        for line in f:
            if 'WNS' in line:
                wns = float(line.split()[-1])
            if 'TNS' in line:
                tns = float(line.split()[-1])
    return {'wns': wns, 'tns': tns}

def main():
    args = parse_arguments()
    logging.basicConfig(level=logging.INFO)

    logger.info(f"Processing report {args.input}")
    stats = extract_timing_stats(Path(args.input))

    print(f"WNS = {stats['wns']:.3f}")
    print(f"TNS = {stats['tns']:.3f}")

    if args.output:
        import json
        with open(args.output, 'w') as f:
            json.dump(stats, f, indent=2)

if __name__ == '__main__':
    main()
```

### Python 编码准则

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

## Makefile 流程管理

使用 Makefile 管理整个流程，支持增量编译：

```makefile
# Configuration
DESIGN = my_design
TOP = top_module

# Default target
all: synth place route signoff

# Synthesis
synth:
	mkdir -p logs
	mkdir -p output
	dc_shell -f scripts/synth.tcl | tee logs/synth.log

# Placement
place: synth
	mkdir -p logs
	icc2_shell -f scripts/place.tcl | tee logs/place.log

# Routing
route: place
	mkdir -p logs
	icc2_shell -f scripts/route.tcl | tee logs/route.log

# Signoff
signoff: route
	mkdir -p logs
	pt_shell -f scripts/signoff.tcl | tee logs/signoff.log

# Clean
clean:
	rm -rf output/* logs/* *.log

.PHONY: all synth place route signoff clean
```

**优点：**
- 只重新运行修改过的步骤
- 方便自动化
- 大家都熟悉，不用学习新工具

## 环境管理

### 环境变量

使用环境变量指定外部依赖路径，不要硬编码：

```bash
# ~/.bashrc 或者环境配置文件
export PDK_ROOT=/opt/pdk/sky130A
export STD_CELL_LIBRARY=$(PDK_ROOT)/libs.ref/sky130_fd_sc_hd/default
```

在 TCL 脚本中读取：

```tcl
set STD_CELL_LIBRARY $env(STD_CELL_LIBRARY)
```

### 工具版本管理

使用 `modules` 工具管理不同工具版本：

```bash
module load synopsys/dc/2021.03
module load synopsys/icc2/2021.03
```

需要新版本就 load 新版本，非常方便。

## 最佳实践

### 增量运行支持

- 支持只运行修改过的步骤
- 保存检查点，方便崩溃后重启
- 不要每次都从头运行 → 节省几小时运行时间
- Makefile 天生支持增量

### 结果收集和 QoR 追踪

- 每次运行收集关键结果：
  - 总面积
  - WNS (最差负 slack)
  - TNS (总负 slack)
  - 总功耗
- 生成对比表格，看优化效果
- 追踪 QoR (Quality of Results) 变化

### 回归测试

- 每次 RTL 修改自动运行全流程回归
- 对比结果，发现回归
- 夜间自动运行
- 邮件通知失败结果
- 早上来就能看结果

## 错误处理

| 错误 | 处理方法 |
|------|----------|
- 工具 license 失败 | 检测到 license 错误，脚本立即退出，不继续 |
| 磁盘空间不够 | 提前检查磁盘空间，不够提示 |
| 输入文件不存在 | 提前检查文件存在，不存在提示 |
| 步骤失败 | 立即退出，不继续下一步 |

**重要：** 如果前面步骤失败，后面步骤不要运行，浪费时间。

## 版本控制

- ✅ 所有脚本纳入 git 版本控制
- ❌ 不要提交二进制结果（报告，网表，日志）
- ✅ 记录工具版本在 README
- ✅ 每个修改提交，方便回溯

## 完整项目目录结构推荐

```
scripts/
├── synth.tcl          # 综合脚本
├── place.tcl          # 布局脚本
├── route.tcl          # 布线脚本
├── cts.tcl           # 时钟树综合
├── signoff.tcl       # 签出脚本
└── analyze_timing.py  # 时序结果分析

reports/              # 汇总报告
output/               # 输出文件（netlist, sdc 等）
logs/                 # 运行日志
```

## 检查清单

脚本写完检查：

- [ ] 不硬编码绝对路径 → 使用环境变量
- [ ] 每个步骤检查错误，失败退出
- [ ] 每个步骤输出日志 → 知道运行到哪了
- [ ] 创建输出目录如果不存在
- [ ] 支持增量运行 → 节省时间
- [ ] 结果可以收集汇总 → 方便对比
- [ ] 脚本有注释 → 别人能看懂

## 反模式（要避免）

❌ **硬编码绝对路径** → 换一台机器就不能运行
❌ **不检查错误** → 失败了还继续，最后找不到哪里错
❌ **没有日志** → 出问题不知道怎么错的
❌ **所有步骤从头跑** → 修改一点等几小时，浪费时间
❌ **二进制结果提交 git** → git 很快变大

## 代理协作

- 使用 `eda-scripting-developer` 代理进行 EDA 脚本开发
- 复杂流程分解为多个脚本，每个脚本做一件事
- 版本控制所有脚本，方便追溯
