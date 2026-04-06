# PrimeTime 命令速查

常用 PrimeTime (PT) 静态时序分析命令快速参考。

## 设计读取

| 命令 | 用途 | 示例 |
|------|------|------|
| `read_verilog` | 读取网表 | `read_verilog netlist/top.v` |
| `link_design` | 链接设计 | `link_design top` |
| `read_sdc` | 读取约束 | `read_sdc constraints/top.sdc` |
| `read_spef` | 读取寄生参数 | `read_spef top.spef` |
| `read_parasitics` | 读取寄生参数 | `read_parasitics top.spef` |

## 时钟操作

| 命令 | 用途 | 示例 |
|------|------|------|
| `create_clock` | 创建时钟 | `create_clock -period 10 [get_ports clk]` |
| `report_clock` | 报告时钟 | `report_clock` |
| `report_clock_timing` | 时钟时序报告 | `report_clock_timing -type summary` |

## 时序分析

| 命令 | 用途 | 示例 |
|------|------|------|
| `report_timing` | 时序报告 | `report_timing -max_paths 10` |
| `report_timing -delay_type max` | 建立时间报告 | `report_timing -delay_type max` |
| `report_timing -delay_type min` | 保持时间报告 | `report_timing -delay_type min` |
| `report_timing -group` | 按组报告 | `report_timing -group` |
| `report_constraint` | 约束报告 | `report_constraint -all_violators` |

## OCV 分析

| 命令 | 用途 | 示例 |
|------|------|------|
| `set_operating_conditions` | 设置操作条件 | `set_operating_conditions -analysis_type on_chip_variation` |
| `set_timing_derate` | 设置时序降额 | `set_timing_derate -early 0.9 -late 1.1` |

## 多工艺角

| 命令 | 用途 | 示例 |
|------|------|------|
| `create_scenario` | 创建场景 | `create_scenario -name ss` |
| `current_scenario` | 设置当前场景 | `current_scenario ss` |
| `report_scenario` | 报告场景 | `report_scenario` |

## 报告

| 命令 | 用途 | 示例 |
|------|------|------|
| `report_timing -summary` | 时序摘要 | `report_timing -summary` |
| `report_area` | 面积报告 | `report_area` |
| `report_power` | 功耗报告 | `report_power` |
| `report_design` | 设计报告 | `report_design` |
| `report_qor` | 质量报告 | `report_qor` |

## 检查

| 命令 | 用途 | 示例 |
|------|------|------|
| `check_timing` | 时序检查 | `check_timing` |
| `check_constraints` | 约束检查 | `check_constraints` |
| `report_violation` | 违规报告 | `report_violation` |

## 属性查询

| 命令 | 用途 | 示例 |
|------|------|------|
| `get_attribute` | 获取属性 | `get_attribute [get_timing_paths] slack` |
| `get_clocks` | 获取时钟 | `get_clocks *` |
| `get_ports` | 获取端口 | `get_ports clk` |
| `get_pins` | 获取引脚 | `get_pins -hierarchical *` |
| `get_cells` | 获取单元 | `get_cells -hierarchical *` |

## 常用流程

```tcl
# 完整 STA 流程
set search_path [list "." "/path/to/library"]
set link_library [list "*" "slow.db" "fast.db"]

read_verilog netlist/top.v
link_design top
read_spef top.spef
read_sdc constraints/top.sdc

set_operating_conditions -analysis_type on_chip_variation
set_timing_derate -early 0.9 -late 1.1

report_timing -max_paths 20 -delay_type max > reports/timing_max.rpt
report_timing -max_paths 20 -delay_type min > reports/timing_min.rpt
report_constraint -all_violators > reports/violations.rpt

check_timing
check_constraints

save_session pt_session
```

## 关键指标

| 指标 | 全称 | 说明 |
|------|------|------|
| WNS | Worst Negative Slack | 最差负松弛，应 >= 0 |
| TNS | Total Negative Slack | 总负松弛，应 = 0 |
| WNS (hold) | Worst Negative Slack (hold) | 保持时间最差负松弛 |
| TNS (hold) | Total Negative Slack (hold) | 保持时间总负松弛 |

## 时序路径分析

```tcl
# 报告特定路径
report_timing -from [get_pins reg1/Q] -to [get_pins reg2/D]

# 报告通过特定单元的路径
report_timing -through [get_cells block1/*]

# 报告最差路径详情
report_timing -max_paths 1 -input_pins -nets -caps

# 计算 WNS/TNS
set paths [get_timing_paths]
set wns [get_attribute $paths slack]
set tns 0
foreach_in_collection p $paths {
    set s [get_attribute $p slack]
    if {$s < 0} { set tns [expr $tns + $s] }
}
```
