# ICER Skill Package - 集成电路工程技能包

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/tangyangchao578-art/icer_skill_package)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

专为 Claude Code 打造的集成电路设计工程师技能包，覆盖从架构到流片的完整设计流程。

## 核心特性

- 🎯 **问题诊断框架**：症状→原因→解决方案的系统方法论
- 📊 **行业经验数值**：各工艺节点的典型值参考
- 📚 **案例研究**：真实问题的诊断和解决过程
- 🔧 **工具命令**：关键命令的深入用法和参数解释
- ✅ **专业深度**：从入门到专家级别的技术指导

## 快速开始

### 安装

```bash
git clone https://github.com/tangyangchao578-art/icer_skill_package.git
cd icer_skill_package
./install.sh all
```

### 验证安装

```bash
./install.sh verify
```

### 使用

```bash
# 使用技能
/skill timing-analysis

# 使用代理
/agent timing-engineer
```

## 技能列表

每个技能都包含：问题诊断框架、行业经验数值、案例研究、详细工作步骤。

| 技能 | 步骤数 | 特色内容 |
|------|--------|----------|
| timing-analysis | 8 步 | 时序诊断决策树、MMMC分析、签收标准 |
| physical-design | 8 阶段 | 拥塞诊断、IR降诊断、DFM考虑 |
| power-analysis | 8 步 | 功耗诊断框架、IR/EM经验值 |
| rtl-coding | 9 步 | 可综合设计、CDC处理、低功耗编码 |
| systemverilog | 10 步 | 设计特性、验证特性分离 |
| uvvm-verification | 5 步 | 验证计划→方案→测试点→环境→覆盖率 |
| assertion-based-verification | 8 步 | SVA断言设计、形式验证 |
| functional-safety-analysis | 8 步 | ISO 26262、FMEDA、ASIL等级 |
| board-bringup | 6 步 | 静态→上电→时钟→配置→模块→系统 |
| eda-scripting | TCL/Python/Makefile | 流程脚本最佳实践 |
| architecture-design | 10 步 | 需求→接口→模块→时钟→复位→存储→电源→DFT→评估→文档 |

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
| eda-automation-engineer | eda-scripting | 流程脚本、自动化 |

## 规则体系

采用双层结构，IC 特定规则覆盖通用规则：

```
rules/
├── common/          # 通用原则
│   ├── architecture.md
│   ├── front-end-design.md
│   ├── front-end-verification.md
│   ├── back-end.md
│   ├── ...
└── ic/              # IC 特定扩展
    ├── architecture.md
    ├── front-end-design.md
    └── ...
```

## 支持工具

### 商业工具

| 类别 | 工具 |
|------|------|
| 综合 | Synopsys Design Compiler, Cadence Genus |
| 物理设计 | Synopsys IC Compiler II, Cadence Innovus |
| 时序分析 | Synopsys PrimeTime, Cadence Tempus |
| 物理验证 | Siemens Calibre, Synopsys ICV, Cadence PVS |
| 仿真 | Synopsys VCS, Cadence Xcelium |
| 功耗分析 | Synopsys PrimePower, Cadence Voltus, ANSYS RedHawk |

### 开源工具

| 类别 | 工具 |
|------|------|
| 综合 | Yosys |
| 仿真 | Verilator, GHDL |
| 物理设计 | OpenROAD |
| 时序分析 | OpenSTA |

## 专业内容亮点

### 故障诊断框架

每个技能都包含系统性的问题诊断方法：

```
症状 → 可能原因 → 诊断步骤 → 判断标准 → 解决方案优先级
```

### 行业经验数值

提供各工艺节点的典型值参考：

| 参数 | 28nm | 16nm | 7nm |
|------|------|------|-----|
| 逻辑级数上限 | 8-10 | 6-8 | 4-6 |
| 时钟 Skew | <150ps | <100ps | <50ps |
| IR 降上限 | <5% | <5% | <5% |

### 案例研究

真实问题的完整诊断过程：

- DDR 控制器时序收敛案例
- 移动 SoC 功耗超标案例
- 拥塞导致时序不收敛案例

## 安装命令

```bash
./install.sh all        # 完整安装
./install.sh rules      # 仅规则
./install.sh skills     # 仅技能
./install.sh agents     # 仅代理
./install.sh update     # 更新
./install.sh verify     # 验证
./install.sh uninstall  # 卸载
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT
