---
name: systemverilog
description: SystemVerilog 语言使用技能 - 设计和验证最佳实践
description.zh: SystemVerilog 语言使用技能 - 设计和验证最佳实践
origin: ICER
categories: front-end
---

# SystemVerilog 使用技能

当用户需要使用 SystemVerilog 进行设计或验证时，启用此技能。此技能提供 SystemVerilog 最佳实践，区分设计可综合子集和验证特性。

## When to Activate

- 编写新的 SystemVerilog RTL 设计
- 编写 SystemVerilog 验证平台
- 将老的 Verilog 代码转换为 SystemVerilog
- 调试 SystemVerilog 代码问题
- 代码审查 SystemVerilog 代码

## 设计中使用 SystemVerilog 特性（可综合子集）

### ✅ 推荐：接口（interface）

**示例：**

```systemverilog
interface axi_if #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
)(
  input clk,
  input rst_n
);
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] data;
  logic valid;
  logic ready;

  // 添加 modport 明确方向
  modport master (
    output addr, data, valid,
    input  ready
  );

  modport slave (
    input  addr, data, valid,
    output ready
  );

endinterface
```

**优点：**
- 自动整理一堆连线，减少代码量
- 减少连线错误（少连、错连）
- 接口协议改变，只需要改一处
- 在 UVM 验证中更容易传递接口

### ✅ 推荐：always 块分类

- `always_ff` - 时序逻辑 → 工具自动检查
- `always_comb` - 组合逻辑 → 工具自动检查是否真的组合
- `always_latch` - 锁存 → 明确告诉工具你真的想要锁存

**✅ 正确示例：**

```systemverilog
// 时序逻辑
always_ff @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    r_data <= '0;
  end else begin
    r_data <= w_next;
  end
end

// 组合逻辑
always_comb begin
  case (sel)
    2'b00: w_mux = a;
    2'b01: w_mux = b;
    2'b10: w_mux = c;
    default: w_mux = '0;
  endcase
end
```

**对比老 Verilog：**

```verilog
// 老 Verilog，工具不知道你要组合还是时序
always @(posedge clk or negedge rst_n) ...
always @(*) ...  // 工具也不能检查错误
```

SystemVerilog 让工具帮你检查错误。

### ✅ 推荐：typedef 自定义类型

**示例：**

```systemverilog
// 地址类型
typedef logic [31:0] addr_t;

// 状态枚举
typedef enum logic [1:0] {
  ST_IDLE,
  ST_READ,
  ST_WRITE,
  ST_ERROR
} state_t;

// 数据包结构
typedef struct packed {
  logic [3:0]  addr;
  logic [31:0] data;
  logic        valid;
} pkt_t;
```

**优点：**
- 提高代码可读性
- 传递参数更容易，减少代码重复
- 类型检查更严格，工具发现错误更早

### ✅ 推荐：struct 组织相关数据

把相关数据放在一起，比分开定义多个信号清晰。

```systemverilog
// ✅ 好：相关数据组织在一起
typedef struct packed {
  logic [ 3:0] opcode;
  logic [11:0] address;
  logic [15:0] data;
} instruction_t;

instruction_t r_fetch;
instruction_t w_exec;
```

对比分开定义：

```systemverilog
// ❌ 坏：相关数据分开定义，不清晰
logic [ 3:0] opcode;
logic [11:0] address;
logic [15:0] data;
```

### ✅ 推荐：参数化模块

提高复用性，同一个模块可以用在不同地方不同配置。

```systemverilog
module fifo #(
  parameter DATA_WIDTH = 32,
  parameter DEPTH       = 16,
  parameter ALMOST_FULL = DEPTH - 4,
  parameter ALMOST_EMPTY = 4
)(
  input  wire                i_clk,
  ...
);
```

### ✅ 推荐：generate 生成重复模块

```systemverilog
generate
  genvar i;
  for (i = 0; i < NUM_CHANS; i = i + 1) begin: gen_chans
    channel u_channel (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_data(i_data[i*WIDTH +: WIDTH]),
      ...
    );
  end
endgenerate
```

比复制粘贴 N 份代码好：
- 代码行数少
- 修改数量只要改参数
- 不容易出错

### ⚠️ 谨慎使用：这些只在验证中使用，设计中不要用

| 特性 | 为什么设计中不要用 |
|------|---------------------|
| 动态数组 | 综合不支持，面积不确定 |
| 关联数组 | 综合不支持 |
| 类（class） | 综合不支持，只用于验证 |
| 虚方法 | 综合不支持，只用于验证 |
| 队列 | 综合不支持，只用于验证 |
| 字符串 | 综合不支持，只用于验证 |

**总结：设计只用可综合子集，验证可以充分使用所有特性。**

## 验证中使用 SystemVerilog 特性

验证可以充分使用所有 SystemVerilog 特性：

### ✅ 类（class）

封装验证组件，数据和方法在一起。

```systemverilog
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  virtual interface vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    // driver code here
  endtask
endclass
```

### ✅ 继承

