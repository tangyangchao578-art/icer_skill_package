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

## SVA 基础

### 立即断言 vs 并发断言

**立即断言**（组合逻辑，立即检查）：

```systemverilog
// 检查复位期间 valid 必须是低
assert property (@(posedge clk) !i_rst_n |-> !o_valid) else begin
  $error("Assertion failed: o_valid should be low during reset");
end
```

**并发断言**（时序属性，在时钟沿检查）：

```systemverilog
// 请求必须在 1-10 周期内得到应答
property req_ack;
  @(posedge clk) req ##[1:10] ack;
endproperty
assert property(req_ack);
```

## 常用断言模式（复制即用）

### 1. 请求必须保持稳定直到应答

```systemverilog
property req_stable_until_ack;
  @(posedge clk)
  $rose(req) |-> req throughout (##[1:$] ack);
endproperty
assert property(req_stable_until_ack);
```

### 2. 请求发生最终必须得到应答

```systemverilog
property req_must_respond;
  @(posedge clk) req |-> eventually [1:20] ack;
endproperty
assert property(req_must_respond);
```

### 3. 两个信号不能同时为高（互斥）

```systemverilog
property signals_exclusive;
  @(posedge clk) not (a && b);
endproperty
assert property(signals_exclusive);
```

### 4. 输入变化后一个周期输出正确

```systemverilog
property output_correct_after_input;
  @(posedge clk) $rose(input_valid) |-> ##1 output_data == expected_data;
endproperty
assert property(output_correct_after_input);
```

### 5. 一旦 ready 为低，发送方必须停止发送

```systemverilog
property backpressure_ok;
  @(posedge clk) !ready |-> !valid;
endproperty
assert property(backpressure_ok);
```

### 6. 跨时钟域同步检查（慢到快，两级同步）

```systemverilog
property cdc_two_flop_ok;
  @(posedge clk_fast) $fell(async_signal) |->
    (r1 == 1'b0) throughout (##1 r2 == 1'b1);
endproperty
```

### 7. 总线忙一直忙到传输完成

```systemverilog
property bus_transfer_complete;
  @(posedge clk) $rose(bus_valid) |->
    bus_valid until & bus_complete;
endproperty
```

### 8. 复位后所有状态正确初始化

```systemverilog
property reset_correct;
  @(posedge clk) !i_rst_n ##1 i_rst_n |-> (state == ST_IDLE);
endproperty
assert property(reset_correct);
```

## 重置处理

所有断言必须正确处理重置，避免重置期间错误失败。

**✅ 正确：**

```systemverilog
property my_prop;
  @(posedge clk) !reset_n |-> (
    // 只有在重置释放后才检查属性
    !reset_n ##1 reset_n |-> property
  );
endproperty
```

或者更简洁：

```systemverilog
property my_prop;
  @(posedge clk) disable iff (!reset_n) property;
endproperty
```

`disable iff` 在重置期间禁用断言，不会报错。

## 断言放置原则

### ✅ 推荐放置位置

- **接口模块**：接口协议断言 → 检查协议遵守
- **状态机**：状态转换属性 → 检查不会进入非法状态
- **跨时钟域**：同步电路属性 → 检查同步正确
- **存储器**：访问权限检查 → 检查不会访问错误地址
- **不变量**：设计不变量 → 一直保持真

### ❌ 避免

- 不要把断言综合到网表中 → 占用面积
- 使用 `ifdef ASSERTIONS` 隔离断言
- 只在仿真和形式验证中包含断言

```systemverilog
`ifdef ASSERTIONS
  // 这里放断言
`endif
```

## 断言覆盖率

- 必须收集断言覆盖率
- 检查所有断言都被触发过
- 从未触发的分析原因：
  - 功能从来没使用 → 可以删除
  - 测试场景不全 → 添加测试
  - 断言永远不对 → 设计错了或者断言错了
- 达到 100% 断言覆盖率（所有断言都触发过）

## 形式验证应用

### 适用场景

- **模块级属性检查**：证明属性在所有输入下都成立
- **等价性检查**：RTL 对 RTL，修改前后功能等价
- **协议检查**：证明接口一直遵守协议

### 不适用场景

- 全芯片（容量太大，运行时间太长）
- 太复杂的设计（状态空间爆炸）

### 优点

- 比仿真更彻底 → 探索所有可能输入组合
- 找到仿真很难找到的 corner case
- 一旦证明就不用反复测试

### 缺点

- 运行时间长，容量限制
- 需要写正确的属性
- 复杂设计容易状态空间爆炸

## 断言覆盖率和功能覆盖率关系

- **断言覆盖率**：所有断言是否都被触发过
- **功能覆盖率**：所有功能点是否被覆盖过
- 两个互相补充，不是互相替代

## 常见错误

### ❌ 忘记处理重置

```systemverilog
// 错误：重置期间也检查，会失败
property bad_prop;
  @(posedge clk) req |-> ##[1:10] ack;
endproperty
```

**✅ 正确：**

```systemverilog
property good_prop;
  @(posedge clk) disable iff (!i_rst_n) req |-> ##[1:10] ack;
endproperty
```

### ❌ 错误的时钟事件

```systemverilog
// 错误：在 negedge 检查，但是属性用 posedge 时钟
property wrong_clk;
  @(negedge clk) ...
endproperty
```

确保时钟和设计时钟沿一致。

### ❌ 悬空断言没有 label

给每个断言起有意义的名字，方便调试。

## 检查清单

添加断言后检查：

- [ ] 所有接口协议都有对应的断言
- [ ] 状态机所有合法转换都覆盖，非法状态检查
- [ ] 断言正确禁用重置期间检查
- [ ] 断言不会增加太多仿真 overhead
- [ ] 所有断言都被触发过（断言覆盖率）
- [ ] 没有错误触发失败（false negative）
- [ ] 没有遗漏应该检查的属性

## 优点对比仿真

- 断言贴近设计，设计者最清楚设计属性
- 属性写在设计旁边，不会过时
- 自动检查，不需要验证工程师写检查代码
- 形式验证可以直接使用相同断言
- 容易发现接口违反，协议错了立刻报错

## 缺点

- 断言只能说"哪里错了"，不能说"哪里对了"
- 需要设计者写出正确的属性
- 不能发现功能遗漏，如果属性没有写就不会检查
- 复杂断言仿真 overhead 较大

## 推荐使用方式

断言是对定向测试和随机测试的**补充**，不是替代：

- 设计中添加断言检查协议和不变量
- 测试平台生成激励
- 断言自动检查，发现错误立即报错
- 覆盖率收集确保所有断言都触发过

## 工具支持

- 所有主流仿真器都支持 SVA：VCS, Xcelium, Questa
- 形式验证工具：Synopsys VC Formal, Cadence Conformal
- 开源：Verilator 支持基本断言

## 反模式（要避免）

❌ **检查应该由设计保证的显而易见属性**：`addr < ADDR_MAX` → 设计已经保证，不需要断言
❌ **太多断言影响仿真速度**：只检查关键属性，不重要的不用
❌ **属性写得太复杂**：复杂属性容易写错，拆成多个简单属性
❌ **忘记收集覆盖率**：不知道断言有没有被触发过

## 代理协作

- 使用 `verification-engineer` 代理进行验证平台开发
- 断言补充 UVM 验证环境，不是替代
- 形式验证使用断言后，工具自动证明属性
