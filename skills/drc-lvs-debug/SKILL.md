---
name: drc-lvi-debug
description: DRC/LVS 调试技能 - DRC/LVS/ERC 错误调试和修复
description.zh: DRC/LVS 调试技能 - DRC/LVS/ERC 错误调试和修复
origin: ICER
categories: back-end
---

# DRC/LVS 调试技能

当用户需要调试 DRC/LVS 违反时，启用此技能。提供 DRC/LVS/ERC/天线错误定位分析和修复步骤。

## When to Activate

- 物理验证后 DRC 违反调试
- LVS 违反调试
- ERC 违反调试
- 天线效应违反调试
- 密度违反调试

## DRC 调试流程

### 完整调试步骤

---

#### 步骤 1：理解违反类型

先看错误信息，确定是什么类型违反：

| 违反类型 | 原因 |
|----------|------|
| **最小间距** | 两个图形距离太近，小于工艺允许最小值 |
| **最小宽度** | 线宽小于工艺允许最小值 |
| **区域密度** | 金属密度超出允许范围（太高或太低） |
| **天线效应** | 长连线暴露在蚀刻，电荷积累击穿栅氧 |
| **过孔间距** | 过孔距离太近 |
| **端点扩展** | 线端点扩展不足 |
| **金属搭接** | 过孔和金属搭接不足 |

---

#### 步骤 2：定位位置

- 在工具 GUI 中打开违反位置
- 放大查看周围环境
- 确定属于哪个模块
- 确定哪个网络出问题

---

#### 步骤 3：分析原因

问自己：

- 这是自动布线产生的还是手动布线产生的？
- 模块摆放太近导致？
- 电源 strap 间距不对？
- blockage 是否挡住了？
- 有没有设计错误？

---

#### 步骤 4：修复

| 违反类型 | 修复方法 |
|----------|----------|
| 间距违反 | 移动图形，增加间距，或者缩小尺寸 |
| 宽度违反 | 增加线宽满足最小值 |
| 密度违反 | 添加填充金属满足密度要求 |
| 天线违反 | 跳线到上层金属，或者插入天线二极管 |
| 过孔间距违反 | 重新排列过孔，增加间距 |

---

#### 步骤 5：重新检查

修复后重新运行 DRC 检查：
- 确认原来的违反已经修复
- 确认修复没有引入新的违反
- 记录修复方法

### Calibre DRC 命令行操作

```tcl
# ============================================
# Calibre DRC 运行命令
# ============================================

# 基本运行命令
calibre -drc -hier design.gds

# 使用规则文件
calibre -drc -rules drc_rules.cal design.gds

# 指定输出文件
calibre -drc -rules drc_rules.cal \
        -hier design.gds \
        -turbo 4 \
        -drc_results design.drc.results

# 查看结果
# 生成 SVRF 数据库
calibre -drc -rules drc_rules.cal \
        -hier design.gds \
        -drc_report design.drc.rpt \
        -drc_db design.drc.db

# 导出错误位置
calibre -drc -rules drc_rules.cal \
        -hier design.gds \
        -drc_export gdsii design.drc.export.gds
```

### Calibre DRC 规则文件示例

```tcl
# ============================================
# Calibre DRC 规则文件示例 (SVRF 格式)
# ============================================

// 层定义
LAYER MAP 1 DATATYPE 0 1      // Metal1
LAYER MAP 2 DATATYPE 0 2      // Metal2
LAYER MAP 3 DATATYPE 0 3      // Via1

// 最小间距规则
Metal1_SPACING = 0.14
Metal2_SPACING = 0.14

// 金属层最小宽度
Metal1_WIDTH = 0.14
Metal2_WIDTH = 0.14

// DRC 检查
// Metal1 最小间距
M1_SPACING = SPACING M1 < Metal1_SPACING

// Metal1 最小宽度
M1_WIDTH = WIDTH M1 < Metal1_WIDTH

// 密度检查
M1_DENSITY = DENSITY M1 0.2 0.8

// 天线规则
ANTENNA_RATIO = 500
ANTENNA_CHECK = ANTENNA M1 GATE < ANTENNA_RATIO

// 输出结果
DRC CHECK MAP M1_SPACING 1
DRC CHECK MAP M1_WIDTH 2
DRC CHECK MAP M1_DENSITY 3
DRC CHECK MAP ANTENNA_CHECK 4
```

