---
name: assertion-based-verification
description: 断言验证技能 - SVA (SystemVerilog Assertion) 断言设计和验证最佳实践
description.zh: 断言验证技能 - SVA (SystemVerilog Assertion) 断言设计和验证最佳实践
origin: ICER
categories: verification
---

# 断言验证技能

当用户需要使用 SVA (SystemVerilog Assertion) 进行断言验证时，启用此技能。提供断言设计、放置、调试最佳实践。

## When to Activate

- 为接口协议添加属性断言
- 为状态机添加属性断言
- 检查设计不变量
- 检查时序属性
- 为形式验证定义属性
- 调试时序问题

---

## 步骤 1：理解断言类型

### 1.1 立即断言 vs 并发断言

**立即断言：**
- 在过程块中执行
- 立即检查，不涉及时序
- 用于检查组合逻辑

```systemverilog
// 立即断言：在过程块中
always_comb begin
    // 检查条件必须满足
    assert (fifo_full || !wr_en) else
        $error("Write when FIFO full!");
end
```

**并发断言：**
- 在时钟沿检查
- 描述时序属性
- 用于检查协议和时序

```systemverilog
// 并发断言：描述时序属性
property req_ack;
    @(posedge clk) req |-> ##[1:10] ack;
endproperty
assert property(req_ack);
```

### 1.2 选择断言类型

| 场景 | 断言类型 | 说明 |
|------|----------|------|
| 检查组合逻辑条件 | 立即断言 | 立即检查 |
| 检查协议时序 | 并发断言 | 描述时序序列 |
| 检查状态机转换 | 并发断言 | 描述状态序列 |
| 检查复位期间状态 | 并发断言 | 带条件禁用 |
| 检查不变量 | 并发断言 | 始终为真的属性 |

---

## 步骤 2：编写基本断言

### 2.1 编写简单属性

**做什么：** 编写最基本的状态检查断言。

```systemverilog
// 检查复位后状态正确
assert property (@(posedge clk) !rst_n |-> state == ST_IDLE)
    else $error("State not IDLE during reset");

// 检查 FIFO 不空时才能读
assert property (@(posedge clk) rd_en |-> !empty)
    else $error("Read when FIFO empty");

// 检查 FIFO 不满时才能写
assert property (@(posedge clk) wr_en |-> !full)
    else $error("Write when FIFO full");
```

### 2.2 使用蕴含操作符

**做什么：** 使用 `|->` 和 `|=>` 描述因果关系。

| 操作符 | 含义 | 示例 |
|--------|------|------|
| `|->` | 同一周期 | `a |-> b`：a 发生时，同一周期 b 必须为真 |
| `|=>` | 下一周期 | `a |=> b`：a 发生后，下一周期 b 必须为真 |

```systemverilog
// 请求后必须有应答（1-10 周期）
property req_ack;
    @(posedge clk) req |-> ##[1:10] ack;
endproperty
assert property(req_ack);

// 请求后下一周期开始处理
property req_start;
    @(posedge clk) req |=> processing;
endproperty
assert property(req_start);
```

### 2.3 使用序列操作符

**做什么：** 使用序列操作符描述复杂时序。

| 操作符 | 含义 | 示例 |
|--------|------|------|
| `##n` | 延迟 n 周期 | `a ##3 b`：a 后 3 周期 b |
| `##[m:n]` | 延迟 m-n 周期范围 | `a ##[1:5] b`：a 后 1-5 周期 b |
| `##[*]` | 延迟任意周期 | `a ##[*] b`：a 后任意周期 b |
| `##[+]` | 延迟至少 1 周期 | `a ##[+] b`：a 后至少 1 周期 b |

```systemverilog
// 写后必须等待 2 周期才能读
property wr_rd_delay;
    @(posedge clk) wr_en |-> ##2 rd_en;
endproperty

// 请求后 1-10 周期必须有应答
property req_ack_range;
    @(posedge clk) req |-> ##[1:10] ack;
endproperty

// 开始后最终必须结束
property start_end;
    @(posedge clk) start |-> ##[*] done;
endproperty
```

