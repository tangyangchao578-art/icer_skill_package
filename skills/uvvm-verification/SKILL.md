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

## 行业经验数值

### 覆盖率目标

| 覆盖率类型 | 目标值 | 说明 |
|------------|--------|------|
| 行覆盖率 | ≥ 95% | 所有语句至少执行一次 |
| 条件覆盖率 | ≥ 90% | 所有条件分支至少执行一次 |
| 翻转覆盖率 | ≥ 85% | 所有寄存器位翻转 |
| FSM 覆盖率 | 100% | 所有状态和转换 |
| 功能覆盖率 | 100% | 所有功能点覆盖 |

### 验证时间估算

| 设计复杂度 | 代码行数 | 验证时间 | 验证人员 |
|------------|----------|----------|----------|
| 小型模块 | < 1K 行 | 2-4 周 | 1 人 |
| 中型模块 | 1K-10K 行 | 1-3 月 | 1-2 人 |
| 大型模块 | 10K-50K 行 | 3-6 月 | 2-4 人 |
| 子系统 | 50K-200K 行 | 6-12 月 | 4-8 人 |
| SoC | > 200K 行 | 12-24 月 | 8-20 人 |

### 回归测试周期

| 设计阶段 | 测试用例数 | 回归时间 | 频率 |
|----------|------------|----------|------|
| 功能开发 | 100-500 | < 1 小时 | 每次提交 |
| 功能完成 | 500-2000 | 1-4 小时 | 每日 |
| 回归阶段 | 2000-10000 | 4-24 小时 | 每周 |
| 流片前 | > 10000 | > 24 小时 | 每周 |

### Bug 密度参考

| 阶段 | Bug/KLOC | 说明 |
|------|----------|------|
| 功能开发 | 5-10 | 正常 |
| 功能完成 | 1-3 | 逐步减少 |
| 回归阶段 | 0.1-0.5 | 大部分已修复 |
| 流片前 | < 0.01 | 几乎无新 Bug |

---

## 故障诊断框架

### 症状1：覆盖率不收敛

**诊断步骤：**

```
1. 分析覆盖率报告
2. 识别未覆盖的代码/功能
3. 检查测试用例
4. 检查约束
```

**判断标准：**

| 覆盖率 | 判断 | 行动 |
|--------|------|------|
| > 95% | 良好 | 继续 |
| 90-95% | 接近 | 补充测试用例 |
| 80-90% | 不足 | 检查约束 |
| < 80% | 严重 | 重新评估验证策略 |

**根本原因定位：**

| 根本原因 | 诊断特征 | 解决方案 |
|----------|----------|----------|
| 约束过紧 | 随机值不发散 | 放宽约束 |
| 测试用例不足 | 功能点未覆盖 | 补充测试用例 |
| 死代码 | 无法覆盖 | 检查 RTL |
| 边界条件遗漏 | 边界未覆盖 | 添加边界测试 |

### 症状2：仿真挂起

**诊断步骤：**

```
1. 检查仿真时间
2. 查看波形
3. 检查 UVM phase
4. 检查 objection
```

**根本原因定位：**

| 根本原因 | 诊断特征 | 解决方案 |
|----------|----------|----------|
| 死锁 | 等待信号不变化 | 检查握手协议 |
| 无限循环 | 时间不推进 | 检查循环条件 |
| Objection 泄漏 | phase 不结束 | 检查 objection |
| 事件未触发 | 等待条件不满足 | 检查事件触发 |

### 症状3：功能错误多

**诊断步骤：**

```
1. 分析错误日志
2. 分类错误类型
3. 定位错误模块
4. 分析错误原因
```

**根本原因定位：**

| 根本原因 | 诊断特征 | 解决方案 |
|----------|----------|----------|
| 规格理解错误 | 测试用例错误 | 重新理解规格 |
| RTL Bug | 波形不正确 | 修复 RTL |
| 测试平台错误 | 预期值错误 | 修复测试平台 |
| 时序问题 | 竞争条件 | 修复时序 |

### 症状4：仿真速度慢

**诊断步骤：**