### Innovus DRC 检查

```tcl
# ============================================
# Innovus DRC 流程
# ============================================

# 运行 DRC
verifyGeometry

# 检查特定层
verifyGeometry -layer M1

# 检查天线
verifyAntenna

# 导出 DRC 报告
report_drc -out_file drc_report.rpt

# 查看特定类型的违规
report_drc -type spacing
report_drc -type width
report_drc -type density
```

### ICC2 DRC 检查

```tcl
# ============================================
# ICC2 DRC 流程
# ============================================

# 运行 DRC
verify_drc

# 检查特定层
verify_drc -layers {M1 M2 M3}

# 检查天线
verify_antenna

# 导出报告
report_drc -out_file drc_report.rpt

# 查看 DRC 违规数量
report_drc -summary

# 查看特定类型的违规
report_drc -type spacing -max 100
```

## 常见 DRC 问题定位和修复

### 问题 1：天线效应违反

**原因：**
- 下层金属长连线，没有连接到二极管，蚀刻时电荷积累击穿栅氧
- 输入栅直接连到下层长走线

**修复方法：**

1. **跳线**：从下层金属跳线到上层金属，减少暴露面积
   ```
   # 原来：长走线全部在 metal1 → 天线违反
   # 改成：一段 metal1 → via → metal2 → via → metal1 → 减少暴露面积
   ```

2. **插入天线二极管**：在栅极添加二极管放电 → 工具自动插入

3. **改变走线**：重新走线减少暴露面积

### 问题 2：密度违反

**原因：**
- 化学机械抛光（CMP）要求每个区域密度在一定范围
- 密度太高或太低都会导致抛光不均匀
- 大区域密度不对就违反

**修复：**
- 添加 dummy 金属填充 → 满足密度要求
- 移动模块留出空间 → 调整密度
- 打开工具自动填充 → 工具自动填充

**注意：**
- 填充不增加太多额外电容
- 填充不影响信号完整性
- 填充遵守设计规则

### 问题 3：间距违反

**原因：**
- 两个信号走线太近
- 自动布线拥挤区域容易出问题

**修复：**
- 如果有空地方，移动走线增加间距
- 如果没空间，换一层走线
- 缩小线宽不行，最小宽度已经是最小值

## LVS 调试流程

**LVS = 版图 vs 原理图比对** → 检查版图和网表是否一致

### Calibre LVS 命令行操作

```tcl
# ============================================
# Calibre LVS 运行命令
# ============================================

# 基本 LVS 运行
calibre -lvs -hier design.gds netlist.v

# 使用规则文件
calibre -lvs -rules lvs_rules.cal design.gds netlist.v

# 指定输出
calibre -lvs -rules lvs_rules.cal \
        -hier design.gds netlist.v \
        -lvs_report design.lvs.rpt \
        -lvs_db design.lvs.db

# 查看结果
calibredrv design.lvs.db
```

### Calibre LVS 规则文件示例

