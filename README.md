# ICER Skill Package - 集成电路工程技能包

专为 Claude Code 打造的集成电路设计工程师技能包，覆盖从架构到流片的完整设计流程。

## 简介

ICER (Integrated Circuit Engineering Rules) 是一套为 Claude Code 准备的规则、技能和代理集合，帮助芯片设计者快速启动新项目，将 AI 编程能力融入芯片设计的各个环节。

## 功能覆盖

| 领域 | 说明 |
|------|------|
| 芯片架构 | 架构定义、模块划分、接口设计 |
| 前端设计 | RTL 编码、可综合设计、重构优化 |
| 前端验证 | UVM 验证、断言验证、覆盖率收集 |
| 中端 | 逻辑综合、映射、DFT |
| 后端设计 | 布局布线、时序收敛、DRC/LVS |
| 板级验证 | 原型验证、硬件 bring-up、调试 |
| 功能安全 | ISO 26262、ASIL、FMEDA、安全机制 |

## 支持工具

同时涵盖主流开源和商业 EDA 工具：

**开源工具：**
- Yosys - 逻辑综合
- Verilator - 仿真
- SymbiFlow - 布局布线
- GHDL - VHDL 仿真
- OpenLANE - 开源 RTL-to-GDS 流程

**商业工具：**
- Synopsys Design Compiler/IC Compiler
- Cadence Innovus/Genus
- Siemens EDA Veloce/Questa
- Synopsys VCS/SpyGlass
- Cadence Xcelium

## 安装

### 方法一：全自动安装

```bash
git clone https://github.com/tangyangchao578-art/icer_skill_package.git
cd icer_skill_package
./install.sh all
```

### 方法二：部分安装

```bash
# 只安装规则
./install.sh rules

# 只安装技能
./install.sh skills

# 只安装代理
./install.sh agents
```

### 手动安装

```bash
# 安装规则
cp -r rules/* ~/.claude/rules/

# 安装技能
cp -r skills/* ~/.claude/skills/

# 安装代理
cp -r agents/* ~/.claude/agents/
```

## 使用方法

安装后，Claude Code 会自动加载规则。在项目中你可以：

- **使用技能：** `/skill rtl-coding` 启用 RTL 编码技能
- **使用代理：** `/agent rtl-designer` 让 RTL 设计师代理帮你工作
- **规则：** 规则会自动应用于所有对话，确保编码和设计符合芯片设计最佳实践

## 目录结构

```
icer_skill_package/
├── README.md
├── install.sh
├── rules/
│   ├── common/          # 通用原则
│   └── ic/              # IC 特定扩展
├── skills/              # 12 个专项技能
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
└── agents/              # 10 个角色代理
    ├── chip-architect/            # 芯片架构师
    ├── rtl-designer/              # RTL 设计师
    ├── verification-engineer/     # 验证工程师
    ├── physical-design-engineer/  # 物理设计工程师
    ├── timing-engineer/           # 时序工程师
    ├── power-engineer/            # 功耗工程师
    ├── functional-safety-engineer/# 功能安全工程师
    ├── validation-engineer/       # 板级验证工程师
    ├── drc-engineer/              # DRC 工程师
    └── eda-automation-engineer/   # EDA 自动化工程师
```

## 技能列表

每个技能都包含详细的工作步骤：

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

每个代理对应特定技能，明确职责和协作关系：

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

## 规则说明

规则采用分层结构：

1. **common/** - 通用原则，定义每个领域"应该做什么"
2. **ic/** - IC 特定扩展，覆盖集成电路的具体要求，覆盖通用规则

遵循与 Claude Code 默认规则相同的约定，可以无缝集成。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT
