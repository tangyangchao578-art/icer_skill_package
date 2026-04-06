# Design Compiler 命令速查

常用 Design Compiler (DC) 综合命令快速参考。

## 设计读取

| 命令 | 用途 | 示例 |
|------|------|------|
| `analyze` | 分析 RTL 文件 | `analyze -format verilog {a.v b.v}` |
| `elaborate` | 详细设计 | `elaborate top` |
| `link` | 链接设计 | `link` |
| `read` | 读取设计文件 | `read -format verilog top.v` |
| `current_design` | 设置当前设计 | `current_design top` |

## 时钟约束

| 命令 | 用途 | 示例 |
|------|------|------|
| `create_clock` | 创建时钟 | `create_clock -period 10 [get_ports clk]` |
| `create_generated_clock` | 创建派生时钟 | `create_generated_clock -divide_by 2 [get_pins div/Q]` |
| `set_clock_uncertainty` | 设置时钟不确定性 | `set_clock_uncertainty 0.2 [get_clocks clk]` |
| `set_clock_latency` | 设置时钟延迟 | `set_clock_latency 0.5 [get_clocks clk]` |

## 输入输出约束

| 命令 | 用途 | 示例 |
|------|------|------|
| `set_input_delay` | 设置输入延迟 | `set_input_delay -max 2 -clock clk [all_inputs]` |
| `set_output_delay` | 设置输出延迟 | `set_output_delay -max 2 -clock clk [all_outputs]` |
| `set_load` | 设置负载 | `set_load 0.1 [all_outputs]` |
| `set_driving_cell` | 设置驱动单元 | `set_driving_cell -lib_cell BUF_X1 [all_inputs]` |

## 路径约束

| 命令 | 用途 | 示例 |
|------|------|------|
| `set_false_path` | 设置假路径 | `set_false_path -from [get_ports rst]` |
| `set_multicycle_path` | 设置多周期路径 | `set_multicycle_path 2 -setup -from A -to B` |
| `set_clock_groups` | 设置时钟组 | `set_clock_groups -asynchronous -group clk1 -group clk2` |
| `set_max_delay` | 设置最大延迟 | `set_max_delay 5 -from A -to B` |

## 编译优化

| 命令 | 用途 | 示例 |
|------|------|------|
| `compile` | 编译设计 | `compile -map_effort high` |
| `compile_ultra` | 高级编译 | `compile_ultra` |
| `compile -incremental` | 增量编译 | `compile -incremental` |

## 报告

| 命令 | 用途 | 示例 |
|------|------|------|
| `report_timing` | 时序报告 | `report_timing -max_paths 10` |
| `report_area` | 面积报告 | `report_area` |
| `report_power` | 功耗报告 | `report_power` |
| `report_constraint` | 约束报告 | `report_constraint -all_violators` |
| `report_clock` | 时钟报告 | `report_clock` |
| `report_design` | 设计报告 | `report_design` |

## 输出

| 命令 | 用途 | 示例 |
|------|------|------|
| `write` | 输出设计 | `write -format verilog -hierarchy -out top.v` |
| `write_sdc` | 输出约束 | `write_sdc top.sdc` |
| `write_sdf` | 输出延时 | `write_sdf -version 2.1 top.sdf` |

## 常用流程

```tcl
# 完整综合流程
analyze -format verilog {rtl/*.v}
elaborate top
link
check_design
create_clock -period 10 [get_ports clk]
set_input_delay -max 2 -clock clk [all_inputs]
set_output_delay -max 2 -clock clk [all_outputs]
compile -map_effort high
report_timing -max_paths 10
report_area
write -format verilog -hierarchy -out netlist/top.v
write_sdc constraints/top.sdc
```

## 常见问题

| 问题 | 解决方法 |
|------|----------|
| 时序不收敛 | 尝试 `compile_ultra` 或调整约束 |
| 面积过大 | 使用 `set_max_area 0` 约束 |
| 无法链接 | 检查库设置和设计层次 |
| 未定义引用 | 检查 `link_library` 设置 |
