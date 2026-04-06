# ICER Skill Package - 集成电路工程技能包

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](https://github.com/tangyangchao578-art/icer_skill_package)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

专为 Claude Code 打造的集成电路设计工程师技能包，覆盖从架构到流片的完整设计流程。

## 特性

- 🎯 **完整覆盖**：从架构设计到流片的全流程
- 📚 **12 个技能**：详细的步骤化工作指南
- 🤖 **10 个代理**：对应芯片设计各角色
- 📝 **示例代码**：RTL、UVM、EDA 脚本模板
- 📖 **命令速查**：常用 EDA 工具命令参考
- ✅ **检查清单**：代码审查、流片检查清单
- 🔧 **工具支持**：商业工具 + 开源工具

## 快速开始

### 安装

```bash
# 克隆仓库
git clone https://github.com/tangyangchao578-art/icer_skill_package.git
cd icer_skill_package

# 完整安装
./install.sh all

# 或部分安装
./install.sh rules     # 仅安装规则
./install.sh skills    # 仅安装技能
./install.sh agents    # 仅安装代理
./install.sh examples  # 仅安装示例代码
```

### 验证安装

```bash
./install.sh verify
```

### 使用

安装后，Claude Code 会自动加载规则。在项目中你可以：

```bash
# 使用技能
/skill rtl-coding

# 使用代理
/agent rtl-designer

# 查看帮助
./install.sh help
```

## 目录结构

```
icer_skill_package/
├── README.md
├── install.sh              # 增强安装脚本
├── rules/                  # 规则 (21 个文件)
│   ├── common/             # 通用原则
│   └── ic/                 # IC 特定扩展
├── skills/                 # 技能 (12 个)
│   ├── architecture-design/
│   ├── rtl-coding/
│   ├── systemverilog/
│   ├── uvvm-verification/
│   ├── assertion-based-verification/
│   ├── physical-design/
│   ├── timing-analysis/
│   ├── power-analysis/
│   ├── functional-safety-analysis/
│   ├── board-bringup/
│   ├── eda-scripting/
│   └── drc-lvs-debug/
├── agents/                 # 代理 (10 个)
│   ├── chip-architect/
│   ├── rtl-designer/
│   ├── verification-engineer/
│   ├── physical-design-engineer/
│   ├── timing-engineer/
│   ├── power-engineer/
│   ├── functional-safety-engineer/
│   ├── validation-engineer/
│   ├── drc-engineer/
│   └── eda-automation-engineer/
├── examples/               # 示例代码
│   ├── rtl/                # RTL 模板
│   ├── uvm/                # UVM 模板
│   ├── scripts/            # EDA 脚本
│   └── constraints/        # 约束文件
└── references/             # 参考文档
    ├── tool_commands/      # 工具命令速查
    └── checklists/         # 检查清单
```

## 技能列表

| 技能 | 步骤数 | 描述 |
|------|--------|------|
| architecture-design | 10 步 | 需求 → 接口 → 模块 → 时钟 → 复位 → 存储 → 电源 → DFT → 评估 → 文档 |
| rtl-coding | 9 步 | 骨架 → 信号 → 时序 → 组合 → CDC → 低功耗 → 风格 → 仿真 → 提交 |
| systemverilog | 10 步 | 设计特性 + 验证特性 |
| uvvm-verification | 5 步 | 验证计划 → 方案 → 测试点 → 环境 → 覆盖率 |
| assertion-based-verification | 8 步 | 类型 → 基本断言 → 模式 → 复位 → 放置 → 调试 → 最佳实践 → 形式验证 |
| physical-design | 8 阶段 | 输入 → Floorplan → Placement → CTS → Routing → Timing → 验证 → Tapeout |
| timing-analysis | 8 步 | 概念 → 分析 → 报告 → 建立修复 → 保持修复 → 多工艺角 → OCV → 签收 |
| power-analysis | 8 步 | 组成 → 分析 → 识别 → 架构优化 → RTL优化 → 物理优化 → IR降 → 电迁移 |
| functional-safety-analysis | 8 步 | ASIL → HARA → 失效 → 影响 → 安全机制 → 指标 → 验证 → 文档 |
| board-bringup | 6 步 | 静态 → 上电 → 时钟 → 配置 → 模块 → 系统 |
| eda-scripting | TCL/Python/Makefile | 流程脚本最佳实践 |
| drc-lvs-debug | DRC/LVS/ERC | 调试步骤 |

## 代理列表

| 代理 | 对应技能 | 职责 |
|------|----------|------|
| chip-architect | architecture-design | 架构设计、模块划分、接口定义 |
| rtl-designer | rtl-coding, systemverilog | RTL 实现、编码、可综合设计 |
| verification-engineer | uvvm-verification, assertion-based-verification | 验证平台、测试用例、覆盖率 |
| physical-design-engineer | physical-design | 布局布线、时序收敛、物理验证 |
| timing-engineer | timing-analysis | 时序分析、收敛优化 |
| power-engineer | power-analysis | 功耗分析、IR降、电迁移 |
| functional-safety-engineer | functional-safety-analysis | 功能安全、FMEDA、安全机制 |
| validation-engineer | board-bringup | 板级验证、bring-up、调试 |
| drc-engineer | drc-lvs-debug | DRC/LVS 调试修复 |
| eda-automation-engineer | eda-scripting | 流程脚本、自动化 |

## 示例代码

### RTL 模板

- `async_fifo.sv` - 异步 FIFO 完整实现
- `clock_gate.sv` - 门控时钟单元
- `cdc_synchronizer.sv` - 跨时钟域同步器

### UVM 模板

- `tb_top.sv` - 测试平台顶层
- `base_test.sv` - 基础测试类

### EDA 脚本

- `dc_synthesis.tcl` - Design Compiler 综合脚本
- `pt_sta.tcl` - PrimeTime 静态时序分析脚本
- `innovus_flow.tcl` - Innovus 物理设计流程

### 约束文件

- `timing.sdc` - 时序约束模板

## 参考文档

### 工具命令速查

- `design_compiler.md` - DC 命令速查
- `prime_time.md` - PT 命令速查

### 检查清单

- `rtl_review.md` - RTL 代码审查清单
- `tapeout_checklist.md` - 流片检查清单

## 支持工具

### 商业工具

| 类别 | 工具 |
|------|------|
| 综合 | Synopsys Design Compiler, Cadence Genus |
| 物理设计 | Synopsys IC Compiler II, Cadence Innovus |
| 时序分析 | Synopsys PrimeTime, Cadence Tempus |
| 物理验证 | Siemens Calibre, Synopsys ICV, Cadence PVS |
| 仿真 | Synopsys VCS, Cadence Xcelium, Siemens Questa |
| 功耗分析 | Synopsys PrimePower, Cadence Voltus, ANSYS RedHawk |

### 开源工具

| 类别 | 工具 |
|------|------|
| 综合 | Yosys |
| 仿真 | Verilator, GHDL, Icarus Verilog |
| 物理设计 | OpenROAD |
| 时序分析 | OpenSTA |
| 完整流程 | OpenLANE |

## 安装命令

```bash
# 查看帮助
./install.sh help

# 完整安装
./install.sh all

# 部分安装
./install.sh rules      # 仅规则
./install.sh skills     # 仅技能
./install.sh agents     # 仅代理
./install.sh examples   # 仅示例
./install.sh references # 仅参考

# 管理命令
./install.sh update     # 更新
./install.sh uninstall  # 卸载
./install.sh verify     # 验证安装
./install.sh version    # 显示版本
```

## 规则说明

规则采用分层结构：

1. **common/** - 通用原则，定义每个领域"应该做什么"
2. **ic/** - IC 特定扩展，覆盖集成电路的具体要求

遵循与 Claude Code 默认规则相同的约定，可以无缝集成。

## Agent 与 Skill 关系

```
Agent = 角色（我是谁，负责什么，调用哪些技能）
Skill  = 技能（具体怎么做，详细步骤）

chip-architect          → architecture-design
rtl-designer           → rtl-coding, systemverilog
verification-engineer  → uvvm-verification, assertion-based-verification
physical-design-engineer → physical-design
timing-engineer        → timing-analysis
power-engineer         → power-analysis
functional-safety-engineer → functional-safety-analysis
validation-engineer    → board-bringup
drc-engineer           → drc-lvs-debug
eda-automation-engineer → eda-scripting
```

## 快速入门示例

### RTL 编码

```
用户: 我需要设计一个异步 FIFO
Claude: /skill rtl-coding
        /agent rtl-designer
        
        我将帮你设计异步 FIFO。根据 RTL 编码技能的步骤：
        1. 首先创建模块骨架...
        2. 定义信号和参数...
        参考 examples/rtl/async_fifo.sv 模板
```

### 物理设计

```
用户: 如何进行布局布线？
Claude: /skill physical-design
        /agent physical-design-engineer
        
        我将指导你完成物理设计流程：
        1. Floorplan - 设置芯片面积和 IO...
        2. Placement - 全局布局和详细布局...
        参考 examples/scripts/pd/innovus_flow.tcl
```

### 时序分析

```
用户: 如何做静态时序分析？
Claude: /skill timing-analysis
        /agent timing-engineer
        
        静态时序分析步骤：
        1. 理解时序概念（建立/保持时间）...
        2. 运行时序分析...
        参考 examples/scripts/sta/pt_sta.tcl
```

## 更新日志

### v1.1.0

- ✨ 新增示例代码目录 (examples/)
- ✨ 新增参考文档目录 (references/)
- 📝 增强 physical-design 技能 (TCL 命令、流程详解)
- 📝 增强 power-analysis 技能 (IR 降、EM 分析)
- 📝 增强 drc-lvs-debug 技能 (Calibre 命令、Waiver 模板)
- 🔧 增强安装脚本 (版本管理、更新、卸载、验证)
- 📖 新增工具命令速查 (DC、PT)
- ✅ 新增检查清单 (RTL 审查、流片检查)

### v1.0.0

- 🎉 初始版本
- 📚 12 个技能
- 🤖 10 个代理
- 📝 21 个规则文件

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT
