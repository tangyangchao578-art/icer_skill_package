# ICER 规则

## 结构

规则采用分层结构：

```
rules/
├── common/          # 通用原则（始终加载）
│   ├── architecture.md
│   ├── front-end-design.md
│   ├── front-end-verification.md
│   ├── board-level-verification.md
│   ├── middle-end.md
│   ├── back-end.md
│   ├── functional-safety.md
│   ├── coding-style.md
│   ├── tools.md
│   ├── documentation.md
│   └── agents.md
└── ic/              # IC 特定扩展
    ├── architecture.md
    ├── front-end-design.md
    ├── front-end-verification.md
    ├── board-level-verification.md
    ├── middle-end.md
    ├── back-end.md
    ├── functional-safety.md
    ├── coding-style.md
    └── tools.md
```

## 规则优先级

当 IC 特定规则与通用规则冲突时，**IC 特定规则优先**（特定覆盖通用）。

## 规则 vs 技能

- **规则** 定义广泛适用的标准、约定和检查清单（如"RTL 必须可综合"、"所有寄存器必须有复位"）。
- **技能** 为特定任务提供深入、可操作的参考材料（如 `rtl-coding`、`uvvm-verification`）。

规则告诉你*做什么*；技能告诉你*怎么做*。
