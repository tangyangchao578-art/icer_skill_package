---
name: uvvm-verification
description: UVM 验证方法论技能 - UVM 验证平台开发最佳实践
description.zh: UVM 验证方法论技能 - UVM 验证平台开发最佳实践
origin: ICER
categories: verification
---

# UVM 验证方法论技能

当用户需要开发 UVM 验证平台时，启用此技能。此技能提供 UVM 验证最佳实践，遵循 IEEE 标准 UVM 。

## When to Activate

- 开发新的 UVM 验证平台
- 优化现有 UVM 验证平台结构
- 调试 UVM 验证平台问题
- 从 legacy 验证方法迁移到 UVM
- 代码审查 UVM 验证平台

## UVM 验证平台标准结构

```
testbench/
├── tb_top.sv           # 测试平台顶层（例化DUT和接口）
├── interfaces/          # DUT接口定义
│   └── bus_if.sv
├── agents/             # agent（driver + monitor + sequencer）
│   ├── driver.sv
│   ├── monitor.sv
│   ├── sequencer.sv
│   └── agent.sv
├── sequences/          # 激励序列
│   ├── base_seq.sv
│   ├── read_seq.sv
│   ├── write_seq.sv
│   └── stress_seq.sv
├── models/             # 参考模型
│   └── ref_model.sv
├── scoreboards/        # 结果比较
│   └── scoreboard.sv
├── coverage/           # 功能覆盖率收集
│   └── coverage.sv
├── tests/              # 测试用例
│   ├── base_test.sv
│   ├── sanity_test.sv
│   └── stress_test.sv
└── env.sv              # 环境顶层
```

这个结构分工清晰，方便复用。

## UVM 编码准则

### 工厂注册

所有组件和事务都必须工厂注册，才能支持覆盖。

```systemverilog
// 组件注册
`uvm_component_utils(my_agent)

// 事务注册，带字段配置
`uvm_object_utils(my_transaction)
`uvm_object_utils_begin(my_transaction)
  `uvm_field_int(addr, UVM_ALL_ON)
  `uvm_field_int(data, UVM_ALL_ON)
  `uvm_field_array_int(data_array, UVM_ALL_ON)
`uvm_object_utils_end
```

**为什么要工厂注册？**
- 支持通过名字创建对象
- 支持工厂覆盖，可以派生覆盖基类
- 支持 UVM 基础设施

### phase 机制

遵循 UVM phase 顺序：

| Phase | 用途 |
|-------|------|
| **build_phase** | 创建所有子组件 |
| **connect_phase** | 连接 TLM 端口 |
| **end_of_elaboration** | 最后调整，打印配置 |
| **run_phase** | 运行测试，产生激励 |
| **extract_phase** | 提取覆盖率和结果 |
| **check_phase** | 检查结果是否正确 |
| **report_phase** | 打印报告统计 |

**✅ 重要：每个 phase 必须调用 `super.phase()`**

```systemverilog
virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);  // 必须调用父类
  // 你的代码...
  agent = my_agent::type_id::create("agent", this);
endfunction
```

**❌ 错误：忘记调用 super.phase()**

```systemverilog
virtual function void build_phase(uvm_phase phase);
  // 忘记调用 super.build_phase(phase);
  agent = my_agent::type_id::create("agent", this);
endfunction
```

父类build没有执行，会导致奇怪的问题。

### 配置数据库

使用 `uvm_config_db` 传递配置，不要使用全局变量。

```systemverilog
// 发送配置：在test里
uvm_config_db#(virtual bus_if)::set(this, "*env.agent*", "bus_vif", bus_if);