---

## 步骤 3：编写常用断言模式

### 3.1 请求-应答协议

**场景：** 请求发生后必须在一定周期内得到应答。

```systemverilog
// 请求后 1-10 周期必须有应答
property req_must_ack;
    @(posedge clk) req |-> ##[1:10] ack;
endproperty
assert property(req_must_ack)
    else $error("No ACK received within 10 cycles after REQ");

// 请求必须保持直到应答
property req_stable_until_ack;
    @(posedge clk) $rose(req) |-> req throughout (##[1:$] ack);
endproperty
assert property(req_stable_until_ack)
    else $error("REQ must be stable until ACK");
```

### 3.2 握手协议

**场景：** valid/ready 握手协议。

```systemverilog
// valid 为高时，data 必须稳定
property valid_data_stable;
    @(posedge clk) valid |-> $stable(data);
endproperty
assert property(valid_data_stable)
    else $error("DATA must be stable when VALID is high");

// ready 为低时，valid 不能变为高（背压）
property backpressure;
    @(posedge clk) !ready |-> !valid;
endproperty
assert property(backpressure)
    else $error("VALID must be low when READY is low");

// valid 和 ready 同时为高时，传输成功
property handshake_success;
    @(posedge clk) (valid && ready) |-> ##1 !valid;
endproperty
// 可选：取决于协议
```

### 3.3 互斥检查

**场景：** 两个信号不能同时为高。

```systemverilog
// 读写不能同时发生
property rw_exclusive;
    @(posedge clk) not (rd_en && wr_en);
endproperty
assert property(rw_exclusive)
    else $error("Read and Write cannot happen simultaneously");

// 两个状态机不能同时活跃
property state_mutex;
    @(posedge clk) not (state_a_active && state_b_active);
endproperty
assert property(state_mutex);
```

### 3.4 状态机转换检查

**场景：** 检查状态机只能进行合法转换。

```systemverilog
// 定义合法状态转换
property legal_state_transition;
    @(posedge clk)
    state == ST_IDLE |-> ##1 state inside {ST_IDLE, ST_DATA, ST_ERROR};
endproperty
assert property(legal_state_transition)
    else $error("Illegal state transition from IDLE");

// 不能直接从 IDLE 到 DONE
property no_idle_to_done;
    @(posedge clk) not (state == ST_IDLE ##1 state == ST_DONE);
endproperty
assert property(no_idle_to_done);
```

### 3.5 FIFO 检查

**场景：** FIFO 相关属性检查。

```systemverilog
// FIFO 不满才能写
property wr_when_not_full;
    @(posedge clk) wr_en |-> !full;
endproperty
assert property(wr_when_not_full)
    else $error("Write when FIFO full");

// FIFO 不空才能读
property rd_when_not_empty;
    @(posedge clk) rd_en |-> !empty;
endproperty
assert property(rd_when_not_empty)
    else $error("Read when FIFO empty");

// FIFO 满时不能再写
property no_wr_when_full;
    @(posedge clk) full |-> !wr_en;
endproperty
assert property(no_wr_when_full);
```

---

## 步骤 4：处理复位

### 4.1 使用 disable iff 禁用复位期间断言

**做什么：** 复位期间断言不检查。

```systemverilog
// 复位期间禁用断言
property reset_correct;
    @(posedge clk) disable iff (!rst_n)
    !rst_n ##1 rst_n |-> state == ST_IDLE;
endproperty
assert property(reset_correct)
    else $error("State not IDLE after reset");
```

### 4.2 检查复位后状态

**做什么：** 检查复位释放后状态正确。

```systemverilog
// 复位释放后状态必须正确
property state_after_reset;
    @(posedge clk)
    !rst_n ##1 rst_n |-> (state == ST_IDLE && counter == 0);
endproperty
assert property(state_after_reset)
    else $error("State not correct after reset release");
```

---

## 步骤 5：断言放置

### 5.1 放置在接口模块

