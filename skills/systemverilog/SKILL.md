---
name: systemverilog
description: SystemVerilog 语言使用技能
description.zh: SystemVerilog 语言使用技能
author: ICER Skill Package
categories: front-end
---

# SystemVerilog 使用技能

当用户需要使用 SystemVerilog 进行设计或验证时，启用此技能。此技能提供 SystemVerilog 最佳实践。

## 使用时机

- 编写新的 SystemVerilog RTL
- 编写 SystemVerilog 验证平台
- 转换 Verilog 到 SystemVerilog
- 调试 SystemVerilog 代码

## 设计中使用 SystemVerilog 特性

### 推荐使用：

✅ **接口（interface）**：
```systemverilog
interface axi_if #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32)
  (input clk, input rst_n);
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] data;
  logic valid;
  logic ready;
endinterface
```
使用接口简化总线连接，减少连线错误。

✅ **总是块分类**：
- `always_ff` - 时序逻辑
- `always_comb` - 组合逻辑
- `always_latch` - 锁存

工具可以自动检查错误。

✅ **typedef**：
```systemverilog
typedef logic [31:0] addr_t;
typedef enum logic [1:0] {IDLE, READ, WRITE, ERROR} state_t;
```
提高代码可读性。

✅ **struct**：
```systemverilog
typedef struct packed {
  logic [3:0]  addr;
  logic [31:0] data;
} pkt_t;
```
组织相关数据在一起。

✅ **参数化**：
```systemverilog
module fifo #(parameter WIDTH = 32, DEPTH = 16)
  (...)
```
提高可复用性。

### 谨慎使用：

⚠️ **动态数组**：设计中不要使用，只在验证中使用
⚠️ **关联数组**：设计中不要使用，只在验证中使用
⚠️ **类**：设计中不要使用，只在验证中使用
⚠️ **虚方法**：设计中不要使用，只在验证中使用

## 验证中使用 SystemVerilog 特性

✅ **类（class）**：封装组件
✅ **继承**：重用基类代码
✅ **多态**：运行时选择不同实现
✅ **约束随机**：生成随机激励
✅ **覆盖组**：功能覆盖率收集

## 编码指南

### 排版

- 4 空格缩进，不使用 Tab
- 每个端口占一行
- 每个信号占一行
- begin/end 单独占一行
- 最大行宽 100 字符

### 文件名

- 文件名和模块名一致
- 使用小写加下划线
- 例：`axi_interconnect.sv`

### 注释

- 文件头注释说明模块功能
- 端口注释说明含义
- 复杂算法注释说明原理
- 注释解释"为什么"，不是"做什么"

## 与 Verilog 比较

| 特性 | SystemVerilog | Verilog |
|------|---------------|---------|
| 接口 | 支持 | 不支持 |
| 类型系统 | 增强 | 弱 |
| 面向对象 | 支持 | 不支持 |
| 约束随机 | 支持 | 不支持 |
| 可综合性 | 好 | 好 |

## 工具支持

所有现代 EDA 工具都支持 SystemVerilog：
- Synopsys VCS/Design Compiler
- Cadence Xcelium/Genus
- Siemens Questa
- 开源：Verilator, Yosys

## 推荐实践

- 新项目使用 SystemVerilog 代替 Verilog
- 设计使用可综合子集
- 验证充分利用 OOP 和约束随机
- 遵循项目编码风格

## 代理协作

- 使用 `rtl-designer` 代理进行 RTL 设计
- 使用 `verification-engineer` 代理进行验证平台开发
