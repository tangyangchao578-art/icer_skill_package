---
name: timing-analysis
description: 静态时序分析技能 - 时序分析解读和时序收敛优化
description.zh: 静态时序分析技能 - 时序分析解读和时序收敛优化
origin: ICER
categories: back-end
---

# 静态时序分析技能

当用户需要进行静态时序分析和时序收敛时，启用此技能。提供时序结果解读、违例调试、优化策略。

## When to Activate

- 静态时序分析结果解读
- 时序违例调试
- 时序收敛优化
- 多工艺角时序分析
- OCV 分析

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

### 2.3 运行多工艺角分析

**必须检查的工艺角：**

| 工艺角 | 晶体管速度 | 电压 | 温度 | 最容易出现 |
|--------|------------|------|------|------------|
| **FF** | 快-快 | 高 | 低 | 保持时间违例 |
| **SS** | 慢-慢 | 低 | 高 | 建立时间违例 |
| **TT** | 典型 | 典型 | 典型 | 参考 |
| **FS** | 快N慢P | 典型 | 典型 | 混合偏差 |
| **SF** | 慢N快P | 典型 | 典型 | 混合偏差 |

**要求：所有工艺角都必须满足时序要求。**

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

**解读：**
- WNS < 0 → 有违例
- TNS 越大 → 整体情况越差
- NP 越多 → 需要修复的路径越多

### 3.2 分析最差路径

**第二步：分析最差路径详情**

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
reg1/Q                  0.150      0.350 f
comb1/Z                 0.300      0.650 f
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
- 看单元延迟占比
- 看线延迟占比
- 找出哪个延迟最大

### 3.3 分类违例

**第三步：分类违例**

- 都是同一个模块 → 优化这个模块
- 都是长路径 → 流水线分割
- 随机分布 → 整体优化

---

## 步骤 4：修复建立时间违例

**建立时间违例 = 路径太慢**

### 4.1 优化方法（按效果排序）

| 方法 | 效果 | 适用场景 | 操作 |
|------|------|----------|------|
| 流水线分割 | 最大 | 长组合逻辑 | 插入寄存器 |
| 换更大驱动 | 中等 | 负载大 | 替换单元 |
| 复制高扇出 | 中等 | 扇出大 | 复制寄存器 |
| 重新摆放 | 中等 | 线太长 | 优化布局 |
| 有用偏斜 | 小 | 接近收敛 | 调整时钟 |

### 4.2 流水线分割示例

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

### 4.3 检查修复结果

- 重新运行 STA
- 检查 WNS 是否改善
- 检查是否引入新的违例

---

## 步骤 5：修复保持时间违例

**保持时间违例 = 路径太快**

### 5.1 优化方法

| 方法 | 效果 | 操作 |
|------|------|------|
| 插入延迟单元 | 最大 | 在快路径插入 buffer |
| 调整有用偏斜 | 中等 | 调整发射时钟延迟 |
| 换更小驱动 | 中等 | 减小驱动强度 |
| 重新摆放 | 小 | 增加线长 |

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

### 5.3 重要提醒

> ⚠️ 修复保持时间后，必须重新检查建立时间！
>
> 增加延迟会改善保持时间，但可能恶化建立时间。

---

## 步骤 6：多工艺角收敛

### 6.1 检查所有工艺角

**必须检查：**
- FF（快-快，高电压，低温）：保持时间最差
- SS（慢-慢，低电压，高温）：建立时间最差
- TT（典型）：参考
- FS/SF（混合）：覆盖工艺偏差

### 6.2 工艺角收敛策略

```
1. 先修复 SS 工艺角的建立时间违例
2. 再修复 FF 工艺角的保持时间违例
3. 检查所有工艺角
4. 迭代，直到所有工艺角都满足
```

---

## 步骤 7：OCV 分析

### 7.1 什么是 OCV

同一芯片上，相同类型的单元速度也可能不同：
- 制造工艺偏差
- 电压偏差
- 温度偏差

### 7.2 OCV 分析设置

**PrimeTime 示例：**

```tcl
# 设置 OCV 降额
set_timing_derate -early 0.90 -cell_delay
set_timing_derate -late 1.10 -cell_delay

# 打开 CPPR
set timing_remove_clock_reconvergence_pessimism true
```

### 7.3 检查 OCV 结果

- 检查 OCV 分析是否满足
- CPPR 是否打开
- 降额因子是否正确

---

## 步骤 8：时序签收

### 8.1 最终检查清单

- [ ] 所有工艺角 WNS ≥ 0
- [ ] 所有工艺角 TNS = 0
- [ ] 所有保持时间满足
- [ ] OCV 分析满足
- [ ] CPPR 已打开
- [ ] 没有 false path 遗漏
- [ ] 所有时钟都已定义

### 8.2 生成最终报告

```tcl
# 生成所有工艺角汇总报告
report_timing -max_paths 100 -slack_lesser_than 0 > setup_violators.rpt
report_timing -delay_type min -max_paths 100 > hold_violators.rpt
report_constraint -all_violators > all_violators.rpt
report_timing_summary > timing_summary.rpt
```

---

## 常见问题

### Q: 建立时间和保持时间哪个更难修复？

A: 保持时间更难修复：
1. 修复保持需要增加延迟，选择少
2. 修复保持可能影响建立时间
3. 修复保持通常在布局布线之后，不能大改

### Q: 为什么 FF 工艺角保持时间最差？

A: FF 工艺角单元最快：
- 数据路径最快 → 数据到达太快
- 时钟路径也快 → 时钟偏斜可能更大
- 所以保持时间违例最容易出现

### Q: WNS 和 TNS 哪个更重要？

A: 都重要：
- WNS 告诉你最差的路径
- TNS 告诉你整体情况
- 修复优先看 WNS，收敛优先看 TNS

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

---

## 代理协作

- 使用 `physical-design-engineer` 代理进行物理设计实现
- 时序修复后重新运行物理验证
