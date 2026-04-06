---
name: uvvm-verification
description: UVM 验证方法论技能 - 从验证计划到功能覆盖率，完整 UVM 验证平台开发
description.zh: UVM 验证方法论技能 - 从验证计划到功能覆盖率，完整 UVM 验证平台开发
origin: ICER
categories: verification
---

# UVM 验证方法论技能

当用户需要开发 UVM 验证平台时，启用此技能。遵循 IEEE 标准 UVM，一步一步完成验证开发，从验证计划到功能覆盖率。

## When to Activate

- 开发新的 UVM 验证平台
- 优化现有 UVM 验证平台结构
- 调试 UVM 验证平台问题
- 从 legacy 验证方法迁移到 UVM
- 代码审查 UVM 验证平台

---

## 第一步：制定验证计划

验证开始前必须制定验证计划，明确验证范围和目标。

### 验证计划内容

| 内容 | 说明 |
|------|------|
| **DUT 功能描述** | 简要说明 DUT 要实现的功能 |
| **功能点列表** | 所有需要验证的功能点，枚举 |
| **测试类型** | 定向测试/随机测试/约束随机 |
| **覆盖率目标** | 代码覆盖率目标，功能覆盖率目标 |
| **收敛标准** | 达到什么标准验证完成 |

### 功能点枚举示例

对于一个异步 FIFO，功能点包括：
- [ ] 空状态读写正确
- [ ] 满状态读写正确
- [ ] 半满状态读写正确
- [ ] 异步复位正确
- [ ] 不同时钟频率工作正确
- [ ] X 传播正确

### 覆盖率目标

```
代码覆盖率：
  - 行覆盖率 >= 90%
  - 条件覆盖率 >= 80%
  - 翻转覆盖率 >= 85%
  - FSM 覆盖率 = 100%

功能覆盖率：
  - 所有功能点 100% 覆盖
```

---

## 第二步：制定验证方案

根据验证计划制定验证方案。

### 验证平台架构

标准 UVM 验证平台结构：

```
testbench/
├── tb_top.sv           # 测试平台顶层（例化DUT和接口）
├── interfaces/          # DUT接口定义
│   └── bus_if.sv
├── agents/             # agent (driver + monitor + sequencer)
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

### 验证策略

- **定向测试**：验证特定功能点，适合边界情况
- **约束随机测试**：随机生成激励，覆盖更多 corner case
- **覆盖率驱动**：根据覆盖率添加缺失测试
- **断言补充**：接口属性断言，自动检查

---

## 第三步：测试点撰写

每个功能点对应一个测试点，明确测试什么，怎么测试。

### 测试点模板

```
测试点 ID: TP-001
测试点名称: 异步FIFO满状态测试
测试点描述: 当FIFO满了，写请求应该被忽略，满信号应该正确输出
测试方法: 连续写直到满，检查满信号，检查数据正确
优先级: P1
覆盖分组: 边界条件
```

### 测试点优先级

- **P1**：必须测试，核心功能
- **P2**：应该测试，非核心功能
- **P3**：可选测试，覆盖盲区

### 功能覆盖率覆盖点

每个测试点对应功能覆盖率覆盖点：

```systemverilog
covergroup fifo_cg {
  option.per_instance = 1;
  empty: coverpoint fifo_empty {
    bins empty = {1};
    bins not_empty = {0};
  }
  full: coverpoint fifo_full {
    bins full = {1};
    bins not_full = {0};
  }
  half_full: coverpoint fifo_counter {
    bins low[] = {[0:DEPTH/2-1], [DEPTH/2+1:DEPTH-1]};
    bins mid = {DEPTH/2};
  }
}
```

---

## 第四步：验证环境撰写

按模块撰写验证环境。

### 1. 接口 (interface)

```systemverilog
interface fifo_if #(
  parameter DATA_WIDTH = 32
)(
  input wr_clk,
  input rd_clk,
  input rst_n
);

  logic             wr_en;
  logic [DATA_WIDTH-1:0] wr_data;
  logic             rd_en;
  logic [DATA_WIDTH-1:0] rd_data;
  logic             empty;
  logic             full;

  // modport for DUT
  modport dut (
    input  wr_clk, rd_clk, rst_n,
    input  wr_en, wr_data, rd_en,
    output rd_data, empty, full
  );

  // modport for testbench
  modport tb (
    output wr_en, wr_data, rd_en,
    input  rd_data, empty, full
  );

endinterface
```

### 2. 事务 (transaction)

```systemverilog
class fifo_trans extends uvm_sequence_item;
  `uvm_object_utils(fifo_trans)

  rand bit [DATA_WIDTH-1:0] data;
  rand bit             write;
  rand bit             read;

  // 约束：写的时候读可以随机
  constraint c_write_read {
    solve write before data;
  }

  function new(string name = "fifo_trans");
    super.new(name);
  endfunction

endclass
```

### 3. Agent

