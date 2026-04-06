---
name: assertion-based-verification
description: 断言验证技能
description.zh: 断言验证技能
author: ICER Skill Package
categories: verification
---

# 断言验证技能

当用户需要使用 SVA (SystemVerilog Assertion) 进行断言验证时，启用此技能。

## 使用时机

- 接口协议断言
- 状态机属性断言
- 不变量断言
- 时序属性检查
- 形式验证属性定义

## SVA 基本结构

### 立即断言

```systemverilog
assert property (@(posedge clk) reset |-> !valid) else begin
  $error("Assertion failed: valid should be low during reset");
end
```

### 并发断言

```systemverilog
// 请求必须在一定周期内应答
property req_ack;
  @(posedge clk) req ##[1:10] ack;
endproperty
assert property(req_ack);
```

## 常用模式

### 稳定要求

```systemverilog
// 请求发出后必须保持稳定直到应答
property req_stable;
  @(posedge clk) req |-> req throughout ##[1:$] ack;
endproperty
```

### 因果关系

```systemverilog
// 如果请求发生，最终必须应答
property req_ack_always;
  @(posedge clk) req |-> eventually [1:20] ack;
endproperty
```

### 互斥

```systemverilog
// 两个信号不能同时为高
property mutually_exclusive;
  @(posedge clk) not (a && b);
endproperty
```

### 重叠输出

```systemverilog
// 输入后一个周期输出正确
property output_correct;
  @(posedge clk) $rose(valid) |-> (data == expected);
endproperty
```

## 断言放置原则

✅ **推荐放置位置：**
- 接口模块：接口协议断言
- 状态机：状态转换属性
- 跨时钟域：同步电路属性
- 存储器：访问权限检查

❌ **避免：**
- 不要把断言放到综合网表
- 使用 `ifdef ASSERTIONS` 隔离
- 综合时去掉断言

## 重置处理

所有断言必须正确处理重置：

```systemverilog
property my_prop;
  @(posedge clk) !reset_n |-> property;
endproperty
```

重置期间不检查断言，避免错误失败。

## 覆盖率

- 断言覆盖也需要收集覆盖率
- 检查所有断言都被触发过
- 未触发的断言检查是否需要
- 达到断言覆盖率目标

## 形式验证应用

- 属性检查：证明所有断言在所有情况下成立
- 比仿真更彻底，但是运行时间更长
- 适合模块级验证，不适合全芯片

## 优点

- 贴近设计，在设计位置描述设计属性
- 自动检查，不需要验证平台编写检查代码
- 形式验证可以直接使用
- 发现仿真遗漏的 corner case

## 检查清单

- [ ] 所有接口协议都有断言
- [ ] 所有状态机转换都有断言
- [ ] 断言正确处理重置
- [ ] 断言不会在仿真中产生太多 overhead
- [ ] 所有断言都被触发过（覆盖率）

## 代理协作

- 使用 `verification-engineer` 代理进行验证平台开发
- 断言是对定向测试和随机测试的补充，不是替代