```
1. 分析仿真时间分布
2. 检查日志输出
3. 检查覆盖率收集
4. 检查波形转储
```

**根本原因定位：**

| 根本原因 | 诊断特征 | 解决方案 |
|----------|----------|----------|
| 日志过多 | 打印时间占比高 | 减少日志 |
| 波形转储 | 磁盘 I/O 高 | 仅转储关键信号 |
| 覆盖率开销 | 内存占用高 | 优化覆盖率 |
| 设计效率低 | 仿真时间长 | 优化模型 |

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

## 步骤 4：验证环境搭建

验证环境搭建需要按顺序完成：接口 → 事务 → Driver → Monitor → Agent → Env → Test。

### 4.1 接口编写

**做什么：** 定义 DUT 与验证环境的连接接口。

**接口编写模板：**

```systemverilog
interface dut_if #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input  wire clk,
    input  wire rst_n
);
    // 时钟和复位
    logic        clk;
    logic        rst_n;

    // 输入信号
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;
    logic                  wr_en;
    logic                  rd_en;

    // 输出信号
    logic [DATA_WIDTH-1:0] rdata;
    logic                  ready;
    logic                  error;

    // 时钟块（用于同步）
    clocking cb @(posedge clk);
        default input #1ns output #1ns;
        output addr, wdata, wr_en, rd_en;
        input  rdata, ready, error;
    endclocking

    // modport for DUT
    modport dut (
        input  clk, rst_n, addr, wdata, wr_en, rd_en,
        output rdata, ready, error
    );

    // modport for Driver
    modport driver (
        clocking cb,
        output  rst_n
    );

    // modport for Monitor
    modport monitor (
        clocking cb
    );

endinterface
```

**接口编写检查清单：**
- [ ] 所有 DUT 信号都已定义
- [ ] 信号位宽正确
- [ ] 添加了 clocking block（同步）
- [ ] 定义了 modport（DUT/Driver/Monitor）
- [ ] 参数化设计（位宽可配置）

### 4.2 事务编写

**做什么：** 定义验证环境中传递的数据结构。

**事务编写模板：**

```systemverilog
class dut_trans extends uvm_sequence_item;
    `uvm_object_utils(dut_trans)

    // 随机化字段
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit        wr_en;
    rand bit        rd_en;

    // 约束
    constraint c_addr_align {
        addr[1:0] == 2'b00;  // 4字节对齐
    }

    constraint c_valid_trans {
        wr_en != rd_en;  // 读写互斥
    }

    // 覆盖点
    covergroup trans_cg;
        cp_addr: coverpoint addr {
            bins low  = {[0:32'h0000FFFF]};
            bins mid  = {[32'h00010000:32'hFFFF0000]};
            bins high = {[32'hFFFF0001:32'hFFFFFFFF]};
        }
        cp_wr: coverpoint wr_en;
        cp_rd: coverpoint rd_en;
    endgroup

    function new(string name = "dut_trans");
        super.new(name);
        trans_cg = new();
    endfunction

    function void post_randomize();
        trans_cg.sample();
    endfunction

    // 复制、比较、打印方法
    virtual function void do_copy(uvm_object rhs);
        dut_trans rhs_;
        super.do_copy(rhs);
        $cast(rhs_, rhs);
        addr  = rhs_.addr;
        data  = rhs_.data;
        wr_en = rhs_.wr_en;
        rd_en = rhs_.rd_en;
    endfunction

    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        dut_trans rhs_;
        bit same = super.do_compare(rhs, comparer);
        $cast(rhs_, rhs);
        same = (addr == rhs_.addr) &&
               (data == rhs_.data) &&
               (wr_en == rhs_.wr_en) &&
               (rd_en == rhs_.rd_en);
        return same;
    endfunction

    virtual function string convert2string();
        return $sformatf("addr=0x%8h, data=0x%8h, wr=%b, rd=%b",
                         addr, data, wr_en, rd_en);
    endfunction

endclass
```

**事务编写检查清单：**
- [ ] 所有传输数据字段都已定义
- [ ] 关键字段添加了随机约束
- [ ] 添加了功能覆盖点
- [ ] 实现了 do_copy、do_compare、convert2string
- [ ] 使用 `uvm_object_utils 注册

### 4.3 Driver 编写

**做什么：** 将事务转换为 DUT 接口信号。

**Driver 编写模板：**

```systemverilog
class dut_driver extends uvm_driver #(dut_trans);
    `uvm_component_utils(dut_driver)

    virtual dut_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("build_phase", "Failed to get vif")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_trans(req);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_trans(dut_trans trans);
        // 等待时钟沿
        @(vif.cb);

        // 驱动信号
        vif.cb.addr  <= trans.addr;
        vif.cb.data  <= trans.data;
        vif.cb.wr_en <= trans.wr_en;
        vif.cb.rd_en <= trans.rd_en;

        // 等待响应
        wait(vif.cb.ready);

        `uvm_info("drive_trans", trans.convert2string(), UVM_HIGH)
    endtask

endclass
```

**Driver 编写检查清单：**
- [ ] 从 config_db 获取 virtual interface
- [ ] 实现 run_phase 的 forever 循环
- [ ] 使用 seq_item_port 与 sequencer 通信
- [ ] 正确使用 clocking block 同步
- [ ] 添加日志信息（UVM_HIGH 级别）

### 4.4 Monitor 编写

**做什么：** 观察接口信号，转换为事务。

**Monitor 编写模板：**

```systemverilog
class dut_monitor extends uvm_monitor;
    `uvm_component_utils(dut_monitor)

    virtual dut_if vif;
    uvm_analysis_port #(dut_trans) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("build_phase", "Failed to get vif")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            collect_trans();
        end
    endtask

    virtual task collect_trans();
        dut_trans trans;

        // 等待有效信号
        wait(vif.cb.ready);

        // 采样信号
        trans = dut_trans::type_id::create("trans");
        trans.addr  = vif.cb.addr;
        trans.data  = vif.cb.data;
        trans.wr_en = vif.cb.wr_en;
        trans.rd_en = vif.cb.rd_en;

        // 发送到 analysis port
        ap.write(trans);

        `uvm_info("collect_trans", trans.convert2string(), UVM_HIGH)
    endtask

endclass
```

**Monitor 编写检查清单：**
- [ ] 创建 uvm_analysis_port
- [ ] 正确采样接口信号
- [ ] 将观察到的事务发送到 analysis port
- [ ] 不修改 DUT 信号（只观察）

### 4.5 Agent 编写

**做什么：** 封装 Driver、Monitor、Sequencer。

**Agent 编写模板：**

```systemverilog
class dut_agent extends uvm_agent;
    `uvm_component_utils(dut_agent)

    dut_driver    driver;
    dut_sequencer sequencer;
    dut_monitor   monitor;
    virtual dut_if vif;

    // 配置：ACTIVE 或 PASSIVE
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // 获取配置
        if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("build_phase", "Failed to get vif")
        end

        // 创建 Monitor（总是创建）
        monitor = dut_monitor::type_id::create("monitor", this);
        uvm_config_db#(virtual dut_if)::set(this, "monitor", "vif", vif);

        // 根据 is_active 决定是否创建 Driver 和 Sequencer
        if (is_active == UVM_ACTIVE) begin
            driver    = dut_driver::type_id::create("driver", this);
            sequencer = dut_sequencer::type_id::create("sequencer", this);
            uvm_config_db#(virtual dut_if)::set(this, "driver", "vif", vif);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // 连接 Driver 和 Sequencer
        if (is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction

endclass
```

**Agent 编写检查清单：**
- [ ] 支持 ACTIVE/PASSIVE 模式
- [ ] 正确创建和连接组件
- [ ] 通过 config_db 传递 interface
- [ ] Monitor 总是创建
- [ ] Driver/Sequencer 只在 ACTIVE 模式创建

### 4.6 Environment 编写

**做什么：** 组装所有组件。

**Environment 编写模板：**

```systemverilog
class dut_env extends uvm_env;
    `uvm_component_utils(dut_env)

    dut_agent     agent;
    dut_scoreboard scoreboard;
    dut_coverage  coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent     = dut_agent::type_id::create("agent", this);
        scoreboard = dut_scoreboard::type_id::create("scoreboard", this);
        coverage  = dut_coverage::type_id::create("coverage", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Monitor → Scoreboard
        agent.monitor.ap.connect(scoreboard.analysis_export);

        // Monitor → Coverage
        agent.monitor.ap.connect(coverage.analysis_export);
    endfunction

endclass
```

**Environment 编写检查清单：**
- [ ] 创建所有需要的组件
- [ ] 正确连接 TLM 端口
- [ ] 通过 config_db 传递配置

### 4.7 Test 编写

**做什么：** 定义测试场景，配置验证环境。

**Test 编写模板：**

```systemverilog
class dut_base_test extends uvm_test;
    `uvm_component_utils(dut_base_test)

    dut_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = dut_env::type_id::create("env", this);

        // 配置
        uvm_config_db#(uvm_active_passive_enum)::set(
            this, "env.agent", "is_active", UVM_ACTIVE
        );
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        // 打印拓扑
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        dut_default_seq seq;

        phase.raise_objection(this, "Starting test");

        seq = dut_default_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);

        phase.drop_objection(this, "Test finished");
    endtask

endclass
```

**Test 编写检查清单：**
- [ ] 创建 environment
- [ ] 配置所有组件
- [ ] 在 run_phase 中启动 sequence
- [ ] 正确使用 objection
- [ ] 打印拓扑验证连接

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

## 步骤 6：验证环境调试

验证环境搭建完成后，需要进行调试确保正确性。

### 6.1 编译调试

**常见编译错误：**

| 错误类型 | 原因 | 解决方法 |
|----------|------|----------|
| 未定义类型 | 缺少 `include` | 添加 ``include "file.sv"` |
| 工厂注册缺失 | 缺少 `uvm_object_utils` | 添加工厂注册宏 |
| 端口不匹配 | TLM 端口类型错误 | 检查 `uvm_analysis_port` vs `uvm_analysis_export` |
| 参数不匹配 | 参数化类型错误 | 检查 `#(TRANS)` 参数 |

### 6.2 连接调试

**检查连接正确性：**

```systemverilog
// 在 end_of_elaboration_phase 打印拓扑
virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
endfunction
```

**检查项：**
- [ ] 所有组件都创建成功
- [ ] 所有 TLM 端口都连接
- [ ] config_db 传递正确
- [ ] virtual interface 获取成功

### 6.3 功能调试

**调试方法：**

1. **使用 UVM 日志**

```systemverilog
// 设置日志级别
set_report_verbosity_level_hier(UVM_HIGH);

// 设置特定组件日志
env.agent.driver.set_report_verbosity_level(UVM_DEBUG);
```

2. **使用波形调试**

```tcl
# VCS
fsdbDumpfile("wave.fsdb");
fsdbDumpvars(0, tb_top);

# Xcelium
probe -create tb_top -depth all
```

3. **检查 Objection**

```systemverilog
// 检查 objection 状态
virtual function void phase_ready_to_end(uvm_phase phase);
    if (phase.get_name() == "run") begin
        `uvm_info("objection", "Run phase ending", UVM_LOW)
    end
endfunction
```

### 6.4 常见问题诊断

| 问题现象 | 可能原因 | 诊断方法 | 解决方法 |
|----------|----------|----------|----------|
| 仿真立即结束 | Objection 未 raise | 检查 run_phase | 添加 `phase.raise_objection` |
| 仿真挂起 | Objection 未 drop | 检查 objection 计数 | 确保 `drop_objection` 被调用 |
| 无激励产生 | Sequence 未启动 | 检查 sequencer 连接 | 检查 `seq.start(env.agent.sequencer)` |
| 数据不正确 | Monitor 采样时机错误 | 查看波形 | 使用 clocking block |
| 覆盖率不更新 | 覆盖点未 sample | 检查 sample 调用 | 添加 `trans_cg.sample()` |

---

## 步骤 7：回归测试

### 7.1 回归测试策略

| 回归类型 | 测试用例数 | 运行频率 | 预期时间 |
|----------|------------|----------|----------|
| Smoke 测试 | 10-50 | 每次提交 | < 10 分钟 |
| Nightly 测试 | 100-500 | 每晚 | 1-4 小时 |
| 完整回归 | 500-2000 | 每周 | 4-24 小时 |
| Tapeout 测试 | > 2000 | 流片前 | > 24 小时 |

### 7.2 测试用例管理

**测试用例分类：**

```systemverilog
// 使用 UVM test 进行分类
class smoke_test extends dut_base_test;
    // 快速冒烟测试
endclass

class feature_test extends dut_base_test;
    // 功能测试
endclass

class regression_test extends dut_base_test;
    // 回归测试
endclass

class stress_test extends dut_base_test;
    // 压力测试
endclass
```

**运行命令：**

```bash
# VCS
vcs -sverilog -ntb_opts uvm \
    +UVM_TESTNAME=smoke_test \
    +UVM_VERBOSITY=UVM_HIGH \
    -l run.log

# Xcelium
xrun -sv -uvm \
    +UVM_TESTNAME=feature_test \
    +UVM_VERBOSITY=UVM_MEDIUM \
    -log run.log
```

### 7.3 覆盖率合并

**合并多个测试的覆盖率：**

```tcl
# VCS
urg -dir simv.vdb -dir test1.vdb -dir test2.vdb \
    -report coverage_report

# Xcelium
imc -exec coverage_merge.tcl
```

**覆盖率合并脚本示例：**

```tcl
# coverage_merge.tcl
open_database test1.ucd
merge_database test2.ucd test3.ucd test4.ucd
report_coverage -totals -by_instance
exit
```

---

## 步骤 8：验证收敛判断

### 8.1 收敛标准

验证完成条件（**全部满足**才算收敛）：

| 检查项 | 标准 | 当前状态 |
|--------|------|----------|
| 所有测试用例通过 | 100% | [ ] |
| 行覆盖率 | ≥ 95% | [ ] |
| 条件覆盖率 | ≥ 90% | [ ] |
| 翻转覆盖率 | ≥ 85% | [ ] |
| FSM 覆盖率 | 100% | [ ] |
| 功能覆盖率 | 100% | [ ] |
| 所有 Bug 已修复 | 无 open Bug | [ ] |
| 回归测试稳定 | 连续 3 天无新 Bug | [ ] |

### 8.2 覆盖率分析

**覆盖率缺口分析：**

```
1. 运行所有测试用例
2. 合并覆盖率报告
3. 识别未覆盖代码/功能
4. 分析原因
5. 添加测试用例覆盖缺口
```

**覆盖率缺口原因分析：**

| 缺口类型 | 可能原因 | 解决方法 |
|----------|----------|----------|
| 死代码 | 不可达代码 | 检查 RTL，可能删除 |
| 边界条件 | 测试用例未覆盖 | 添加边界测试 |
| 异常路径 | 约束过紧 | 放宽约束 |
| 功能遗漏 | 测试计划不完整 | 补充测试计划 |

### 8.3 Bug 趋势追踪

**Bug 趋势指标：**

| 指标 | 定义 | 收敛标准 |
|------|------|----------|
| Bug 发现率 | 每周新发现 Bug 数 | 持续下降 |
| Bug 修复率 | 已修复 Bug / 总 Bug | > 95% |
| Bug 重开率 | 重开 Bug / 已修复 Bug | < 5% |
| Bug 密度 | Bug 数 / KLOC | < 0.1 |

**Bug 趋势图：**

```
Bug 数量
    ^
    |     新发现 Bug
    |        *
    |      *   *
    |    *       *
    |  *           *    ← 期望趋势
    |*               *
    +-------------------> 时间
```

### 8.4 验证签收清单

**签收前检查：**

- [ ] 所有测试用例通过
- [ ] 覆盖率达标
- [ ] 功能覆盖率 100%
- [ ] 所有断言通过
- [ ] 无 open Bug
- [ ] 回归测试稳定
- [ ] 验证报告完成
- [ ] 代码审查通过
- [ ] 文档更新完成

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