**做什么：** 在接口协议层放置断言，检查协议遵守。

```systemverilog
module axi_interface (
    input  wire        clk,
    input  wire        rst_n,
    // AXI 信号
    input  wire [31:0] awaddr,
    input  wire        awvalid,
    output logic       awready,
    // ...
);
    // AXI 协议断言

    // AWVALID 必须保持直到 AWREADY
    property aw_stable;
        @(posedge clk) disable iff (!rst_n)
        awvalid |-> awvalid throughout (##[1:$] awready);
    endproperty
    assert property(aw_stable);

    // WVALID 必须在 AWVALID 之后或同时
    property w_after_aw;
        @(posedge clk) disable iff (!rst_n)
        $rose(awvalid) |-> ##[0:$] wvalid;
    endproperty
    assert property(w_after_aw);

    // BVALID 必须在 WVALID 和 WREADY 之后
    property b_after_w;
        @(posedge clk) disable iff (!rst_n)
        (wvalid && wready) |-> ##[1:$] bvalid;
    endproperty
    assert property(b_after_w);

endmodule
```

### 5.2 放置在状态机模块

**做什么：** 检查状态机转换正确性。

```systemverilog
module state_machine (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire done,
    output logic [2:0] state
);
    // 状态定义
    localparam ST_IDLE  = 3'b000;
    localparam ST_DATA  = 3'b001;
    localparam ST_WAIT  = 3'b010;
    localparam ST_DONE  = 3'b011;
    localparam ST_ERROR = 3'b100;

    // 状态机逻辑
    // ...

    // 状态机断言

    // IDLE 只能转换到 DATA 或 ERROR
    property idle_transition;
        @(posedge clk) disable iff (!rst_n)
        state == ST_IDLE |-> ##1 state inside {ST_IDLE, ST_DATA, ST_ERROR};
    endproperty
    assert property(idle_transition);

    // DATA 只能转换到 WAIT 或 ERROR
    property data_transition;
        @(posedge clk) disable iff (!rst_n)
        state == ST_DATA |-> ##1 state inside {ST_WAIT, ST_ERROR};
    endproperty
    assert property(data_transition);

    // 必须从 IDLE 开始
    property start_from_idle;
        @(posedge clk) disable iff (!rst_n)
        $rose(start) |-> state == ST_IDLE;
    endproperty
    assert property(start_from_idle);

endmodule
```

### 5.3 使用 cover 收集覆盖率

**做什么：** 收集断言覆盖率，确保所有断言都触发过。

```systemverilog
// 收集断言覆盖率
cover property (@(posedge clk) req && ack);
cover property (@(posedge clk) fifo_full);
cover property (@(posedge clk) state == ST_ERROR);

// 收集序列覆盖率
sequence s_req_ack;
    @(posedge clk) req ##[1:10] ack;
endsequence
cover sequence(s_req_ack);
```

---

## 步骤 6：断言调试

### 6.1 使用 $display 和 $error

**做什么：** 断言失败时打印详细信息。

```systemverilog
property req_ack;
    @(posedge clk) req |-> ##[1:10] ack;
endproperty

assert property(req_ack)
    else begin
        $error("REQ-ACK protocol violation at time %0t", $time);
        $display("REQ = %b, ACK = %b", req, ack);
    end
```

### 6.2 使用 $asserton/off 控制断言

**做什么：** 在特定情况下禁用断言。

```systemverilog
// 禁用所有断言
initial begin
    $assertoff();  // 禁用
    // 复位期间
    #100;
    $asserton();   // 启用
end

// 禁用特定断言
assert property(req_ack)
    else $error("...");
// 可以在仿真中禁用特定断言
```

### 6.3 查看断言覆盖率

**做什么：** 检查所有断言是否都被触发过。

```systemverilog
// 在仿真结束时打印覆盖率
final begin
    $display("Assertion Coverage Report:");
    // 工具特定命令
end
```

---

## 步骤 7：断言最佳实践

### 7.1 断言放在哪里

