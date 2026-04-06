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
│   └── drc-lvi-debug/
└── agents/              # 7 个角色代理
    ├── chip-architect/
    ├── rtl-designer/
    ├── verification-engineer/
    ├── physical-design-engineer/
    ├── functional-safety-engineer/
    ├── validation-engineer/
    └── eda-scripting-developer/
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
