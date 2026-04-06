---
name: power-analysis
description: 功耗分析和优化技能 - 功耗计算、IR降分析、电迁移分析、低功耗优化
description.zh: 功耗分析和优化技能 - 功耗计算、IR降分析、电迁移分析、低功耗优化
origin: ICER
categories: back-end
---

# 功耗分析和优化技能

当用户需要进行功耗分析和功耗优化时，启用此技能。涵盖从架构级到物理级的低功耗优化，包括 IR 降和电迁移分析。

## When to Activate

- 项目前期功耗预算评估
- 功耗分析结果解读和问题定位
- 低功耗设计优化
- IR 降问题分析和修复
- 电迁移问题分析和修复

---

## 行业经验数值

### 功耗预算经验值

| 芯片类型 | 动态功耗占比 | 静态功耗占比 | 说明 |
|----------|--------------|--------------|------|
| 高性能CPU | 60-70% | 30-40% | 高频率，高漏电 |
| 移动SoC | 70-80% | 20-30% | 平衡设计 |
| 低功耗MCU | 80-90% | 10-20% | 低漏电优化 |
| AI加速器 | 50-60% | 40-50% | 大面积，高漏电 |

### 功耗优化效果

| 方法 | 功耗节省 | 实现复杂度 | 风险 |
|------|----------|------------|------|
| 降低电压 | 20-40% | 低 | 时序风险 |
| 电源门控 | 40-90% | 中 | 面积开销 |
| 时钟门控 | 10-30% | 低 | 低 |
| 多电压域 | 15-25% | 高 | 设计复杂 |
| 动态调频 | 10-40% | 中 | 需要软件支持 |

### IR 降经验值

| 参数 | 典型值 | 说明 |
|------|--------|------|
| IR 降上限 | < 5% Vdd | 必须满足 |
| IR 降目标 | < 3% Vdd | 设计目标 |
| 电源环电流密度 | < 10mA/um | EM 限制 |
| 电源带间距 | 50-100um | 取决于功耗密度 |

### 电迁移经验值

| 金属层 | 典型电流密度 | 说明 |
|--------|--------------|------|
| M1-M2 | 0.5-1.0 mA/um | 细线宽 |
| M3-M5 | 1.0-2.0 mA/um | 中间层 |
| M6-M8 | 2.0-5.0 mA/um | 电源层 |

---

## 故障诊断框架

### 症状1：功耗超标

**诊断步骤：**

```tcl
# 1. 获取功耗报告
report_power -hierarchy

# 2. 按模块分析
report_power -cells -sort_by total

# 3. 分析时钟功耗
report_clock_power

# 4. 分析漏电功耗
report_power -leakage
```

**判断标准：**

| 情况 | 动态功耗占比 | 静态功耗占比 | 诊断 |
|------|--------------|--------------|------|
| 正常 | 70-80% | 20-30% | 按正常流程优化 |
| 静电高 | < 60% | > 40% | 检查漏电路径 |
| 时钟高 | 时钟 > 30% | - | 检查门控效率 |

**根本原因定位：**

| 根本原因 | 诊断特征 | 解决方案 |
|----------|----------|----------|
| 时钟网络功耗高 | 时钟 > 30% | 增加门控时钟 |
| 某模块功耗异常 | 模块占比超预期 | 检查活动性 |
| 漏电功耗高 | 静态 > 40% | 增加电源门控 |
| 存储器功耗高 | Memory > 40% | 检查访问模式 |

### 症状2：IR 降超标

**诊断步骤：**

```tcl
# 1. 运行 IR 分析
run_ir_drop_analysis

# 2. 定位热点
report_ir_drop -threshold 0.05

# 3. 检查电源网格
report_power_grid -resistance

# 4. 检查电流密度
report_current_density
```

**判断标准：**

| IR 降 | 判断 | 行动 |
|-------|------|------|
| < 3% | 良好 | 无需处理 |
| 3-5% | 边缘 | 关注热点 |
| 5-10% | 严重 | 必须优化 |
| > 10% | 极严重 | 需重新设计 PDN |

**根本原因定位：**

| 根本原因 | 诊断特征 | 解决方案 |
|----------|----------|----------|
| 电源环太窄 | 环电流密度高 | 加宽电源环 |
| 电源带不足 | 局部 IR 高 | 增加电源带 |
| 高功耗模块位置差 | 模块处 IR 高 | 调整位置靠近电源 |
| 电源通孔不足 | 通孔电阻高 | 增加过孔 |

### 症状3：电迁移违规

**诊断步骤：**

```tcl
# 1. 运行 EM 分析
run_em_analysis

# 2. 报告违规
report_em_violations

# 3. 按严重程度排序
report_em_violations -sort_by severity
```

**判断标准：**

| EM 违规 | 判断 | 行动 |
|---------|------|------|
| 0 | 通过 | 无需处理 |
| < 10 | 轻微 | 可 waiver |
| 10-100 | 严重 | 必须修复 |
| > 100 | 极严重 | 需重新设计 |

**根本原因定位：**

| 根本原因 | 诊断特征 | 解决方案 |
|----------|----------|----------|
| 线宽太窄 | 线段电流密度高 | 加宽金属 |
| 过孔太少 | 过孔电流密度高 | 增加过孔 |
| 电源网络设计不合理 | 多处违规 | 重新设计 PDN |

---

## 案例研究：功耗超标问题

### 背景
- 项目：某移动 SoC
- 工艺：16nm FinFET
- 功耗预算：800mW
- 实际功耗：1.2W（超标 50%）

### 问题现象
```
Total Power: 1200mW
  Dynamic Power: 900mW (75%)
    Switching: 720mW
    Internal: 180mW
  Leakage Power: 300mW (25%)
```

### 诊断过程

**步骤1：分析功耗分布**
```
模块功耗排序：
CPU: 300mW (25%)
GPU: 280mW (23%)
DDR: 200mW (17%)
Clock: 240mW (20%)  <-- 异常高
其他: 180mW (15%)
```
结论：时钟功耗占比过高

**步骤2：分析门控效率**
```
时钟门控效率：45%
目标：> 90%
```
结论：门控效率太低

**步骤3：检查 RTL**
```systemverilog
// 问题：没有门控条件
always @(posedge clk) begin
    data_out <= data_in;  // 无使能信号
end
```

### 解决方案

| 问题 | 解决方案 | 效果 |
|------|----------|------|
| 门控效率 45% | RTL 增加门控条件 | 效率提升到 85% |
| 时钟功耗 240mW | 综合自动插入门控 | 降至 80mW |
| CPU 未关断 | 增加电源门控 | 空闲功耗降 90% |

### 结果
```
Total Power: 750mW（降低 37%）
  Dynamic Power: 550mW (73%)
  Leakage Power: 200mW (27%)
```
功耗满足预算。

### 经验总结
1. 时钟功耗应 < 30%，否则检查门控效率
2. 门控效率目标 > 90%
3. 大功耗模块考虑电源门控

---
## 步骤 1：理解功耗组成

### 1.1 动态功耗

**公式：**
```
P_dynamic = α × C_load × Vdd² × f
```

- α = 开关活动性（翻转次数比例）
- C_load = 总负载电容
- Vdd = 电源电压
- f = 工作频率

**关键：** 电压对功耗是平方关系，降低电压收益最大。

### 1.2 静态功耗

**公式：**
```
P_static = I_leakage × Vdd
```

- 漏电流导致
- 先进工艺（<28nm）静态功耗占比增加
- 关断电源可以消除静态功耗

### 1.3 功耗占比

| 工艺节点 | 动态功耗占比 | 静态功耗占比 |
|----------|--------------|--------------|
| 40nm | 80-90% | 10-20% |
| 28nm | 70-80% | 20-30% |
| 16nm | 60-70% | 30-40% |
| 7nm | 50-60% | 40-50% |

---

## 步骤 2：运行功耗分析

### 2.1 准备输入数据

- 网表
- 工艺库（带功耗信息）
- 寄生参数
- 开关活动性（VCD/SAIF 文件）

### 2.2 运行功耗分析

**PrimeTime-PX 示例：**

```tcl
# ============================================
# PrimeTime-PX 功耗分析流程
# ============================================

# 1. 读入设计和库
read_verilog design.v
current_design design_name
link

# 2. 读入寄生参数
read_parasitics design.spef

# 3. 读入开关活动性
read_vcd activity.vcd -strip_path testbench.dut
# 或使用 SAIF 文件
read_saif activity.saif

# 4. 设置工作条件
set_operating_conditions -library slow_lib slow

# 5. 计算功耗
update_power

# 6. 生成报告
report_power -hierarchy > power_report.rpt
report_power -cells > cell_power.rpt
report_power -nets > net_power.rpt

# 7. 详细分析
report_power -hierarchy -levels 3 -sort_by total
```

**Voltus 功耗分析示例：**

```tcl
# ============================================
# Voltus 功耗分析流程
# ============================================

# 1. 读入设计
read_netlist design.v
read_physical -def design.def
read_spef design.spef

# 2. 读入开关活动性
read_activity_file -format vcd -file activity.vcd

# 3. 设置功耗分析
set_power_analysis_mode -method static

# 4. 运行功耗分析
run_power_analysis

# 5. 生成报告
report_power -out_file power_report.rpt
report_power -by_hierarchy > power_hierarchy.rpt
```

**开源工具 OpenSTA 功耗分析：**

```tcl
# ============================================
# OpenSTA 功耗分析
# ============================================

# 读入设计
read_liberty slow.lib
read_verilog design.v
link_design design_name

# 读入寄生参数
read_spef design.spef

# 读入开关活动性
read_saif activity.saif

# 功耗报告
report_power
```

### 2.3 解读功耗报告

```
Total Power: 500.000 mW
  Dynamic Power: 400.000 mW (80%)
    Switching Power: 350.000 mW
    Internal Power: 50.000 mW
  Leakage Power: 100.000 mW (20%)
```

---

## 步骤 3：识别高功耗模块

### 3.1 按模块排序

```
Module           Power (mW)   Percentage
--------------------------------------
CPU             150.0        30.0%
DDR_Controller   80.0        16.0%
PCIe_Controller  60.0        12.0%
Clock_Tree       50.0        10.0%
Memory           40.0         8.0%
...
```

### 3.2 定位优化目标

- 高功耗模块优先优化
- 高翻转活动性信号关注
- 大负载网络关注

---

## 步骤 4：架构级功耗优化

**效果最大，越早做越好。**

### 4.1 降低电压

**效果：最大（V² 关系）**

- 关键模块高电压，非关键低电压
- 动态电压调整（DVFS）

### 4.2 电源关断

**效果：大**

- 不使用的模块关断电源
- 需要隔离单元和保持寄存器

### 4.3 时钟门控

**效果：中等**

- 不使用的模块关闭时钟
- 自动插入门控时钟单元

### 4.4 多电压域

**效果：中等**

- 不同模块不同电压
- 需要电平转换器

---

## 步骤 5：RTL 级功耗优化

### 5.1 门控时钟编码

**✅ 好：有使能信号，工具可插入门控**

```systemverilog
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_data <= '0;
    end else if (enable) begin  // 使能条件
        r_data <= i_data;
    end
end
```

### 5.2 操作数隔离

```systemverilog
// 选择通路不使用时停止翻转
always_comb begin
    if (sel == 0) begin
        result = a_operand;  // b_operand 不翻转
    end else begin
        result = b_operand;  // a_operand 不翻转
    end
end
```

### 5.3 格雷码计数器

```systemverilog
// 二进制：每次多位翻转，功耗大
// 格雷码：每次只有一位翻转，功耗小
assign gray = binary ^ (binary >> 1);
```

### 5.4 低功耗设计模式详细示例

#### 门控时钟（Clock Gating）

```systemverilog
// ============================================
// 门控时钟实现
// ============================================

// 方式 1：使用综合器自动插入的门控单元
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_reg <= '0;
    end else if (enable) begin  // 综合器自动插入门控
        data_reg <= data_in;
    end
end

// 方式 2：手动实例化门控单元
module clock_gating_example (
    input  wire        clk,
    input  wire        enable,
    input  wire [31:0] data_in,
    output reg  [31:0] data_out
);
    wire gated_clk;
    
    // 门控单元实例化
    CLK_GATE_CELL u_clk_gate (
        .CLK   (clk),
        .EN    (enable),
        .GCLK  (gated_clk)
    );
    
    always_ff @(posedge gated_clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= '0;
        end else begin
            data_out <= data_in;
        end
    end
endmodule
```

#### 电源关断（Power Gating）

```systemverilog
// ============================================
// 电源关断设计
// ============================================

module power_gating_example (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        power_enable,  // 电源使能信号
    input  wire [31:0] data_in,
    output wire [31:0] data_out
);
    // 电源域隔离信号
    wire [31:0] isolated_data;
    
    // 隔离单元 - 电源关闭时输出固定值
    ISO_CELL u_iso [31:0] (
        .DATA_IN (data_in),
        .ISO_EN  (~power_enable),
        .DATA_OUT(isolated_data)
    );
    
    // 电源开关单元
    SWITCH_CELL u_switch (
        .VDD_IN (VDD_TOP),
        .VDD_OUT(VDD_BLOCK),
        .EN     (power_enable)
    );
    
    // 电源域内逻辑
    // ... 使用 isolated_data 作为输入
    
endmodule
```

#### 多电压域设计

```systemverilog
// ============================================
// 多电压域设计示例
// ============================================

// UPF 定义
/*
    create_power_domain TOP
    create_power_domain HIGH_PERF -domain TOP -elements {cpu}
    create_power_domain LOW_POWER -domain TOP -elements {peripheral}
    
    create_supply_net VDD_HIGH
    create_supply_net VDD_LOW
    
    set_domain_supply_net HIGH_PERF -primary_power_net VDD_HIGH
    set_domain_supply_net LOW_POWER -primary_power_net VDD_LOW
    
    // 电平转换器
    create_level_shifter LS_HIGH_TO_LOW \
        -domain HIGH_PERF \
        -input_supply VDD_HIGH \
        -output_supply VDD_LOW
*/

// RTL 设计考虑
module multi_voltage_design (
    input  wire        clk_high,
    input  wire        clk_low,
    input  wire [31:0] cpu_data,    // 来自高电压域
    output wire [31:0] peri_data    // 到低电压域
);
    // 跨电压域信号需要电平转换器
    // 综合器会根据 UPF 自动插入
    
endmodule
```

#### 操作数隔离

```systemverilog
// ============================================
// 操作数隔离技术
// ============================================

module operand_isolation (
    input  wire        clk,
    input  wire [1:0]  sel,
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [31:0] c,
    input  wire [31:0] d,
    output reg  [31:0] result
);
    // 不使用操作数隔离 - 所有输入都在翻转
    // result = (sel == 0) ? a + b : c + d;
    
    // 使用操作数隔离 - 只有选中的通路翻转
    wire [31:0] a_iso, b_iso, c_iso, d_iso;
    
    // 隔离逻辑
    assign a_iso = (sel == 0) ? a : 32'b0;
    assign b_iso = (sel == 0) ? b : 32'b0;
    assign c_iso = (sel == 1) ? c : 32'b0;
    assign d_iso = (sel == 1) ? d : 32'b0;
    
    // 或者使用专用的隔离单元
    // ISO_CELL u_iso_a [31:0] (.DATA_IN(a), .ISO_EN(sel[0]), .DATA_OUT(a_iso));
    
    always_ff @(posedge clk) begin
        case (sel)
            2'b00: result <= a_iso + b_iso;
            2'b01: result <= c_iso + d_iso;
            default: result <= 32'b0;
        endcase
    end
endmodule
```

---

## 步骤 6：物理级功耗优化

### 6.1 移除死代码

- 删除未使用的逻辑
- 减少电容

### 6.2 优化缓冲

- 不必要的大驱动换成小驱动
- 减少短路功耗

### 6.3 线长优化

- 关键路径线长优化
- 减少负载电容

---

## 步骤 7：IR 降分析

### 7.1 什么是 IR 降

电源网络有电阻，电流流过产生电压降：

```
V_used = V_supply - I × R
```

### 7.2 IR 降影响

- 局部电压降低 → 单元延迟增加 → 时序违例
- 严重 IR 降 → 功能错误

### 7.3 IR 降检查标准

```
最大 IR 降 < 5% × Vdd
```

### 7.4 IR 降优化方法

| 方法 | 效果 |
|------|------|
| 增加电源线宽 | 降低电阻 |
| 增加电源 strap 密度 | 降低电阻 |
| 高功耗模块靠近电源 pad | 减少距离 |
| 多层电源 | 降低电阻 |
| 去耦电容 | 维持电压稳定 |

### 7.5 IR 降分析详细流程

**RedHawk IR 降分析：**