// 获取配置：在agent里
virtual function void build_phase(uvm_phase phase);
  if (!uvm_config_db#(virtual bus_if)::get(this, "", "bus_vif", vif)) begin
    `uvm_fatal(get_full_name(), "Failed to get bus_vif from config db")
  end
endfunction
```

**最佳实践：**
- 使用虚拟接口通过 config_db 传递
- 配置参数通过 config_db 传递
- 不要硬编码，不要全局变量

### TLM 连接

**✅推荐：**
- Monitor 使用 `analysis_port` 发送采集到的transaction
- Scoreboard 使用 `tlm_analysis_fifo` 接收
- 正确连接，不要跳过层级

```systemverilog
// monitor
analysis_port#(transaction) ap;

function new(string name, uvm_component parent);
  ap = new("ap", this);
endfunction

// env
scoreboard = scoreboard::type_id::create("scoreboard", this);
agent.monitor.ap.connect(scoreboard.analysis_export);
```

### sequence 机制

- sequence 负责产生激励
- driver 负责把 transaction 发给接口
- sequence 不做结果检查，结果检查在scoreboard
- 分层sequence：大sequence调用小sequence，复用

**✅ 示例：**

```systemverilog
// 顶层读写sequence
class rw_seq extends base_seq;
  `uvm_object_utils(rw_seq)

  virtual task body();
    write_seq write = write_seq::type_id::create("write");
    read_seq read = read_seq::type_id::create("read");
    write.start(m_sequencer);
    read.start(m_sequencer);
  endtask
endclass
```

### objection 机制控制仿真结束

**✅ 正确：**

```systemverilog
class my_test extends base_test;
  `uvm_component_utils(my_test)

  virtual task run_phase(uvm_phase phase);
    // 提起objection，告诉UVM我们还在运行
    phase.raise_objection(this);
    // 运行sequence
    seq.start(env.agent.sequencer);
    // 等待sequence完成
    seq.wait_for_sequence_state(UVM_FINISHED);
    // 放下objection，告诉UVM我们结束了
    phase.drop_objection(this);
  endtask
endclass
```

**❌ 常见错误：忘记 objection**

如果忘记 raise objection，仿真会立即结束，什么都不运行。

## 最佳实践

### 可重用性

- agent 设计支持 active/passive 模式
  - active：driver + sequencer + monitor
  - passive：只有 monitor，用于集成
- 所有参数配置化，不要硬编码
- 不依赖特定环境配置
- 方便集成到更高层环境

### 调试可观测性

- 提供适当的日志输出，使用 `uvm_info`
- 使用 `+UVM_VERBOSITY=UVM_DEBUG` 控制日志详细程度
- 所有内部信号都可以通过波形观测
- 使用 UVM 报告机制，不要自己用 `$display` 到处打

### 覆盖率驱动验证

- 定义所有功能点的覆盖点
- 定义感兴趣的交叉覆盖
- 每次仿真收集覆盖率
- 合并覆盖率数据
- 根据覆盖率结果发现遗漏，添加缺失测试
- **达到覆盖率目标才算验证收敛**

## 检查清单

验证平台完成后检查：

- [ ] 所有组件都正确工厂注册
- [ ] 每个 phase 都调用了 `super.phase()`
- [ ] TLM 端口都正确连接
- [ ] 正确使用 objection 机制控制仿真结束
- [ ] 配置通过 `uvm_config_db` 传递
- [ ] 没有全局变量
- [ ] sequence 只产生激励，不做检查
- [ ] 功能覆盖点都已定义
- [ ] 日志级别合理，不会太多也不会太少

## 常见错误

| 错误 | 后果 | 修复 |
|------|------|------|
| 忘记 `super.phase()` | 组件没有创建，连接失败 | 添加 `super.phase()` |
| 忘记 objection | 仿真立即结束，不运行 | 添加 raise/drop objection |
| 在 build_phase 之前 get config | config 还没设置，get 失败 | 在 build_phase 里 get |
| driver 里面做结果检查 | 破坏分层，难以复用 | 结果检查移到 scoreboard |
| 使用全局变量传递接口 | 不可复用，容易出错 | 使用 uvm_config_db |
| 不检查 get 成功失败 | 失败了还继续运行，很难debug | 失败 `uvm_fatal` |

## UVM 验证收敛标准

验证完成条件（全部满足才算完成）：

- [ ] 所有计划的测试用例都通过
- [ ] 代码覆盖率 >= 90%
- [ ] 功能覆盖率 100%
- [ ] 所有断言都没有失败
- [ ] 所有open issue都已经分析处理

## 工具支持

- Synopsys VCS → 完全支持
- Cadence Xcelium → 完全支持
- Siemens Questa → 完全支持
- 开源：Verilator → 支持基本 UVM

## 推荐书籍资料

- **UVM Primer 中文** → 入门最佳
- **IEEE 1800-2017** → 官方标准
- **UVM Cookbook** → 实用案例

## 反模式（要避免）

❌ **上帝序列**：一个sequence做完所有事情，包括结果检查 → 拆分sequence和scoreboard
❌ **硬编码配置**：不能配置地址宽度数据宽度 → 参数化
❌ **多层太深**：超过5层嵌套，调试困难 → 合理分层
❌ **不看覆盖率**：认为所有测试通过就完成了 → 覆盖率必须达到目标
❌ **打印太多日志**：日志几G，根本打不开 → 合理控制日志级别

## 代理协作

- 使用 `verification-engineer` 代理进行验证开发
- 使用 `code-reviewer` 代理进行代码审查
- 断言验证配合使用 `assertion-based-verification` 技能
