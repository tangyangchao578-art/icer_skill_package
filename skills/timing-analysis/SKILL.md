---
name: timing-analysis
description: 静态时序分析技能 - 时序诊断、收敛优化、签收标准
description.zh: 静态时序分析技能 - 时序诊断、收敛优化、签收标准
origin: ICER
categories: back-end
---

# 静态时序分析技能

当用户需要进行静态时序分析、时序诊断和时序收敛时，启用此技能。提供时序结果解读、问题诊断、优化策略。

## When to Activate

- 静态时序分析结果解读
- 时序违例诊断和修复
- 时序收敛优化
- 多工艺角时序分析
- OCV/MMMC 分析
- 时序签收

---

## 行业经验数值

### 时序设计经验值

| 参数 | 28nm | 16nm | 7nm | 说明 |
|------|------|------|-----|------|
| 逻辑级数上限 | 8-10级 | 6-8级 | 4-6级 | 超过需流水线分割 |
| 典型单元延迟 | 50-80ps | 30-50ps | 15-30ps | NAND2_X1 |
| 典型线延迟/um | 0.5-1ps | 0.3-0.5ps | 0.2-0.3ps | M2层 |
| Setup Margin | 100-200ps | 50-100ps | 30-50ps | 签收裕量 |
| Hold Margin | 50-100ps | 30-50ps | 20-30ps | 保持裕量 |

### 时钟设计经验值

| 参数 | 典型值 | 说明 |
|------|--------|------|
| Clock Skew | < 100ps | 同时钟域内 |
| Clock Latency | 1-3ns | 取决于芯片大小 |
| Clock Transition | < 100ps | 时钟转换时间 |
| Clock Uncertainty | 50-150ps | 时钟不确定性 |

### 扇出设计经验值

| 驱动类型 | 建议扇出 | 最大扇出 | 超过后果 |
|----------|----------|----------|----------|
| 时钟网络 | 8-16 | 32 | skew增大、转换时间变差 |
| 控制信号 | 4-8 | 16 | 延迟增大、时序违例 |
| 数据信号 | 4-6 | 8 | 延迟增大、负载过大 |

---

## 故障诊断框架

### 症状分类与诊断流程

#### 症状1：WNS 持续为负

**诊断步骤1：分析时序报告**

```tcl
# 获取详细时序信息
report_timing -max_paths 100 -slack_lesser_than 0 \
              -input_pins -nets -caps -transition_time

# 分析延迟组成
report_delay_calculation -from [get_pins start/Q] -to [get_pins end/D]
```

**判断标准：**

| Cell Delay 占比 | Net Delay 占比 | 可能原因 | 诊断动作 |
|-----------------|----------------|----------|----------|
| > 60% | < 40% | 逻辑级数过多/驱动不足 | 检查逻辑深度、单元驱动 |
| < 40% | > 60% | 线长过长/扇出过大 | 检查布局、扇出 |
| ≈ 50% | ≈ 50% | 综合问题 | 分析关键路径细节 |

**诊断步骤2：检查约束正确性**

```tcl
# 验证时钟定义
report_clock -skew -latency

# 检查假路径
report_false_path

# 检查多周期路径
report_multicycle_path

# 检查输入输出延迟
report_port -delay
```

**诊断步骤3：定位根本原因**

| 根本原因 | 诊断特征 | 解决方案优先级 |
|----------|----------|----------------|
| 逻辑级数过多 | logic_depth > 10 | 1.流水线分割 2.逻辑重构 |
| 扇出过大 | fanout > 16 | 1.复制寄存器 2.插buffer |
| 线长过长 | net_length > 500um | 1.重新摆放 2.插buffer |
| 驱动不足 | slew > 100ps | 1.换大驱动 2.减负载 |
| 约束错误 | false path missing | 修正约束 |

#### 症状2：TNS 远大于 WNS

**现象：** TNS >> WNS（如 WNS=-100ps, TNS=-10000ps）

**诊断：** 不只是几条路径有问题，而是模块级问题

| 可能原因 | 诊断方法 | 解决方案 |
|----------|----------|----------|
| 模块时序预算不足 | 检查模块边界约束 | 调整时序预算 |
| 时钟质量问题 | 检查 CTS 报告 | 重做 CTS |
| 电源问题 | 检查 IR 降报告 | 修复电源网络 |

