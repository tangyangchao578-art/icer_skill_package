# IC 设计代理编排

## 可用代理

位于 `~/.claude/agents/`：

### 前端代理

| 代理 | 用途 | 对应技能 |
|-------|---------|----------|
| chip-architect | 芯片架构设计 | architecture-design |
| rtl-designer | RTL 设计、编码 | rtl-coding, systemverilog |
| verification-engineer | 验证平台开发、测试用例 | uvvm-verification, assertion-based-verification |

### 后端代理

| 代理 | 用途 | 对应技能 |
|-------|---------|----------|
| physical-design-engineer | 物理设计、布局布线 | physical-design |
| timing-engineer | 时序分析、收敛优化 | timing-analysis |
| power-engineer | 功耗分析、IR降分析 | power-analysis |
| drc-engineer | DRC/LVS 调试修复 | drc-lvs-debug |

### 验证与安全代理

| 代理 | 用途 | 对应技能 |
|-------|---------|----------|
| functional-safety-engineer | 功能安全分析、FMEDA | functional-safety-analysis |
| validation-engineer | 板级验证、bring-up | board-bringup |

### 工具代理

| 代理 | 用途 | 对应技能 |
|-------|---------|----------|
| eda-automation-engineer | EDA 流程脚本开发 | eda-scripting |

## 立即使用代理

无需用户提示：

### 前端任务
1. **芯片架构定义** - 使用 **chip-architect** 代理
2. **RTL 实现** - 使用 **rtl-designer** 代理
3. **验证平台开发** - 使用 **verification-engineer** 代理

### 后端任务
4. **物理设计** - 使用 **physical-design-engineer** 代理
5. **时序收敛** - 使用 **timing-engineer** 代理
6. **功耗分析** - 使用 **power-engineer** 代理
7. **DRC/LVS 调试** - 使用 **drc-engineer** 代理

### 验证与安全任务
8. **功能安全分析** - 使用 **functional-safety-engineer** 代理
9. **板级调试** - 使用 **validation-engineer** 代理

### 工具任务
10. **EDA 脚本开发** - 使用 **eda-automation-engineer** 代理

## 代理协作关系

```
前端流程：
chip-architect → rtl-designer → verification-engineer

后端流程：
physical-design-engineer → timing-engineer → power-engineer → drc-engineer

验证与安全：
functional-safety-engineer (贯穿全流程)
validation-engineer (硅后验证)

工具支持：
eda-automation-engineer (全流程自动化)
```

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

- **架构设计师**：定义架构
- **验证工程师**：从验证视角评估可验证性
- **后端工程师**：从实现视角评估可实现性
- **时序工程师**：评估时序可行性
- **功耗工程师**：评估功耗预算
- **安全工程师**：评估功能安全

## 代理选择指南

| 任务类型 | 推荐代理 |
|----------|----------|
| 定义芯片架构 | chip-architect |
| 编写 RTL 代码 | rtl-designer |
| 开发验证平台 | verification-engineer |
| 添加断言 | verification-engineer |
| 布局布线 | physical-design-engineer |
| 时序违例修复 | timing-engineer |
| 功耗分析优化 | power-engineer |
| DRC/LVS 问题 | drc-engineer |
| 功能安全分析 | functional-safety-engineer |
| 板级调试 | validation-engineer |
| 流程自动化脚本 | eda-automation-engineer |
