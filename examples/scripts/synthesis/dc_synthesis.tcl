#==============================================================================
# Design Compiler 综合脚本
# 用途: RTL 到门级网表的综合
# 作者: ICER Skill Package
# 版本: 1.0
#==============================================================================

#------------------------------------------------------------------------------
# 设置
#------------------------------------------------------------------------------

# 设置设计名称
set DESIGN_NAME "top"
set CLOCK_NAME "clk"
set RESET_NAME "rst_n"

# 设置时钟周期 (ns)
set CLOCK_PERIOD 10.0

# 设置库路径 (需要根据实际环境修改)
set LIB_PATH "/path/to/library"
set TARGET_LIBRARY "$LIB_PATH/slow.db"
set LINK_LIBRARY   "$LIB_PATH/slow.db $LIB_PATH/pad.db"

# 设置搜索路径
set search_path [list "." $LIB_PATH]

# 设置工作目录
set WORK_DIR "./work"
file mkdir $WORK_DIR

#------------------------------------------------------------------------------
# 库设置
#------------------------------------------------------------------------------

# 设置目标库
set target_library $TARGET_LIBRARY

# 设置链接库
set link_library $LINK_LIBRARY

# 设置符号库
set symbol_library "$LIB_PATH/symbols.sdb"

# 设置 synthetic_library
set synthetic_library [list dw_foundation.sldb]

#------------------------------------------------------------------------------
# 读取设计
#------------------------------------------------------------------------------

# 定义工作库
define_design_lib WORK -path $WORK_DIR

# 分析 RTL 文件
analyze -format verilog {
    rtl/top.v
    rtl/submodule1.v
    rtl/submodule2.v
}

# 详细设计
elaborate $DESIGN_NAME

# 链接设计
link

# 检查设计
check_design

#------------------------------------------------------------------------------
# 约束设置
#------------------------------------------------------------------------------

# 创建时钟
create_clock -name $CLOCK_NAME -period $CLOCK_PERIOD [get_ports $CLOCK_NAME]

# 设置输入延迟
set_input_delay -max 2.0 -clock $CLOCK_NAME [all_inputs]
set_input_delay -min 0.5 -clock $CLOCK_NAME [all_inputs]

# 设置输出延迟
set_output_delay -max 2.0 -clock $CLOCK_NAME [all_outputs]
set_output_delay -min 0.5 -clock $CLOCK_NAME [all_outputs]

# 设置复位为假路径
set_false_path -from [get_ports $RESET_NAME]

# 设置驱动
set_driving_cell -lib_cell BUF_X1 -pin Z [all_inputs]

# 设置负载
set_load 0.1 [all_outputs]

# 设置最大扇出
set_max_fanout 20 [all_inputs]

# 设置最大转换时间
set_max_transition 0.5 [current_design]

# 设置最大电容
set_max_capacitance 0.5 [current_design]

# 设置面积约束
set_max_area 0

#------------------------------------------------------------------------------
# 编译
#------------------------------------------------------------------------------

# 编译选项
# -map_effort: 映射努力 (low, medium, high)
# -area_effort: 面积努力 (low, medium, high)
# -incremental: 增量编译

compile -map_effort high -area_effort high

# 如果时序不满足，可以尝试增量编译
# compile -incremental

#------------------------------------------------------------------------------
# 报告
#------------------------------------------------------------------------------

# 报告约束
report_constraint -all_violators > reports/constraint.rpt

# 报告时序
report_timing -max_paths 10 > reports/timing.rpt

# 报告面积
report_area > reports/area.rpt

# 报告功耗
report_power > reports/power.rpt

# 报告设计
report_design > reports/design.rpt

# 报告参考
report_reference > reports/reference.rpt

#------------------------------------------------------------------------------
# 输出
#------------------------------------------------------------------------------

# 移除未使用的端口
remove_unconnected_ports [get_cells -hierarchical *]

# 更改命名规则
change_names -rule verilog -hierarchy

# 输出网表
write -format verilog -hierarchy -output netlist/${DESIGN_NAME}.v

# 输出约束
write_sdc constraints/${DESIGN_NAME}.sdc

# 输出延时信息
write_sdf -version 2.1 sdf/${DESIGN_NAME}.sdf

# 输出数据库
write -format ddc -hierarchy -output db/${DESIGN_NAME}.ddc

#------------------------------------------------------------------------------
# 结束
#------------------------------------------------------------------------------

exit