#### 症状3：保持时间违例

**诊断步骤：**

```tcl
# 分析保持时间违例
report_timing -delay_type min -max_paths 50

# 检查时钟偏斜
report_clock_timing -type skew
```

**根本原因分析：**

| 现象 | 可能原因 | 解决方案 |
|------|----------|----------|
| 同一模块大量违例 | CTS 问题 | 检查时钟树、重做 CTS |
| 随机分布 | 局部时钟偏斜大 | 插入 delay buffer |
| 修复后反复出现 | 工艺角覆盖不全 | 检查所有工艺角 |

#### 症状4：不同工艺角结果矛盾

**现象：** SS 工艺角满足，FF 工艺角不满足（或相反）

**诊断：**

```tcl
# 比较 SS 和 FF 工艺角
report_timing -max_paths 10 > timing_ss.rpt
current_scenario ff
report_timing -max_paths 10 > timing_ff.rpt
```

**原因与解决方案：**

| 矛盾情况 | 原因 | 解决方案 |
|----------|------|----------|
| SS 违例, FF OK | 建立时间问题 | 优化关键路径延迟 |
| FF 违例, SS OK | 保持时间问题 | 插入 delay buffer |
| 都违例 | 约束错误或设计问题 | 检查约束、重新评估 |

---

## 步骤 1：理解基本概念

### 1.1 建立时间（Setup Time）

**定义：** 数据需要在下一个时钟沿之前稳定到达。

**计算公式：**
```
Setup Slack = Required Time - Arrival Time
           = (Clock Period + Clock Skew) - (Launch Clock + Data Delay)
```

- Slack ≥ 0 → 满足
- Slack < 0 → 违例，路径太慢

### 1.2 保持时间（Hold Time）

**定义：** 数据需要在时钟沿之后保持稳定，不能太快到达。

**计算公式：**
```
Hold Slack = Arrival Time - Required Time
           = (Launch Clock + Data Delay) - (Capture Clock + Hold Time)
```

- Slack ≥ 0 → 满足
- Slack < 0 → 违例，路径太快

### 1.3 关键术语

| 术语 | 含义 |
|------|------|
| **WNS** | Worst Negative Slack，最差的负 slack |
| **TNS** | Total Negative Slack，所有负 slack 总和 |
| **NP** | Number of Paths，违例路径数量 |
| **OCV** | On-Chip Variation，片上变化 |
| **CPPR** | Clock Path Pessimism Removal，去除时钟路径悲观 |
| **Logic Depth** | 逻辑深度，路径上逻辑单元数量 |
| **Fanout** | 扇出，一个信号驱动的负载数量 |

---

## 步骤 2：运行静态时序分析

### 2.1 准备输入数据

**需要准备：**
- 网表（.v 或 .v.gz）
- 工艺库（.lib 或 .db）
- 时序约束（.sdc）
- 寄生参数（.spef）

### 2.2 运行 STA

**PrimeTime 示例：**

```tcl
# 读入库文件
set link_library [list *.lib]

# 读入网表
read_verilog design.v

# 链接设计
current_design design_name
link

# 读入约束
read_sdc constraints.sdc

# 读入寄生参数
read_parasitics design.spef

# 运行时序分析
update_timing

# 生成报告
report_timing -max_paths 100 -slack_lesser_than 0
report_timing -delay_type min -max_paths 100
report_constraint -all_violators
```

### 2.3 MMMC 分析设置

**为什么需要 MMMC：** 单一工艺角分析无法覆盖所有工作条件

```tcl
# 创建场景
create_scenario -name func_ss_125c
create_scenario -name func_ff_-40c
create_scenario -name test_ss_125c

# 设置每个场景的操作条件
current_scenario func_ss_125c
set_operating_conditions -library slow_lib slow_125c

current_scenario func_ff_-40c
set_operating_conditions -library fast_lib fast_-40c

# 运行分析
report_timing -scenarios {func_ss_125c func_ff_-40c}
```

### 2.4 必须检查的工艺角

| 工艺角 | 晶体管速度 | 电压 | 温度 | 最容易出现 |
|--------|------------|------|------|------------|
| **FF** | 快-快 | 高 | 低 | 保持时间违例 |
| **SS** | 慢-慢 | 低 | 高 | 建立时间违例 |
| **TT** | 典型 | 典型 | 典型 | 参考 |
| **FS** | 快N慢P | 典型 | 典型 | 混合偏差 |
| **SF** | 慢N快P | 典型 | 典型 | 混合偏差 |

---

## 步骤 3：解读时序报告

### 3.1 查看汇总信息

**第一步：看整体结果**

```
Report: Timing Summary
  WNS: -0.234 ns (Setup)
  TNS: -12.567 ns (Setup)
  NP: 156 paths

  WNS: -0.045 ns (Hold)
  TNS: -1.234 ns (Hold)
  NP: 23 paths
```

**解读方法：**

| 指标 | 值 | 判断 |
|------|-----|------|
| WNS | ≥ 0 | 满足 |
| WNS | -100ps ~ 0 | 接近收敛，小幅优化 |
| WNS | < -500ps | 严重问题，需要重构 |
| TNS/WNS | > 10 | 多条路径问题，模块级优化 |
| TNS/WNS | < 5 | 少数路径问题，针对性优化 |

### 3.2 分析关键路径

**第二步：分析关键路径详情**

```
Startpoint: reg1/CK (rising edge-triggered flip-flop)
Endpoint:   reg2/D (rising edge-triggered flip-flop)
Path Group: clk
Path Type:  max

Point                   Incr       Path
--------------------------------------------------
clock clk (rise edge)   0.000      0.000
clock network delay     0.200      0.200
reg1/CK                 0.000      0.200 r
reg1/Q                  0.150      0.350 f    <- 检查转换时间
comb1/Z                 0.300      0.650 f    <- 延迟最大的单元
comb2/Z                 0.250      0.900 f
comb3/Z                 0.200      1.100 r
reg2/D                  0.000      1.100 r
data arrival time                  1.100

clock clk (rise edge)   1.000      1.000
clock network delay     0.200      1.200
clock uncertainty      -0.050      1.150
reg2/setup time        -0.050      1.100
data required time                 1.100
--------------------------------------------------
slack                              0.000
```

**分析要点：**

1. **统计单元延迟**
   - 数逻辑级数（此例：4级）
   - 找最大延迟单元（comb1: 300ps）

2. **检查转换时间**
   - 查看每个端点的转换时间
   - 转换时间过大 → 驱动不足

3. **检查线延迟**
   - 线延迟占比高 → 布局问题

4. **检查时钟路径**
   - 时钟网络延迟是否合理
   - 时钟不确定性是否合理

### 3.3 分类违例

**第三步：分类违例**

| 分类 | 特征 | 策略 |
|------|------|------|
| 集中在某模块 | 模块时序预算不足 | 调整模块约束或重构 |
| 都是长路径 | 逻辑级数过多 | 流水线分割 |
| 都是高扇出 | 扇出过大 | 复制寄存器 |
| 随机分布 | 整体优化 | 综合优化 |

---

## 步骤 4：修复建立时间违例

**建立时间违例 = 路径太慢**

### 4.1 优化方法选择决策树

```
建立时间违例
    │
    ├── 逻辑级数 > 10？
    │       ├── 是 → 流水线分割（最有效）
    │       └── 否 → 检查延迟组成
    │
    ├── Cell Delay > 60%？
    │       ├── 是 → 检查驱动强度
    │       │       ├── 驱动太小 → 换大驱动
    │       │       └── 扇出太大 → 复制寄存器
    │       └── 否 → 检查线延迟
    │
    ├── Net Delay > 60%？
    │       ├── 是 → 布局问题
    │       │       ├── 线太长 → 重新摆放
    │       │       └── 拥塞 → 优化布线
    │       └── 否 → 继续分析
    │
    └── 接近收敛？
            ├── 是 → 有用偏斜
            └── 否 → 重新评估设计
```

### 4.2 优化方法详解

| 方法 | 效果 | 适用场景 | 操作 |
|------|------|----------|------|
| 流水线分割 | 最大 | 逻辑级数 > 10 | 插入寄存器 |
| 换更大驱动 | 中等 | 负载大、转换时间差 | 替换单元 |
| 复制高扇出 | 中等 | 扇出 > 16 | 复制寄存器 |
| 重新摆放 | 中等 | 线太长 | 优化布局 |
| 有用偏斜 | 小 | 接近收敛 | 调整时钟 |

### 4.3 流水线分割示例

**问题：** 长组合逻辑路径延迟太大

```systemverilog
// ❌ 问题：一级组合逻辑 32 级进位，延迟太大
always @(*) begin
    for (i = 0; i < 32; i = i + 1) begin
        c[i+1] = a[i] & b[i] | c[i] & (a[i] ^ b[i]);
    end
end
```

**解决：** 分成两级流水

```systemverilog
// ✅ 解决：分成两级流水
always @(posedge clk) begin
    // 第一级：低 16 位
    level1_c <= lower_16_bits_calculation;
end

always @(*) begin
    // 第二级：高 16 位 + 第一级结果
    final_result = upper_16_bits + level1_c;
end
```

### 4.4 PrimeTime 优化命令

```tcl
# 分析关键路径
report_timing -max_paths 20 -input_pins -nets -caps

# 识别高扇出网络
report_net_fanout -threshold 16

# 分析延迟组成
report_delay_calculation -from [get_pins start/Q] -to [get_pins end/D]

# 自动优化建议
report_qor
```

---

## 步骤 5：修复保持时间违例

**保持时间违例 = 路径太快**

### 5.1 优化方法

| 方法 | 效果 | 操作 | 注意 |
|------|------|------|------|
| 插入延迟单元 | 最大 | 在快路径插入 buffer | 可能影响建立时间 |
| 调整有用偏斜 | 中等 | 调整发射时钟延迟 | 需要时钟树控制 |
| 换更小驱动 | 中等 | 减小驱动强度 | 选择有限 |
| 重新摆放 | 小 | 增加线长 | 效果不确定 |

### 5.2 插入延迟单元示例

```
问题路径：
reg1/Q -> [comb: 0.2ns] -> reg2/D
保持时间要求：0.3ns
Slack = 0.2 - 0.3 = -0.1ns（违例）

解决：插入 buffer
reg1/Q -> [comb: 0.2ns] -> [buffer: 0.15ns] -> reg2/D
Slack = 0.35 - 0.3 = 0.05ns（满足）
```

### 5.3 保持时间修复流程

```
1. 分析保持时间违例路径
2. 计算需要的延迟量
3. 选择合适的 buffer
4. 插入 buffer
5. 重新检查建立时间（重要！）
6. 检查所有工艺角
```

> ⚠️ **重要提醒：** 修复保持时间后，必须重新检查建立时间！
> 增加延迟会改善保持时间，但可能恶化建立时间。

---

## 步骤 6：OCV 分析

### 6.1 什么是 OCV

同一芯片上，相同类型的单元速度也可能不同：
- 制造工艺偏差
- 电压偏差
- 温度偏差

### 6.2 OCV 分析设置

**PrimeTime 示例：**

```tcl
# 设置 OCV 降额
set_timing_derate -early 0.90 -cell_delay
set_timing_derate -late 1.10 -cell_delay

# 打开 CPPR
set timing_remove_clock_reconvergence_pessimism true

# 运行分析
update_timing
report_timing -max_paths 100
```

### 6.3 OCV 降额因子选择

| 工艺节点 | Early Derate | Late Derate | 说明 |
|----------|--------------|-------------|------|
| 28nm | 0.92 | 1.08 | 标准值 |
| 16nm | 0.90 | 1.10 | 先进节点 |
| 7nm | 0.88 | 1.12 | 更大偏差 |

---

## 步骤 7：时序签收

### 7.1 签收标准

| 检查项 | 标准 | 说明 |
|--------|------|------|
| Setup WNS | ≥ 0 | 所有工艺角 |
| Hold WNS | ≥ 0 | 所有工艺角 |
| TNS | = 0 | 无违例路径 |
| OCV | 满足 | OCV 分析通过 |
| CPPR | 已打开 | 去除悲观 |

### 7.2 签收检查清单

- [ ] 所有工艺角 WNS ≥ 0
- [ ] 所有工艺角 Hold WNS ≥ 0
- [ ] TNS = 0
- [ ] OCV 分析满足
- [ ] CPPR 已打开
- [ ] 没有 false path 遗漏
- [ ] 所有时钟都已定义
- [ ] 输入输出延迟已设置
- [ ] 时钟不确定性已设置

### 7.3 生成最终报告

```tcl
# 生成所有工艺角汇总报告
report_timing -max_paths 100 -slack_lesser_than 0 > setup_violators.rpt
report_timing -delay_type min -max_paths 100 > hold_violators.rpt
report_constraint -all_violators > all_violators.rpt
report_timing_summary > timing_summary.rpt
report_clock_timing -type summary > clock_summary.rpt

# QoR 汇总
report_qor > qor_summary.rpt
```

---

## 案例研究

### 案例：DDR 控制器时序收敛问题

**背景：**
- 项目：某 SoC 芯片
- 工艺：16nm FinFET
- 目标频率：1.2GHz
- 问题：SS 工艺角 WNS = -800ps

**问题现象：**
```
Path 1: SLACK = -800ps (VIOLATED)
  Startpoint: ddr_phy/data_out_reg
  Endpoint: ddr_controller/din_reg
  Path Group: clk_ddr
  Data Path Delay: 1.2ns
  Logic Levels: 12
```

**诊断过程：**

**步骤1：分析延迟组成**
```
Cell Delay: 400ps (33%)
Net Delay: 800ps (67%)  <-- 异常高
```
结论：Net Delay 占比过高，问题在布线

**步骤2：检查布局**
```
ddr_phy 位置: (100, 100)
ddr_controller 位置: (800, 800)
距离: 约1mm
```
结论：模块距离过远，线长过大

**步骤3：检查扇出**
```
data_out_reg fanout: 48  <-- 异常高
```
结论：扇出过大，每个接收端负载过重

**解决方案：**

| 措施 | 效果 |
|------|------|
| 重新布局：将 ddr_controller 移至距 PHY 200um 处 | 线长减少 75% |
| 寄存器复制：将 data_out_reg 复制为 4 份 | 扇出降为 12 |
| 插入 buffer：在长线上插入 buffer 链 | 改善信号完整性 |

**结果：**
```
Path 1: SLACK = +50ps (MET)
  Data Path Delay: 650ps
  Logic Levels: 12
```
WNS 从 -800ps 改善到 +50ps，时序收敛。

**经验总结：**
1. DDR 路径对布局敏感，应优先处理
2. 高扇出网络必须复制寄存器
3. 数据通路不能太长，建议 < 500um

---

## 高级主题：时序约束编写

### Generated Clock

```tcl
# 正确设置派生时钟
create_generated_clock -name clk_div2 \
                       -source [get_pins pll/clk_out] \
                       -divide_by 2 \
                       [get_pins div/clk_out]

# 注意：派生时钟的 master clock 必须正确定义
```

### 异步时钟域

```tcl
# 设置异步时钟组
set_clock_groups -asynchronous \
                 -group [get_clocks clk_sys] \
                 -group [get_clocks clk_ddr] \
                 -group [get_clocks clk_peri]

# 或使用 false path
set_false_path -from [get_clocks clk_sys] -to [get_clocks clk_ddr]
```

### Input/Output Delay

```tcl
# 输入延迟：外部芯片到本芯片的延迟
set_input_delay -max 2.0 -clock clk [get_ports data_in]
set_input_delay -min 0.5 -clock clk [get_ports data_in]

# 输出延迟：本芯片到外部芯片的延迟
set_output_delay -max 2.0 -clock clk [get_ports data_out]
set_output_delay -min 0.5 -clock clk [get_ports data_out]
```

---

## 工具支持

| 工具 | 公司 | 用途 |
|------|------|------|
| PrimeTime | Synopsys | 工业界标准 |
| Tempus | Cadence | 主流 |
| OpenSTA | 开源 | 免费 |

---

## 反模式（要避免）

❌ **只检查典型工艺角**：TT 不代表最坏情况

❌ **忽略 CPPR**：结果悲观，过度优化

❌ **修复保持后不检查建立**：可能引入新问题

❌ **过度使用 false path**：可能掩盖真正的问题

❌ **不看 TNS 只看 WNS**：可能漏掉模块级问题

❌ **不分析延迟组成直接优化**：可能选错优化方法

---

## 代理协作

- 使用 `physical-design-engineer` 代理进行物理设计实现
- 使用 `timing-engineer` 代理进行时序分析和优化
- 时序修复后重新运行物理验证
- 配合 `power-engineer` 进行功耗时序权衡