| 断言类型 | 放置位置 |
|----------|----------|
| 协议断言 | 接口模块 |
| 状态机断言 | 状态机模块 |
| 数据完整性断言 | 数据通路模块 |
| 不变量断言 | 相关模块内部 |

### 7.2 断言命名规范

```systemverilog
// ✅ 好：断言有有意义的名字
assert property(req_ack)
    else $error("...");
// 名字自动为 req_ack

// ✅ 好：属性有有意义的名字
property p_req_must_get_ack;
    @(posedge clk) req |-> ##[1:10] ack;
endproperty
assert property(p_req_must_get_ack);

// ❌ 不好：断言没有名字，难调试
assert property(@(posedge clk) req |-> ack);
```

### 7.3 断言复杂度控制

**规则：** 每个断言只检查一个属性，不要过于复杂。

```systemverilog
// ❌ 不好：一个断言检查多个属性
assert property(@(posedge clk)
    req |-> ##[1:10] ack && data_valid && !error);

// ✅ 好：分开检查
assert property(@(posedge clk) req |-> ##[1:10] ack);
assert property(@(posedge clk) ack |-> data_valid);
assert property(@(posedge clk) ack |-> !error);
```

---

## 步骤 8：形式验证应用

### 8.1 断言用于形式验证

**场景：** 使用形式验证工具证明断言在所有输入下都成立。

**适用场景：**
- 模块级属性检查
- 协议检查
- 等价性检查

**不适用场景：**
- 全芯片（容量太大）
- 太复杂的设计（状态空间爆炸）

### 8.2 形式验证断言编写要点

```systemverilog
// 形式验证友好的断言
// 1. 有界属性更好（##[1:10] 比 ##[*] 更好）
// 2. 避免复杂序列组合
// 3. 明确时钟和复位

property bounded_check;
    @(posedge clk) disable iff (!rst_n)
    req |-> ##[1:10] ack;  // 有界，形式验证友好
endproperty
```

---

## 最终检查清单

断言添加完成后检查：

- [ ] 所有接口协议都有对应的断言
- [ ] 状态机所有合法转换都覆盖
- [ ] 断言正确禁用复位期间检查
- [ ] 断言不会增加太多仿真 overhead
- [ ] 所有断言都被触发过（断言覆盖率）
- [ ] 断言有有意义的名字
- [ ] 断言失败时有清晰的错误信息

---

## 反模式（要避免）

❌ **断言过于复杂**：一个断言检查太多属性

```systemverilog
// ❌ 不好
assert property(@(posedge clk) req |-> ack && data_valid && !error);

// ✅ 好：分开
assert property(@(posedge clk) req |-> ack);
assert property(@(posedge clk) ack |-> data_valid);
```

❌ **忘记处理复位**：复位期间断言会失败

```systemverilog
// ❌ 不好：复位期间也检查
assert property(@(posedge clk) state == ST_IDLE);

// ✅ 好：复位期间禁用
assert property(@(posedge clk) disable iff (!rst_n) state == ST_IDLE);
```

❌ **无界属性**：形式验证无法处理

```systemverilog
// ❌ 形式验证困难
assert property(@(posedge clk) req |-> ##[*] ack);

// ✅ 好：有界
assert property(@(posedge clk) req |-> ##[1:100] ack);
```

❌ **没有收集覆盖率**：不知道断言是否触发

```systemverilog
// 添加 cover
cover property (@(posedge clk) req && ack);
```

---

## 工具支持

| 工具 | 公司 | 用途 |
|------|------|------|
| VCS | Synopsys | 仿真 + 断言检查 |
| Xcelium | Cadence | 仿真 + 断言检查 |
| Questa | Siemens | 仿真 + 断言检查 |
| VC Formal | Synopsys | 形式验证 |
| JasperGold | Cadence | 形式验证 |
| Verilator | 开源 | Lint + 基本断言 |

---

## 代理协作

- 断言补充 UVM 验证环境，不是替代
- 使用 `verification-engineer` 代理开发验证平台
- 形式验证使用断言后，工具自动证明属性