```tcl
# ============================================
# Calibre LVS 规则文件示例 (SVRF 格式)
# ============================================

// 层定义
LAYER MAP 1 DATATYPE 0 1      // Diffusion
LAYER MAP 2 DATATYPE 0 2      // Poly
LAYER MAP 3 DATATYPE 0 3      // Metal1
LAYER MAP 4 DATATYPE 0 4      // Contact

// 器件定义
// NMOS 定义
NMOS = MOS LAYER DIFF POLY MODEL NMOS

// PMOS 定义
PMOS = MOS LAYER DIFF POLY MODEL PMOS

// 连接定义
// 多晶硅和扩散区的接触
CONNECT POLY CONTACT
CONNECT DIFF CONTACT
CONNECT M1 CONTACT

// 端口定义
PORT M1 TEXT 1

// LVS 检查
LVS CHECK NMOS
LVS CHECK PMOS
LVS CHECK SHORT
LVS CHECK OPEN

// 输出
LVS REPORT design.lvs.rpt
```

### Innovus LVS 检查

```tcl
# ============================================
# Innovus LVS 流程
# ============================================

# 导出网表
saveNetlist -excludeLeafCells design.v

# 导出 DEF
defOut design.def

# 导出 GDS
streamOut design.gds

# 运行 LVS（需要 Calibre 或其他工具）
# 外部运行 Calibre LVS

# 或使用内置检查
verifyConnectivity -type all
```

### ICC2 LVS 检查

```tcl
# ============================================
# ICC2 LVS 流程
# ============================================

# 导出网表
write_verilog -exclude {leaf_cells} design.v

# 导出 DEF
write_def design.def

# 导出 GDS
write_stream design.gds

# 连接性检查
verify_lvs -report_file lvs_report.rpt

# 检查未连接端口
verify_connectivity -unconnected

# 检查短路
verify_connectivity -short
```

### 常见 LVS 违反

| 违反类型 | 原因 |
|----------|------|
| **端口不匹配** | 网表端口数量 vs 版图端口数量不一样 |
| **节点短路** | 两个应该分开的节点连在一起了 |
| **节点开路** | 应该连接的节点没有连上 |
| **浮动节点** | 节点没有连接到任何东西 |
| **器件不匹配** | 器件数量/类型不匹配 |

### 完整调试步骤

1. **读错误报告** → 确定哪个模块哪个网络错了
2. **在版图 GUI 定位** → 找到错误位置
3. **追踪连接** → 从错误点追踪连接，找出哪错了
4. **修复** → 修改网表或者修改版图
5. **重新运行 LVS** → 验证修复

### 常见 LVS 错误原因

1. **电源环没有切开** → 整个电源环是连在一起，分段没切开 → 短路
   - **修复**：正确切开分段电源环，每个分段正确连接

2. **同名网络没有连接** → 顶层同名网络应该连接，没连 → 开路
   - **修复**：正确连接同名网络

3. **blockage 挡住连接** → 阻挡挡住了走线 → 工具找不到连接 → 开路
   - **修复**：调整 blockage 位置，让连接通过

4. **P&R 输出网表层次不对** → LVS 找不到层次 → 匹配错
   - **修复**：调整网表层次匹配版图层次

5. **pad 连接错** → IO pad 连接到 wrong 网络
   - **修复**：改正连接

## ERC 调试流程

**ERC = 电学规则检查**

### 常见 ERC 违反

| 违反 | 说明 | 修复 |
|------|------|------|
| 输入引脚未连接 | 输入引脚悬空 | 未使用输入接地或接电源 |
| 输出引脚未连接 | 输出引脚悬空 | 未使用输出可以悬空，检查是否真的不用 | |
| 电源地短路 | VDD 和 GND 短路 | 找到短路位置，重新走线 |
| 浮动输入引脚 | 输入引脚没有驱动 | 接正确驱动，或者固定电平 |
| 未连接单元 | 单元输出没连接 | 删除不用单元，或者正确连接 |

**修复：**
- 未使用输入 → 绑定到 VDD 或 GND
- 浮动节点 → 如果真的不用，可以留下，否则连接
- 短路 → 找到短路位置重新走线

## Waiver 文档模板

当遇到无法修复的 DRC/LVS 违规时，需要提交 Waiver 申请。

### Waiver 申请模板

