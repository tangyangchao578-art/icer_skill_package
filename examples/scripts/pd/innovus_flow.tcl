#==============================================================================
# Innovus 物理设计流程脚本
# 用途: 从网表到 GDS 的完整物理设计流程
# 作者: ICER Skill Package
# 版本: 1.0
#==============================================================================

#------------------------------------------------------------------------------
# 全局设置
#------------------------------------------------------------------------------

# 设计名称
set DESIGN_NAME "top"

# 库路径 (需要根据实际环境修改)
set LIB_PATH "/path/to/library"

# 设置库
set lib_list [list \
    "$LIB_PATH/slow.lib" \
]

set lef_list [list \
    "$LIB_PATH/tech.lef" \
    "$LIB_PATH/cells.lef" \
]

# 设置工作目录
set WORK_DIR "./work"
file mkdir $WORK_DIR

#------------------------------------------------------------------------------
# 初始化设计
#------------------------------------------------------------------------------

# 创建设计库
create_lib ${DESIGN_NAME}_lib

# 读取 LEF
read_lef $lef_list

# 读取库
read_liberty $lib_list

# 读取网表
read_verilog netlist/${DESIGN_NAME}.v

# 链接设计
link_design ${DESIGN_NAME}

# 读取 SDC
read_sdc constraints/${DESIGN_NAME}.sdc

#------------------------------------------------------------------------------
# Floorplan
#------------------------------------------------------------------------------

# 创建 floorplan
# 方式1: 指定利用率
floorPlan -coreUtilization 0.7 \
          -coreAspect 1.0 \
          -coreMargin 10

# 方式2: 指定尺寸
# floorPlan -site core -d 1000 1000 10 10 10 10

# 创建电源环
addRing -nets {VDD VSS} \
        -layer {top M8 bottom M8 left M9 right M9} \
        -width 2.0 \
        -spacing 0.5 \
        -offset 1.0

# 创建电源带
addStripe -nets {VDD VSS} \
          -layer M6 \
          -direction horizontal \
          -width 0.5 \
          -spacing 0.5 \
          -set_to_set_distance 50

# 放置 IO
# loadIoFile io_constraints.iof

# 放置 Macro
# placeInstance macro_inst1 100 200 R0

# 创建 Blockage
# createPlaceBlockage -type hard -boundary {{0 0} {100 100}}

#------------------------------------------------------------------------------
# Placement
#------------------------------------------------------------------------------

# 设置 placement 模式
setPlaceMode -timingDriven true \
             -congestion true \
             -maxDensity 0.85

# 全局 placement
placeDesign -inplace_opt

# 检查拥塞
routeDesign -globalDetailRoute -congestionMapOnly

# 如果拥塞严重，调整
# setPlaceMode -maxDensity 0.75
# placeDesign -inplace_opt

# 优化
optDesign -preCTS

#------------------------------------------------------------------------------
# CTS
#------------------------------------------------------------------------------

# 创建时钟
createClock -name clk -period 10 [getPorts clk]

# 设置 CTS 目标
setCCOptTarget -skew 0.1
setCCOptTarget -maxLatency 2.0

# 运行 CTS
ccopt_design

# 分析时钟树
report_ccopt_clock_trees > reports/cts_report.rpt

#------------------------------------------------------------------------------
# Routing
#------------------------------------------------------------------------------

# 设置布线层
setNanoRouteMode -drouteMinLayer M1
setNanoRouteMode -drouteMaxLayer M8

# 全局布线 + 详细布线
routeDesign -globalDetailRoute

# 天线修复
setNanoRouteMode -drouteFixAntenna true
routeDesign -repairAntenna

# 检查布线
verifyConnectivity
verifyGeometry

#------------------------------------------------------------------------------
# Post-Route Optimization
#------------------------------------------------------------------------------

# 后布线优化
optDesign -postRoute -setup -hold

# 检查时序
reportTiming > reports/timing_postroute.rpt

#------------------------------------------------------------------------------
# 物理验证
#------------------------------------------------------------------------------

# DRC
verifyGeometry > reports/drc.rpt

# LVS
verifyConnectivity > reports/lvs.rpt

# 天线
verifyAntenna > reports/antenna.rpt

#------------------------------------------------------------------------------
# 输出
#------------------------------------------------------------------------------

# 输出 GDS
streamOut gds/${DESIGN_NAME}.gds

# 输出 DEF
defOut def/${DESIGN_NAME}.def

# 输出网表
saveNetlist -excludeLeafCells netlist/${DESIGN_NAME}_final.v

# 输出 SPEF
rcOut -spef spef/${DESIGN_NAME}.spef

# 输出 SDF
write_sdf sdf/${DESIGN_NAME}.sdf

# 输出报告
report_area > reports/area.rpt
report_power > reports/power.rpt
report_timing -max_paths 20 > reports/timing_final.rpt

#------------------------------------------------------------------------------
# 结束
#------------------------------------------------------------------------------

exit
