---
name: physical-design
description: 物理设计全流程技能 - 从floorplan到GDSII，完整数字芯片物理设计指导
description.zh: 物理设计全流程技能 - 从floorplan到GDSII，完整数字芯片物理设计指导
origin: ICER
categories: back-end
---

# 物理设计全流程技能

当用户需要进行数字芯片物理设计时，启用此技能。提供从 floorplan 到 GDSII 全流程指导，涵盖问题调试和优化。

## When to Activate

- 全芯片物理设计从头开始
- 模块级物理设计
- 时序收敛问题调试
- 物理设计流程优化
- DRC/LVS 问题调试

## 物理设计完整流程

### 阶段 1：输入数据准备

**需要准备：**
- [ ] 综合后门级网表（.v）
- [ ] 时序约束（SDC）
- [ ] 工艺库文件（.lef, .lib, .tech, GDS）
- [ ] IO 摆放信息（.iof）
- [ ] 电源地规划
- [ ] Filling 规则

**检查：**
- [ ] 网表没有未连接端口
- [ ] 约束语法正确
- [ ] 库文件对应正确工艺版本

---

### 阶段 2：Floorplan

**步骤：**
1. 设置芯片核心尺寸（core area）
2. IO 摆放（按 package 要求）
3. 电源环/电源带创建
4. PDN（电源分布网络）创建
5. 模块 hard macro 摆放
6. 标准模块区域划分

**检查清单 ✅**

- [ ] 总面积满足项目要求
- [ ] PDN IR 降满足要求（< 5% Vdd）
- [ ] PDN 电迁移满足要求
- [ ] 模块摆放符合数据流方向
- [ ] 硬宏模块避开电源带
- [ ] IO 摆放符合 package 要求
- [ ] 留出足够通道方便走线

**Floorplan 最佳实践：**

- 高吞吐量数据通路摆放紧凑，减少线长
- 存储器摆放靠近 IO，减少延迟
- 时钟模块放在芯片中心方便分发
- 电源 pad 均匀分布，减少 IR 降

### Floorplan 详细流程与命令

#### ICC2 Floorplan 命令

```tcl
# ============================================
# 1. 创建 Floorplan
# ============================================

# 设置芯片尺寸和核心区域
initialize_floorplan -core_utilization 0.7 \
                     -core_aspect_ratio 1.0 \
                     -core_margins {{left 10} {right 10} {top 10} {bottom 10}}

# 或者直接指定尺寸
initialize_floorplan -core_area {0 0 1000 1000}

# ============================================
# 2. IO 摆放
# ============================================

# 自动摆放 IO
place_pins -self

# 手动摆放 IO
set_pin_physical_constraint -pins {pin_name} -layers {M4} -sides {1}

# 按约束文件摆放
read_io_constraints io_constraints.iof

# ============================================
# 3. 电源环创建
# ============================================

# 创建电源环
create_pg_ring_pattern ring_pattern \
    -horizontal_layer M8 \
    -vertical_layer M9 \
    -horizontal_width {2.0} \
    -vertical_width {2.0} \
    -horizontal_spacing {0.5} \
    -vertical_spacing {0.5}

set_pg_strategy ring_strategy \
    -pattern {{name: ring_pattern} {nets: {VDD VSS}} \
    -core_offset {{inter_semiconductor_space: 1.0}}}

create_pg_mesh_region ring_strategy

# ============================================
# 4. 电源带创建
# ============================================

# 创建电源带
create_pg_mesh_pattern mesh_pattern \
    -horizontal_layer M6 \
    -vertical_layer M7 \
    -horizontal_width {0.5} \
    -vertical_width {0.5} \
    -horizontal_pitch {50} \
    -vertical_pitch {50}

# ============================================
# 5. Hard Macro 摆放
# ============================================

# 设置 Macro 约束
set_macro_constraint -allowed_orientations {R0 R180 MX MY}

# 手动摆放 Macro
place_cell -inst_name macro_inst1 -location {100 200} -orientation R0

# 自动摆放 Macro
place_macros

# 设置 Macro Keepout
create_keepout_margin -type hard -outer {5 5 5 5} macro_inst1
```

