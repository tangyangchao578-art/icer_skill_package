---
name: uvvm-verification
description: UVM 验证方法论技能
description.zh: UVM 验证方法论技能
author: ICER Skill Package
categories: verification
---

# UVM 验证方法论技能

当用户需要开发 UVM 验证平台时，启用此技能。此技能提供 UVM 验证最佳实践。

## 使用时机

- 开发新的 UVM 验证平台
- 优化现有 UVM 验证平台
- 调试 UVM 验证问题
- 从老方法迁移到 UVM

## UVM 验证平台结构

```
testbench/
├── tb_top.sv           # 测试平台顶层
├── interfaces/          # 接口定义
│   └── bus_if.sv
├── agents/             # 驱动器+监视器+序列器
│   ├── driver.sv
│   ├── monitor.sv
│   ├── sequencer.sv
│   └── agent.sv
├── sequences/          # 激励序列
│   ├── base_seq.sv
│   ├── read_seq.sv
│   └── write_seq.sv
├── models/             # 参考模型
│   └── ref_model.sv
├── scoreboards/        # 结果检查
│   └── scoreboard.sv
├── coverage/           # 功能覆盖率
│   └── coverage.sv
├── tests/              # 测试用例
│   ├── base_test.sv
│   ├── sanity_test.sv
│   └── stress_test.sv
└── env.sv              # 环境顶层
```

## UVM 编码准则

### 工厂注册

```systemverilog
`uvm_component_utils(my_agent)
`uvm_component_utils_begin(my_transaction)
  `uvm_field_int(addr, UVM_ALL_ON)
  `uvm_field_int(data, UVM_ALL_ON)
`uvm_component_utils_end
```

使用工厂注册允许覆盖。

### phase 机制

- build_phase : 创建组件
- connect_phase : 连接 TLM 端口
- run_phase : 运行测试
- 遵循 UVM phase 顺序

### 配置数据库

- 使用 `uvm_config_db` 传递配置
- 在 build_phase 获取配置
- 不要使用全局变量

### TLM 连接

- 使用 analysis port 从 monitor 发送数据
- 使用 TLM FIFO 连接到 scoreboard
- 正确连接所有端口

### sequence 机制

- sequence 产生激励
- 分层 sequence：大 sequence 调用小 sequence
- sequence 不要包含功能检查

## 最佳实践

### 可重用性

- agent 设计支持 active/passive 模式
- 配置参数化
- 不依赖环境特定配置
- 方便集成到更高层环境

### 调试

- 提供适当的日志输出
- 使用 `+UVM_VERBOSITY=UVM_DEBUG` 控制日志
- 提供波形可以观测内部信号
- 使用 UVM 报告机制

### 覆盖率

- 定义功能覆盖点
- 定义交叉覆盖
- 根据覆盖率结果添加测试
- 达到覆盖率目标才收敛

## 检查清单

- [ ] 所有组件都正确工厂注册
- [ ] phase 调用 super.phase()
- [ ] TLM 端口都正确连接
- [ ] 正确使用 objection 机制结束仿真
- [ ] 配置通过 config_db 传递
- [ ] 功能覆盖率已收集

## 常见错误

❌ 不要在 build_phase 之前访问 config_db
❌ 不要忘记 super.phase()
❌ 不要在 driver 中做结果检查
❌ 不要忘记 objection 控制仿真结束
❌ 不要使用全局变量共享配置

## 工具支持

- Synopsys VCS
- Cadence Xcelium
- Siemens Questa
- 开源：Verilator 支持基本 UVM

## 代理协作

- 使用 `verification-engineer` 代理进行验证开发
- 使用 `code-reviewer` 代理进行代码审查
