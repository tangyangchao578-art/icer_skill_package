# IC 设计代理编排

## 可用代理

位于 `~/.claude/agents/`：

| 代理 | 用途 | 何时使用 |
|-------|---------|------------|
| chip-architect | 芯片架构设计 | 定义芯片架构、模块划分、接口设计 |
| rtl-designer | RTL 设计 | RTL 实现、调试、优化 |
| verification-engineer | 验证工程师 | 验证平台开发、测试用例编写 |
| physical-design-engineer | 后端工程师 | 物理设计、布局布线、时序收敛 |
| functional-safety-engineer | 功能安全工程师 | 安全需求分析、安全机制设计 |
| validation-engineer | 验证工程师（板级） | FPGA 原型验证、硅后板级验证、调试 |
| eda-scripting-developer | EDA 脚本开发 | EDA 流程脚本开发、自动化 |

## 立即使用代理

无需用户提示：

1. **芯片架构定义** - 使用 **chip-architect** 代理
2. **RTL 实现** - 使用 **rtl-designer** 代理
3. **验证平台开发** - 使用 **verification-engineer** 代理
4. **后端实现** - 使用 **physical-design-engineer** 代理
5. **功能安全分析** - 使用 **functional-safety-engineer** 代理
6. **板级调试** - 使用 **validation-engineer** 代理
7. **EDA 脚本开发** - 使用 **eda-scripting-developer** 代理

## 并行任务执行

对独立操作始终使用并行 Task 执行：

```markdown
同时启动多个代理：
1. 代理 1：RTL 模块实现
2. 代理 2：验证平台开发
3. 代理 3：约束脚本编写
```

## 多视角分析

对于复杂问题，使用分角色子代理：

- 架构设计师：定义架构
- 验证工程师：从验证视角评估可验证性
- 后端工程师：从实现视角评估可实现性
- 安全工程师：评估功能安全