#### Innovus Floorplan 命令

```tcl
# ============================================
# Innovus Floorplan 流程
# ============================================

# 设置设计
loadDesign design.dc

# 创建 floorplan
floorPlan -coreUtilization 0.7 \
          -coreAspect 1.0 \
          -coreMargin 10

# 或者指定尺寸
floorPlan -site core -d 1000 1000 10 10 10 10

# IO 摆放
loadIoFile io_constraints.iof

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

# Macro 摆放
placeInstance macro_inst1 100 200 R0

# 创建 blockage
createPlaceBlockage -type hard -boundary {{0 0} {100 100}}
```

#### OpenROAD Floorplan 命令

```tcl
# ============================================
# OpenROAD Floorplan 流程
# ============================================

# 初始化 floorplan
initialize_floorplan -utilization 0.7 \
                     -aspect_ratio 1.0 \
                     -core_space 10

# IO 摆放
place_pins -hor_layers M4 -ver_layers M3

# 创建电源网格
add_global_connection -net VDD -pin_pattern {VDD} -power
add_global_connection -net VSS -pin_pattern {VSS} -ground

# 电源网格定义
define_pdng_grid -name grid1 \
                 -starts_with POWER \
                 -layers {M8 M9} \
                 -widths 2.0 \
                 -pitches 100

# Macro 摆放
place_macro -macro_name macro_inst1 -x 100 -y 200 -orientation R0
```

#### Floorplan 常见问题与解决

| 问题 | 原因 | 解决方法 |
|------|------|----------|
| 面积过大 | 利用率设置过低 | 提高利用率，重新规划 |
| 拥塞严重 | Macro 摆放过密 | 调整 Macro 间距，增加通道 |
| IR 降过大 | 电源网格不足 | 增加电源带宽，减少间距 |
| 时序不收敛 | Macro 位置不合理 | 根据 dataflow 重新摆放 |

---

### 阶段 3：Placement

**步骤：**
1. 全局 placement（global placement）
2. 详细 placement（detailed placement）
3. 拥塞优化
4. 时序优化 placement

**检查清单 ✅**

- [ ] 布线拥塞在合理范围（< 80% 密度）
- [ ] 初始 WNS 满足初步要求（> 0 最好，至少不太多负slack）
- [ ] 没有超长网表（net length 太大）
- [ ] 硬宏周围密度合理，不拥塞

**拥塞过高怎么办？**

1. 重新摆放大模块，分散开
- 给大总线留出专用通道
- 分解超大模块为多个小模块
- 降低局部模块密度，留出空间

### Placement 详细流程与命令

#### ICC2 Placement 命令

```tcl
# ============================================
# 1. 全局 Placement
# ============================================

# 设置 placement 目标
set_placement_spacing_label -name S -side both -lib_cells [get_lib_cells]

# 运行全局 placement
place_opt -from initial

# 或者分步执行
legalize_placement -incremental

# ============================================
# 2. 拥塞分析
# ============================================

# 检查拥塞
report_congestion

# 查看详细拥塞
report_congestion -layers {M1 M2 M3 M4 M5 M6}

# 生成拥塞热点报告
report_congestion -hotspot

# ============================================
# 3. 拥塞优化
# ============================================

# 如果拥塞严重，增加目标密度
set_placement_spacing_label -name S -side both -lib_cells [get_lib_cells]
set_placement_density_limit 0.75

# 拥塞驱动的 placement
place_opt -congestion_effort high

# 使用 padding 缓解拥塞
set_placement_padding -global -left 2 -right 2

# ============================================
# 4. 时序驱动 Placement
# ============================================

# 使能时序优化
set_optimize_effort -high

# 运行时序驱动的 placement
place_opt -from initial -timing_effort high

# 检查初始时序
report_timing -max_paths 10
```

#### Innovus Placement 命令

```tcl
# ============================================
# Innovus Placement 流程
# ============================================

# 全局 placement
placeDesign -inplace_opt

# 拥塞分析
routeDesign -globalDetailRoute -congestionMapOnly

# 查看拥塞
encounter 13> win select CongestionViewer
encounter 14> congestionViewer -showCongestion

# 拥塞优化
setPlaceMode -timingDriven true -congestion true
placeDesign

# 时序检查
reportTiming

# 优化 placement
optDesign -preCTS
```

#### Placement 检查清单

| 检查项 | 目标值 | 检查方法 |
|--------|--------|----------|
| 全局拥塞 | < 5% | report_congestion |
| 局部拥塞 | < 80% | report_congestion -hotspot |
| 初始 WNS | > -500ps | report_timing |
| 最大线长 | 合理范围 | report_net_lengths |
| 单元密度 | < 85% | report_design_density |

#### Placement 常见问题与解决

| 问题 | 现象 | 解决方法 |
|------|------|----------|
| 拥塞热点 | 局部密度 > 90% | 增加 padding，调整 Macro 位置 |
| 时序差 | WNS < -1ns | 使能 timing-driven placement |
| 线长过长 | 关键路径延迟大 | 调整权重，优化关键路径摆放 |
| 重叠 | 单元重叠 | 运行 legalize_placement |

---

### 阶段 4：CTS（时钟树综合）

**步骤：**
1. 时钟树目标设置（skew 目标，latency 目标）
2. 时钟树综合
3. 时钟树优化（skew 优化，power 优化）
4. 时钟树验证

**目标：**

| 指标 | 目标 |
|------|------|
| 时钟 skew | < 100ps (先进工艺) |
| 时钟 latency | 满足设计要求 |
| 转换时间 | < 最大允许值 |
| 时钟功耗 | 在预算内 |

**检查清单 ✅**

- [ ] 时钟 skew 满足要求
- [ ] 时钟 latency 满足要求
- [ ] 转换时间满足要求
- [ ] 功耗满足要求
- [ ] 没有未平衡的时钟端点

**CTS 最佳实践：**

- 异步时钟域分开做 CTS，不要平衡
- 门控时钟正确识别，不要缓冲门控输出
- 使用有用skew优化改善时序

### CTS 详细流程与命令

#### ICC2 CTS 命令

```tcl
# ============================================
# 1. 时钟树设置
# ============================================

# 定义时钟
create_clock -name clk -period 10 [get_ports clk]

# 设置时钟树目标
set_clock_tree_options -target_skew 0.1
set_clock_tree_options -target_max_latency 2.0
set_clock_tree_options -target_min_latency 0.5

# 设置时钟树约束
set_clock_tree_constraints -max_transition 0.2
set_clock_tree_constraints -max_capacitance 0.5

# ============================================
# 2. 时钟树综合
# ============================================

# 综合时钟树
clock_tree_synthesis

# 或者使用 opt 设计
compile_clock_tree

# ============================================
# 3. 时钟树分析
# ============================================

# 报告时钟树状态
report_clock_tree -status

# 报告时钟 skew
report_clock_tree -skew

# 报告时钟 latency
report_clock_tree -latency

# 详细报告
report_clock_timing -type summary

# ============================================
# 4. 时钟树优化
# ============================================

# skew 优化
optimize_clock_tree -skew

# power 优化
optimize_clock_tree -power

# latency 优化
optimize_clock_tree -latency

# ============================================
# 5. 时钟树验证
# ============================================

# 检查时钟树
check_clock_tree

# 验证时钟网络
verify_clock_tree
```

#### Innovus CTS 命令

```tcl
# ============================================
# Innovus CTS 流程
# ============================================

# 创建时钟
createClock -name clk -period 10 [getPorts clk]

# 设置 CTS 目标
setCCOptTarget -skew 0.1
setCCOptTarget -maxLatency 2.0

# 运行 CTS
ccopt_design

# 分析时钟树
report_ccopt_clock_trees

# 验证
verifyClockNets
```

#### CTS 时钟树质量指标

| 指标 | 定义 | 目标值 |
|------|------|--------|
| Clock Skew | 同一时钟域内时钟到达时间差 | < 100ps (先进工艺) |
| Clock Latency | 时钟从源到寄存器的延迟 | 满足设计约束 |
| Insertion Delay | 时钟树插入延迟 | 越小越好，但需平衡 |
| Transition Time | 时钟信号转换时间 | < 最大允许值 |
| Clock Power | 时钟网络功耗 | 在预算内 |

#### CTS 常见问题与解决

| 问题 | 原因 | 解决方法 |
|------|------|----------|
| Skew 过大 | 时钟树不平衡 | 增加平衡 buffer，调整树结构 |
| Latency 过大 | 时钟树级数太多 | 减少级数，使用更大驱动 |
| 功耗过大 | 时钟网络负载大 | 使用门控时钟，减少翻转 |
| Transition 过大 | 驱动能力不足 | 增加 buffer，使用更大驱动 |

---

### 阶段 5：Routing

**步骤：**
1. 全局布线（global routing）
2. 详细布线（detailed routing）
3. 搜索修复布线失败
- 天线修复

**检查清单 ✅**

- [ ] 100% 布线完成（没有 unroute net）
- [ ] 没有绕线失败
- [ ] 所有天线违反修复完成
- [ ] 短路开路检查通过

**常见问题修复：**

- **布线失败**：局部拥塞 → 重新摆放模块增加通道
- **天线违反**：跳线到上层，或者插入天线二极管
- **短路**：检查重叠过孔，检查间距

### Routing 详细流程与命令

#### ICC2 Routing 命令

```tcl
# ============================================
# 1. 全局布线
# ============================================

# 检查布线拥塞
report_route_quality

# 设置布线层约束
set_ignored_layers -min_layer M1 -max_layer M8

# 全局布线
route_global

# ============================================
# 2. 详细布线
# ============================================

# 运行详细布线
route_auto

# 或分步执行
route_track
route_detail

# ============================================
# 3. 天线修复
# ============================================

# 检查天线违反
report_antenna_violations

# 自动修复天线违反
route_opt -repair_antenna

# 插入天线二极管
insert_antenna_diodes -all

# ============================================
# 4. 布线优化
# ============================================

# 优化布线
route_opt -size_only

# 修布线 DRC
route_opt -drc_effort high

# ============================================
# 5. 布线验证
# ============================================

# 检查布线完成度
report_route_status

# 检查未布线网络
report_unconnected_nets

# 检查短路和开路
verify_routing
```

#### Innovus Routing 命令

```tcl
# ============================================
# Innovus Routing 流程
# ============================================

# 设置布线层
setNanoRouteMode -drouteMinLayer M1
setNanoRouteMode -drouteMaxLayer M8

# 全局布线
globalDetailRoute

# 详细布线
detailRoute

# 天线修复
setNanoRouteMode -drouteFixAntenna true
routeDesign

# 检查布线
verifyConnectivity
verifyGeometry
```

#### Routing 检查清单

| 检查项 | 目标 | 命令 |
|--------|------|------|
| 布线完成率 | 100% | report_route_status |
| 天线违反 | 0 | report_antenna_violations |
| 短路 | 0 | verify_routing |
| 开路 | 0 | verify_routing |
| DRC 违反 | 0 | verify_geometry |

---

### 阶段 6：Timing Closure

**步骤：**
1. 静态时序分析
2. 识别最差路径
3. 修复建立时间违例
4. 修复保持时间违例
5. 迭代，直到所有满足

**优化优先级**

1. **满足建立时间**（所有工艺角）
2. **满足保持时间**（所有工艺角）
3. **修复所有违例**（转换时间，电容负载）

**检查清单 ✅**

- [ ] 所有工艺角 WNS ≥ 0
- [ ] 所有工艺角 TNS = 0
- [ ] 保持时间所有路径满足
- [ ] 没有最大转换时间违反
- [ ] 没有最大电容负载违反
- [ ] OCV 分析满足要求

### Timing Closure 详细流程与命令