```tcl
# ============================================
# RedHawk IR 降分析流程
# ============================================

# 1. 设置设计
load_design design.gds

# 2. 加载库文件
load_techfile tech.tf
load_lef tech.lef
load_lib .lib

# 3. 加载电源网络
load_def design.def
load_spef design.spef

# 4. 设置功耗源
set_power_source -file power_sources.pwr

# 5. 运行 IR 降分析
run_ir_drop_analysis

# 6. 生成报告
report_ir_drop -out_file ir_drop.rpt
report_ir_drop -threshold 0.05  # 报告超过 5% 的 IR 降

# 7. 可视化
plot_ir_drop_map
```

**Voltus IR 降分析：**

```tcl
# ============================================
# Voltus IR 降分析流程
# ============================================

# 1. 设置分析模式
set_power_analysis_mode -method static -analysis_view typical

# 2. 配置电源网格
set_power_grid -net VDD -layer M8 -width 2.0 -pitch 50
set_power_grid -net VSS -layer M8 -width 2.0 -pitch 50

# 3. 运行 IR 降分析
run_static_ir_drop

# 4. 生成报告
report_static_ir_drop -out_file ir_drop.rpt
report_static_ir_drop -threshold 5.0  # 5% 阈值

# 5. 热点分析
identify_ir_hotspots
```

---

## 步骤 8：电迁移分析

### 8.1 什么是电迁移

大电流流过金属，电子撞击金属原子，导致原子迁移，最终断路。

### 8.2 检查标准

```
电流密度 < 最大允许电流密度（工艺给定）
```

### 8.3 电迁移优化方法

| 方法 | 效果 |
|------|------|
| 增加线宽 | 降低电流密度 |
| 并联多根线 | 分散电流 |
| 使用上层金属 | 更厚，允许更大电流 |
| 过孔并联 | 分散电流 |

### 8.4 电迁移分析详细流程

**RedHawk 电迁移分析：**

```tcl
# ============================================
# RedHawk 电迁移分析流程
# ============================================

# 1. 设置电迁移规则
load_em_rules em_rules.txt

# 2. 运行电迁移分析
run_em_analysis

# 3. 生成报告
report_em_violations -out_file em_report.rpt

# 4. 热点定位
identify_em_hotspots

# 5. 详细报告
report_em_details -net VDD -out_file vdd_em.rpt
report_em_details -net VSS -out_file vss_em.rpt
```

**Voltus 电迁移分析：**

```tcl
# ============================================
# Voltus 电迁移分析流程
# ============================================

# 1. 设置分析模式
set_power_analysis_mode -method static

# 2. 加载电迁移规则
load_em_rules em_rules.cmd

# 3. 运行电迁移分析
run_em_analysis

# 4. 生成报告
report_em_violations -out_file em_report.rpt

# 5. 按严重程度排序
report_em_violations -sort_by severity -threshold 1.0
```

### 8.5 电迁移违规修复策略

```tcl
# ============================================
# 电迁移修复示例
# ============================================

# 1. 增加线宽
# 找到违规网络
set em_violations [get_em_violations -threshold 1.0]
foreach violation $em_violations {
    set net_name [get_attribute $violation net_name]
    set wire_width [get_attribute $violation wire_width]
    set required_width [get_attribute $violation required_width]
    
    # 增加线宽
    change_wire_width -net $net_name -width $required_width
}

# 2. 增加过孔
# 对于过孔电迁移违规
add_via_array -net VDD -rows 2 -columns 2

# 3. 添加去耦电容
# 同时帮助 IR 降和电迁移
add_decoupling_capacitor -location {x y} -cap_value 10pF
```

---

## 最终检查清单

- [ ] 总功耗满足预算
- [ ] 最大 IR 降 < 5% Vdd
- [ ] 电迁移满足要求
- [ ] 门控时钟插入率 > 90%
- [ ] 高功耗模块已优化

---

## 反模式（要避免）

❌ **不做功耗分析就流片** → 功耗超标，芯片过热

❌ **忽略 IR 降** → 时序不满足

❌ **电迁移不检查** → 可靠性问题

❌ **低功耗优化只在物理级做** → 架构级优化收益最大

---

## 工具支持

| 工具 | 公司 |
|------|------|
| PrimePower | Synopsys |
| Voltus | Cadence |
| RedHawk | ANSYS |

---

## 代理协作

- 使用 `physical-design-engineer` 代理进行物理设计
- IR 降修复后重新运行时序分析