```systemverilog
class fifo_agent extends uvm_agent;
  `uvm_component_utils(fifo_agent)

  fifo_driver    driver;
  fifo_sequencer sequencer;
  fifo_monitor   monitor;
  virtual fifo_if vif;
  bit is_active = 1;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // get interface from config db
    if (!uvm_config_db#(virtual fifo_if)::get(this, "", "fifo_vif", vif)) begin
      `uvm_fatal("build_phase", "Failed to get vif")
    end
    if (is_active) begin
      driver    = fifo_driver::type_id::create("driver", this);
      sequencer = fifo_sequencer::type_id::create("sequencer", this);
    end
    monitor = fifo_monitor::type_id::create("monitor", this);
  endfunction

endclass
```

### 4. Environment

```systemverilog
class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  fifo_agent agent;
  fifo_scoreboard scoreboard;
  fifo_coverage coverage;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = fifo_agent::type_id::create("agent", this);
    scoreboard = fifo_scoreboard::type_id::create("scoreboard", this);
    coverage = fifo_coverage::type_id::create("coverage", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    agent.monitor.ap.connect(scoreboard.analysis_export);
    agent.monitor.ap.connect(coverage.analysis_export);
  endfunction

endclass
```

### 5. Test

```systemverilog
class fifo_base_test extends uvm_test;
  `uvm_component_utils(fifo_base_test)

  fifo_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
    // set interface in config db
    uvm_config_db#(virtual fifo_if)::set(this, "env.agent", "fifo_vif", fifo_vif);
  endfunction

  virtual task run_phase(uvm_phase phase);
    fifo_default_seq seq = fifo_default_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sequencer);
    phase.drop_objection(this);
  endtask

endclass
```

---

## 第五步：功能覆盖率收集

### 功能覆盖率定义

在 coverage 组件收集：

```systemverilog
class fifo_coverage extends uvm_component;
  `uvm_component_utils(fifio_coverage)

  uvm_analysis_export #(fifo_trans) analysis_export;
  covergroup fifo_function_cg;
    // 所有功能点覆盖
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
    fifo_function_cg = new();
  endfunction

  function void write(fifo_trans t);
    fifo_function_cg.sample();
  endfunction

endclass
```

### 覆盖率收敛

- 每次仿真收集覆盖率
- 合并所有测试的覆盖率
- 找出未覆盖的功能点
- 添加对应测试覆盖
- 达到 100% 功能覆盖率才算收敛

---

## UVM 编码准则

### 工厂注册

所有组件和事务都必须工厂注册：

```systemverilog
// 组件注册
`uvm_component_utils(my_agent)

// 事务注册
`uvm_object_utils(my_transaction)
`uvm_object_utils_begin(my_transaction)
  `uvm_field_int(addr, UVM_ALL_ON)
  `uvm_field_int(data, UVM_ALL_ON)
`uvm_object_utils_end
```

### phase 机制

遵循 UVM phase 顺序：

| Phase | 用途 |
|-------|------|
| **build_phase** | 创建所有子组件 |
| **connect_phase** | 连接 TLM 端口 |
| **end_of_elaboration** | 最后调整，打印配置 |
| **run_phase** | 运行测试，产生激励 |
| **extract_phase** | 提取覆盖率和结果 |
| **check_phase** | 检查结果正确性 |
| **report_phase** | 打印报告统计 |

**✅ 永远**：每个 phase 必须调用 `super.phase()`

```systemverilog
virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);  // 必须调用父类
  // 你的代码...
endfunction
```

### 配置数据库

使用 `uvm_config_db` 传递配置，不要全局变量：

```systemverilog
// 发送配置：在 test
uvm_config_db#(virtual fifo_if)::set(this, "*env.agent*", "fifo_vif", fifo_if);

// 获取配置：在 agent
if (!uvm_config_db#(virtual fifo_if)::get(this, "", "fifo_vif", vif)) begin
  `uvm_fatal(get_full_name(), "Failed to get fifo_vif from config db");
end
```

---

## 检查清单

验证平台完成检查：

- [ ] 所有功能点都对应测试点
- [ ] 验证平台结构符合标准
- [ ] 所有组件正确工厂注册
- [ ] 每个 phase 调用 `super.phase()`
- [ ] 正确使用 objection 控制仿真结束
- [ ] 配置通过 `uvm_config_db` 传递
- [ ] 没有全局变量
- [ ] sequence 只产生激励，不做结果检查
- [ ] 所有功能覆盖点都已定义
- [ ] 覆盖率目标明确

---

## 验证收敛标准

验证完成条件（**全部满足**才算完成）：

- [ ] 所有计划的测试点都已执行
- [ ] 所有测试用例都通过
- [ ] 代码覆盖率达到目标
- [ ] 功能覆盖率 100%
- [ ] 所有断言都没有失败
- [ ] 所有 open issue 都已分析处理

---

## 常见错误

| 错误 | 后果 | 修复 |
|------|------|------|
| 忘记 `super.phase()` | 父类不执行，组件没创建 | 添加 `super.phase()` |
| 忘记 objection | 仿真立即结束 | 添加 `raise_objection` / `drop_objection` |
| 在 `build_phase` 之前 get | 配置还没设置，get 失败 | 在 `build_phase` 里面 get |
| driver 里面做结果检查 | 破坏分层，难以复用 | 结果检查移到 scoreboard |
| 不检查 get 成功失败 | 失败了还继续，难 debug | 失败 `uvm_fatal` |

---

## 工具支持

- Synopsys VCS → 完全支持
- Cadence Xcelium → 完全支持
- Siemens Questa → 完全支持
- 开源：Verilator → 支持基本 UVM

---

## 反模式（要避免）

❌ **上帝 sequence**：一个 sequence 做完所有事情包括结果检查 → 拆分 sequence 和 scoreboard
❌ **硬编码配置** → 不能配置不同位宽 → 参数化配置
❌ **嵌套太深** → 超过 5 层嵌套，调试困难 → 合理分层
❌ **不收集覆盖率** → 认为测试通过就是完成 → 必须达到覆盖率目标
❌ **日志太多** → 日志文件几 G，打不开 → 合理控制日志级别

## 代理协作

- 使用 `verification-engineer` 代理进行验证开发
- 使用 `code-reviewer` 代理进行代码审查
- 断言验证配合使用 `assertion-based-verification` 技能