复用基类代码，减少重复。

```systemverilog
// 基类
class base_test extends uvm_test;
  // common code
endclass

// 派生类
class read_test extends base_test;
  // add test-specific code
  // reuse base code
endclass
```

### ✅ 多态

运行时选择不同实现，同一个接口不同行为。

```systemverilog
virtual class sequence;
  pure virtual task body();
endclass

class read_sequence extends sequence;
  virtual task body();
    // read sequence
  endtask
endclass

class write_sequence extends sequence;
  virtual task body();
    // write sequence
  endtask
endclass
```

### ✅ 约束随机激励

生成合法的随机激励，更容易找到 corner case。

```systemverilog
class transaction extends uvm_sequence_item;
  rand logic [31:0] addr;
  rand logic [31:0] data;
  rand bit        read;

  // 约束地址 4 字节对齐
  constraint addr_align { addr[1:0] == 2'b00; }

  // 约束地址范围
  constraint addr_range { addr inside {[0:ADDR_MAX]}; }
endclass
```

### ✅ 功能覆盖率

收集功能覆盖率，验证验证进度。

```systemverilog
covergroup ctrl_cg @(posedge clk);
  option.per_instance = 1;
  enable: coverpoint enable {
    bins on  = {1};
    bins off = {0};
  }
  mode: coverpoint mode {
    bins idle;
    bins read;
    bins write;
    bins error;
  }
  enable_x_mode: cross enable, mode;
endgroup
```

## 编码指南

### 排版格式

- 4 个空格缩进，不使用 Tab
- 每个端口声明占一行
- 每个信号声明占一行
- `begin/end` 单独占一行
- 最大行宽 100 字符，超过换行
- 空行分隔不同逻辑块

### 文件名

- 文件名和模块名一致
- 使用小写加下划线 `snake_case`
- 示例：`axi_interconnect.sv`，`fifo.sv`

### 注释

- 文件开头注释：说明模块功能，作者，日期
- 每个端口注释：说明含义，约束，时序要求
- 复杂算法：说明算法原理，设计决策
- 复杂状态机：说明转换条件
- **注释解释**"为什么"**，不解释**做什么"**（代码已经说明了做什么）

**✅ 好注释：**

```systemverilog
// 格雷码计数器，降低功耗，因为只有一位翻转
// Gray code counter, lower power because only one bit toggles
always_ff @(posedge clk) begin
  ...
end
```

**❌ 坏注释（废话）：**

```systemverilog
// 这是一个计数器，计数从 0 到 255
// This is a counter, count from 0 to 255
always_ff @(posedge clk) begin
  ...
end
```

## 可综合性检查清单

设计中使用 SystemVerilog 检查：

- [ ] 没有使用动态分配（动态数组、队列）
- [ ] 没有使用类和面向对象
- [ ] 所有参数都是常量，在编译时确定
- [ ] generate 块都有名字
- [ ] 所有循环都是静态绑定（循环次数在编译时确定）
- [ ] 所有变量都有确定位宽

## 与 Verilog 比较

| 特性 | SystemVerilog | Verilog-2001 |
|------|---------------|---------------|
| 接口 | ✅ 支持 | ❌ 不支持 |
| 类型系统 | ✅ 增强（typedef, struct, enum） | ❌ 弱类型 |
| 面向对象 | ✅ 支持（验证） | ❌ 不支持 |
| 约束随机 | ✅ 内置 | ❌ 不支持 |
| 功能覆盖率 | ✅ 内置 | ❌ 不支持 |
| always 分类 | ✅ 显式，工具可检查 | ❌ 隐式 |
| 可综合性 | ✅ 完全支持 | ✅ 完全支持 |

## 工具支持

所有现代 EDA 工具都完全支持 SystemVerilog：

- **Synopsys:** VCS, Design Compiler → 完全支持
- **Cadence:** Xcelium, Genus → 完全支持
- **Siemens:** Questa → 完全支持
- **开源:** Verilator, Yosys → 支持可综合子集

## 推荐实践

- ✅ 新项目使用 SystemVerilog 代替 Verilog
- ✅ 设计严格使用可综合子集
- ✅ 验证充分利用 OOP、约束随机、覆盖率
- ✅ 遵循项目编码风格一致
- ✅ 接口比一堆散连线好，尽量使用接口
- ✅ typedef 比裸 `logic` 好，提高可读性

## 反模式（要避免）

❌ **过度使用 struct**：设计中不必要把所有东西都放 struct，合理使用就好
❌ **在设计中使用验证特性**：动态数组、类，这些不可综合
❌ **没有给 generate 块命名**：生成的模块层次不好访问，调试困难
❌ **文件和模块名不一致**：找到代码困难
❌ **混合 Verilog 和 SystemVerilog 不必要**：统一都用 SystemVerilog 更好

## 代理协作

- 使用 `rtl-designer` 代理进行 RTL 设计
- 使用 `verification-engineer` 代理进行验证平台开发
- 使用 `code-reviewer` 代理进行代码审查
