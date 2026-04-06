#==============================================================================
# PrimeTime 静态时序分析脚本
# 用途: 时序分析和签收
# 作者: ICER Skill Package
# 版本: 1.0
#==============================================================================

#------------------------------------------------------------------------------
# 设置
#------------------------------------------------------------------------------

# 设置设计名称
set DESIGN_NAME "top"

# 设置库路径 (需要根据实际环境修改)
set LIB_PATH "/path/to/library"

# 设置搜索路径
set search_path [list "." $LIB_PATH]

# 设置目标库
set link_library [list "*" "$LIB_PATH/slow.db" "$LIB_PATH/fast.db"]

#------------------------------------------------------------------------------
# 读取设计
#------------------------------------------------------------------------------

# 读取网表
read_verilog netlist/${DESIGN_NAME}.v

# 链接设计
link_design $DESIGN_NAME

# 读取寄生参数
read_spef -min min.spef
read_spef -max max.spef

# 读取约束
read_sdc constraints/${DESIGN_NAME}.sdc

#------------------------------------------------------------------------------
# 时序分析设置
#------------------------------------------------------------------------------

# 设置分析类型
# bc_wc: best-case worst-case
# on_chip_variation: OCV 分析
set_operating_conditions -analysis_type bc_wc

# 设置时序降额 (OCV)
set_timing_derate -early 0.90 -cell_delay -net_delay
set_timing_derate -late 1.10 -cell_delay -net_delay

#------------------------------------------------------------------------------
# 报告生成
#------------------------------------------------------------------------------

# 创建报告目录
file mkdir reports

# 报告时序摘要
report_timing -summary > reports/timing_summary.rpt

# 报告最大路径
report_timing -max_paths 20 -delay_type max > reports/timing_max.rpt

# 报告最小路径 (保持时间)
report_timing -max_paths 20 -delay_type min > reports/timing_min.rpt

# 报告路径组
report_timing -group > reports/timing_group.rpt

# 报告约束违反
report_constraint -all_violators > reports/constraint_violators.rpt

# 报告时钟
report_clock > reports/clock.rpt

# 报告时钟树
report_clock_timing -type summary > reports/clock_timing.rpt

# 报告面积
report_area > reports/area.rpt

# 报告功耗
report_power > reports/power.rpt

# 报告设计
report_design > reports/design.rpt

#------------------------------------------------------------------------------
# 时序检查
#------------------------------------------------------------------------------

# 检查时序
check_timing > reports/check_timing.rpt

# 检查约束
check_constraints > reports/check_constraints.rpt

# 报告 WNS/TNS
set wns [get_attribute [get_timing_paths] slack]
set tns 0
foreach_in_collection path [get_timing_paths] {
    set slack [get_attribute $path slack]
    if {$slack < 0} {
        set tns [expr $tns + $slack]
    }
}

echo "WNS: $wns"
echo "TNS: $tns"

# 保存 WNS/TNS 到文件
set fp [open reports/timing_summary.txt w]
puts $fp "Design: $DESIGN_NAME"
puts $fp "WNS: $wns ps"
puts $fp "TNS: $tns ps"
close $fp

#------------------------------------------------------------------------------
# 多工艺角分析
#------------------------------------------------------------------------------

# 设置工艺角
set corners [list ss tt ff]

foreach corner $corners {
    # 设置库
    set link_library [list "*" "$LIB_PATH/${corner}.db"]

    # 重新链接
    link_design $DESIGN_NAME

    # 报告时序
    report_timing -max_paths 10 -delay_type max > reports/timing_${corner}_max.rpt
    report_timing -max_paths 10 -delay_type min > reports/timing_${corner}_min.rpt
}

#------------------------------------------------------------------------------
# 输出
#------------------------------------------------------------------------------

# 保存会话
save_session pt_session

#------------------------------------------------------------------------------
# 结束
#------------------------------------------------------------------------------

exit