#### ICC2 时序优化命令

```tcl
# ============================================
# 1. 时序分析
# ============================================

# 基本时序报告
report_timing -max_paths 10

# 详细时序报告
report_timing -max_paths 10 -delay_type max -input_pins -nets -caps

# 建立/保持时间报告
report_timing -delay_type max -max_paths 10  # 建立
report_timing -delay_type min -max_paths 10  # 保持

# 报告 WNS/TNS
report_timing -summary

# ============================================
# 2. 修复建立时间违例
# ============================================

# 自动优化
opt_design -post_route

# 具体优化策略
# 2.1 增加驱动
size_cell -cell_name <cell> -new_cell <larger_cell>

# 2.2 复制高扇出
clone_cell -cell_name <cell>

# 2.3 重新摆放关键路径
place_opt -timing_effort high -critical_path_endpoints

# 2.4 有用偏斜
set_clock_latency -max 0.2 [get_clocks clk] -source
set_clock_latency -min 0.1 [get_clocks clk] -source

# ============================================
# 3. 修复保持时间违例
# ============================================

# 自动修复
opt_design -post_route -hold

# 插入延迟单元
insert_buffer -cell_name <buffer_cell> -net <net_name>

# 调整驱动大小（用更小驱动）
size_cell -cell_name <cell> -new_cell <smaller_cell>

# ============================================
# 4. 多工艺角分析
# ============================================

# 设置工艺角
set_operating_conditions -analysis_type on_chip_variation

# 运行多工艺角分析
report_timing -corners {ss ff tt}

# OCV 分析
set_timing_derate -early 0.9 -cell_delay
set_timing_derate -late 1.1 -cell_delay
report_timing -max_paths 10
```

#### Innovus 时序优化命令

```tcl
# ============================================
# Innovus 时序优化流程
# ============================================

# 时序报告
reportTiming

# 建立时间优化
optDesign -postCTS -setup

# 保持时间优化
optDesign -postCTS -hold

# 后布线优化
optDesign -postRoute -setup -hold

# 多工艺角
setAnalysisMode -analysisType onChipVariation
reportTiming -corners {ss ff tt}
```

#### 时序收敛决策树

```
时序违例
    │
    ├── 建立时间违例 (Setup Violation)
    │       │
    │       ├── 组合逻辑延迟太大？
    │       │       ├── 是 → 流水线分割
    │       │       └── 否 → 继续分析
    │       │
    │       ├── 驱动不足？
    │       │       ├── 是 → 增加驱动
    │       │       └── 否 → 继续分析
    │       │
    │       ├── 线长太长？
    │       │       ├── 是 → 重新摆放
    │       │       └── 否 → 有用偏斜
    │       │
    │       └── 高扇出？
    │               └── 是 → 复制寄存器
    │
    └── 保持时间违例 (Hold Violation)
            │
            ├── 路径太快？
            │       ├── 是 → 插入延迟单元
            │       └── 否 → 继续分析
            │
            ├── 时钟偏斜问题？
            │       ├── 是 → 调整有用偏斜
            │       └── 否 → 增加线长
            │
            └── 驱动过大？
                    └── 是 → 减小驱动
```

---

### 阶段 7：物理验证

**必须做：**

1. **DRC**（设计规则检查）→ 零违反才能流片
2. **LVS**（版图原理图比对）→ 零违反才能流片
3. **ERC**（电学规则检查）
4. **天线检查**
5. **密度检查**
6. **IR 降分析**
7. **电迁移分析**

**检查清单 ✅**

- [ ] DRC 零违反
- [ ] LVS 零违反
- [ ] ERC 零违反
- [ ] 密度满足要求
- [ ] IR 降满足要求
- [ ] 电迁移满足要求

---

### 阶段 8：出带（tapeout）

**生成：**

- [ ] GDSII 完整芯片
- [ ] LEF/DEF 交换文件
- [ ] SPEF 寄生参数
- [ ] 最终网表
- [ ] 时序报告
- [ ] 所有检查报告

**文档：**

