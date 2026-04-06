#==============================================================================
# 时序约束文件 (SDC)
# 用途: 定义时钟、输入输出延迟、假路径等
# 作者: ICER Skill Package
# 版本: 1.0
#==============================================================================

#------------------------------------------------------------------------------
# 时钟定义
#------------------------------------------------------------------------------

# 主时钟
create_clock -name clk -period 10 [get_ports clk]

# 派生时钟
create_generated_clock -name clk_div2 \
                       -source [get_ports clk] \
                       -divide_by 2 \
                       [get_pins div_inst/clk_out]

# 时钟不确定性 (时钟抖动 + 建立时间裕量)
set_clock_uncertainty -setup 0.2 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]

# 时钟延迟
set_clock_latency -max 0.5 [get_clocks clk]
set_clock_latency -min 0.3 [get_clocks clk]

# 时钟转换时间
set_clock_transition 0.1 [get_clocks clk]

#------------------------------------------------------------------------------
# 输入延迟
#------------------------------------------------------------------------------

# 所有输入默认延迟
set_input_delay -max 2.0 -clock clk [all_inputs]
set_input_delay -min 0.5 -clock clk [all_inputs]

# 特定端口延迟
set_input_delay -max 1.5 -clock clk [get_ports data_in]
set_input_delay -min 0.3 -clock clk [get_ports data_in]

#------------------------------------------------------------------------------
# 输出延迟
#------------------------------------------------------------------------------

# 所有输出默认延迟
set_output_delay -max 2.0 -clock clk [all_outputs]
set_output_delay -min 0.5 -clock clk [all_outputs]

# 特定端口延迟
set_output_delay -max 1.5 -clock clk [get_ports data_out]
set_output_delay -min 0.3 -clock clk [get_ports data_out]

#------------------------------------------------------------------------------
# 异步路径
#------------------------------------------------------------------------------

# 复位为假路径
set_false_path -from [get_ports rst_n]

# 异步复位
set_false_path -from [get_ports async_rst_n]

# 测试模式
set_false_path -from [get_ports test_mode]

#------------------------------------------------------------------------------
# 多周期路径
#------------------------------------------------------------------------------

# 数据路径需要两个周期
set_multicycle_path 2 -setup -from [get_pins reg1/Q] -to [get_pins reg2/D]
set_multicycle_path 1 -hold -from [get_pins reg1/Q] -to [get_pins reg2/D]

#------------------------------------------------------------------------------
- 跨时钟域路径
#------------------------------------------------------------------------------

# 异步时钟域之间的路径
set_clock_groups -asynchronous -group [get_clocks clk] \
                              -group [get_clocks clk_div2]

# 或者使用假路径
set_false_path -from [get_clocks clk] -to [get_clocks clk_div2]
set_false_path -from [get_clocks clk_div2] -to [get_clocks clk]

#------------------------------------------------------------------------------
# 负载和驱动
#------------------------------------------------------------------------------

# 输入驱动
set_driving_cell -lib_cell BUF_X1 -pin Z [all_inputs]

# 输出负载
set_load 0.1 [all_outputs]

# 端口负载
set_load 0.05 [get_ports data_out]

#------------------------------------------------------------------------------
- 扇出约束
#------------------------------------------------------------------------------

# 最大扇出
set_max_fanout 20 [all_inputs]

# 扇出负载
set_fanout_load 4 [get_ports data_out]

#------------------------------------------------------------------------------
# 转换时间和电容约束
#------------------------------------------------------------------------------

# 最大转换时间
set_max_transition 0.5 [current_design]

# 最大电容
set_max_capacitance 0.5 [current_design]

# 最小电容
set_min_capacitance 0.01 [current_design]

#------------------------------------------------------------------------------
# 面积和功耗约束
#------------------------------------------------------------------------------

# 最大面积
set_max_area 0

# 功耗约束
set_max_total_power 100 mW

#------------------------------------------------------------------------------
# 额外约束
#------------------------------------------------------------------------------

# 禁止使用的单元
set_dont_use [get_lib_cells */*BUF_X16*]

# 保持不变的单元
set_dont_touch [get_cells -hierarchical *]

# 理想网络
set_ideal_network [get_ports clk]

#------------------------------------------------------------------------------
# 操作条件
#------------------------------------------------------------------------------

# 设置操作条件
set_operating_conditions -max slow -min fast

# 线负载模型
set_wire_load_mode top