```markdown
# DRC/LVS Waiver 申请表

## 基本信息
- **项目名称**: [项目名称]
- **Waiver 编号**: WA-[年份]-[序号]
- **申请人**: [姓名]
- **申请日期**: [日期]

## 违规信息
- **违规类型**: [DRC/LVS]
- **违规代码**: [规则名称]
- **违规位置**: [坐标/模块名称]
- **违规数量**: [数量]
- **发现工具**: [Calibre/ICV/PVS]

## 违规描述
[详细描述违规的具体情况]

## 原因分析
[分析为什么会出现这个违规]

## 影响评估
1. **功能影响**: [是否影响功能]
2. **可靠性影响**: [是否影响可靠性]
3. **良率影响**: [预计对良率的影响]

## 解决方案
- [ ] 已尝试修复，但无法修复
- [ ] 修复成本过高
- [ ] 设计限制，无法修复
- [ ] 其他: [说明]

## 安全证明
[提供理论分析或仿真证明，说明此违规不会影响芯片正常工作]

## 审批记录
| 角色 | 姓名 | 日期 | 结果 |
|------|------|------|------|
| 设计工程师 | | | |
| 物理设计工程师 | | | |
| DRC 工程师 | | | |
| 项目经理 | | | |
| Foundry 代表 | | | |

## 附件
- [ ] 违规截图
- [ ] 分析报告
- [ ] 仿真结果（如适用）
```

### Waiver 评估标准

| 风险等级 | 说明 | Waiver 可能性 |
|----------|------|---------------|
| 高 | 影响功能或可靠性 | 不允许 |
| 中 | 可能影响良率 | 需要充分证明 |
| 低 | 不影响功能和良率 | 允许 |

### 常见可接受的 Waiver

1. **密度违规边界**：芯片边缘密度略低
2. **天线轻微违规**：电荷积累量很小
3. **金属填充密度**：局部区域略高

### 常见不可接受的 Waiver

1. **短路**：任何短路都不允许
2. **最小间距严重违规**：可能导致制造失败
3. **电源网络开路**：影响供电

## 调试技巧

### 1. 分层分批修复

- 同一种违反一起修复 → 快
- 先修复简单错误，再修复复杂错误
- 修复一批，重新检查一批 → 不要一次改一堆再检查，容易引入新错误

### 2. 利用工具自动修复

- 大多数简单违反工具能自动修复
- 让工具自动修复先，剩下手动修复
- 节省时间

### 3. 记录修复

- 记录每个修复位置和原因
- 方便复查
- 方便下个项目参考

### 4. 从顶层开始

- 先修复顶层错误，再修复模块错误
- 顶层对了，往下找模块错

## 最终流片要求

流片前必须：

- [ ] **DRC 零违反** → 有违反必须 waivere ，得到 foundry 同意
- [ ] **LVS 零违反** → 零违反才能流片
- [ ] **ERC 零违反**
- [ ] **天线零违反**
- [ ] **密度满足要求**

**重要：** 不要留已知违反流片，良率会差，甚至芯片不工作。

## 工具支持

- **Calibre** (Siemens EDA) → 工业界标准
- **ICV** (Synopsys)
- **PVS** (Cadence)

## 检查清单

修复完成检查：

- [ ] 原来的违反都修复了
- [ ] 没有引入新的违反
- [ ] 所有违反零
- [ ] 如果必须 waive → 记录原因，得到foundry同意
- [ ] 修复后重新跑时序 → 修复可能改变线负载，影响时序

## 反模式（要避免）

❌ **忽略小违反** → 小违反积累，最后良率低
❌ **不重新检查** → 修复一个引入一个，最后还是错
❌ **一次改一百个** → 引入很多新错误，找不到
❌ ** waive 不知道原因的违反** → 不知道原因就waive，可能出问题

## 代理协作

- 使用 `physical-design-engineer` 代理进行物理设计
- DRC/LVS 修复完成后，重新运行静态时序分析 → 修复改变了寄生参数，时序可能变化