- 汇总报告（面积、时序、功耗）
- 违例汇总（如果有必须的waiver）
- GDS 层级说明

## 优化目标优先级

优先级从高到低：

1. **满足时序要求**（建立时间 + 保持时间，所有工艺角）
2. **满足物理验证**（DRC/LVS 零违反）
3. **满足功耗预算**
4. **最小化面积**

## 常见问题调试

### 问题 1：拥塞过高

**解决方法：**

1. **重新摆放模块**：把拥塞区域模块分散开
2. **留出通道**：给大总线和数据通路留出专用通道
3. **分解大模块**：超大模块分解成多个小模块
4. **降低密度**：增加芯片面积一点点，降低局部密度
5. **移除没用的逻辑**：删除死代码减少单元

### 问题 2：建立时间违例

**解决方法（按效果排序）：**

1. **流水线重分割**：把长组合逻辑分成多个流水级 → 最有效
2. **换更大驱动**：增加驱动强度减少延迟
3. **复制高扇出驱动**：大扇出复制多个寄存器减少负载每个
4. **重新摆放**：重新摆放减少关键路径线长
5. **有用偏斜调整**：调整寄存器时钟偏斜改善
6. **retiming**：移动寄存器边界平衡路径

### 问题 3：保持时间违例

**解决方法：**

1. **插入延迟单元**：在快路径插入延迟单元增加延迟
2. **调整有用偏斜**：调整发射时钟延迟增加路径延迟
3. **减小驱动**：用更小驱动增加延迟
- **重新摆放**：增加线长增加延迟

**重要：** 修复保持时间后必须重新检查建立时间，修复保持可能影响建立。

### 问题 4：DRC 违反

**解决方法：**

1. 在工具 GUI 定位错误位置
2. 看违反类型：间距/宽度/密度/天线
3. 分析原因：
   - **间距违反**：移动图形，增加间距
   - **密度违反**：添加填充金属
   - **天线违反**：跳线，插入二极管
   - **过孔违反**：重新排列过孔，增加间距

### 问题 5：LVS 错误

**常见 LVS 错误：**

- **端口不匹配**：网表端口和版图端口数量不同 → 检查顶层端口连接
- **节点短路**：两个应该分开的节点连在一起 → 检查层次，检查电源环切口
- **节点开路**：应该连接的没连上 → 检查blockage是否挡住连接
- **浮动节点**：节点没有连接 → 检查是否真的没用，没用删除

## 工具选择

| 任务 | 商业工具 | 开源工具 |
|------|----------|----------|
| 布局布线 | IC Compiler II (Synopsys), Innovus (Cadence) | OpenROAD |
| 静态时序分析 | PrimeTime (Synopsys), Tempus (Cadence) | OpenSTA |
| 物理验证 | Calibre (Siemens), ICV (Synopsys), PVS (Cadence) | - |

## 检查清单（tapeout 前最终检查）

- [ ] 所有工艺角建立时间满足（WNS ≥ 0）
- [ ] 所有工艺角保持时间满足
- [ ] DRC 零违反
- [ ] LVS 零违反
- [ ] IR 降满足要求
- [ ] 电迁移满足要求
- [ ] 功耗满足预算
- [ ] 面积满足预算
- [ ] GDS 正确层级
- [ ] 所有文档齐全

## 反模式（要避免）

❌ **跳过检查**："先流片回来再说" → 流片回来错了几百万就没了
❌ **忽略保持时间**：建立时间对了就完事 → 保持时间错了芯片不工作
❌ **不检查所有工艺角**：只检查典型工艺角 → 最坏情况不满足
❌ **电源规划太早不优化** → IR 降不够时序都错了
❌ **最后一分钟做大改动** → 引入新错误，没时间验证

## 代理协作

- 使用 `physical-design-engineer` 代理进行物理设计实现
- 使用 `timing-analysis` 技能进行时序分析和修复
- 使用 `power-analysis` 技能进行功耗和 IR 降分析
- 使用 `drc-lvi-debug` 技能进行 DRC/LVS 错误调试
