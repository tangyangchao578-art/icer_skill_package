---
name: rtl-coding
description: RTL 编码技能 - 可综合、可验证、可维护的 RTL 编码最佳实践
description.zh: RTL 编码技能 - 可综合、可验证、可维护的 RTL 编码最佳实践
origin: ICER
categories: front-end
---

# RTL 编码技能

当用户需要编写 RTL 代码时，启用此技能。此技能提供可综合、可验证、可维护的 RTL 编码指导，遵循工业界最佳实践。

## When to Activate

- 编写新的 RTL 模块
- 修改现有的 RTL 代码
- RTL 代码重构优化
- RTL 代码审查
- 调试 RTL 功能问题

## 编码模板

### 完整模块模板（SystemVerilog）

```systemverilog
module fifo #(
  parameter DATA_WIDTH = 32,
  parameter DEPTH       = 16
)(
  // Clock and reset
  input  wire                i_clk,
  input  wire                i_rst_n,

  // Write port
  input  wire                i_wr_en,
  input  wire [DATA_WIDTH-1:0] i_wr_data,

  // Read port
  input  wire                i_rd_en,
  output logic [DATA_WIDTH-1:0] o_rd_data,
  output logic               o_empty,
  output logic               o_full
);

// Local parameters
localparam ADDR_WIDTH = $clog2(DEPTH);

// Internal signals
logic [ADDR_WIDTH-1:0] r_wr_addr;
logic [ADDR_WIDTH-1:0] r_rd_addr;
logic [DATA_WIDTH-1:0] r_mem[DEPTH];

// Write operation
always_ff @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    r_wr_addr <= '0;
  end else if (i_wr_en && !o_full) begin
    r_wr_addr <= r_wr_addr + 1'b1;
  end
end

// ... rest of code

endmodule
```

### 同步时序逻辑模板

**✅ 推荐：**

```systemverilog
always_ff @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    r_state <= STATE_IDLE;
  end else begin
    r_state <= w_next_state;
  end
end
```

### 组合逻辑模板

**✅ 推荐：**

```systemverilog
always_comb begin
  case (r_state)
    STATE_IDLE: begin
      if (i_valid) begin
        w_next_state = STATE_DATA;
        w_output = 1'b0;
      end else begin
        w_next_state = STATE_IDLE;
        w_output = 1'b0;
      end
    end
    // ... other states
    default: begin
      w_next_state = STATE_IDLE;
      w_output = 1'b0;
    end
  endcase
end
```

## 可综合性准则

### ✅ 推荐做

- 使用 `always_ff` 描述时序逻辑
- 使用 `always_comb` 描述组合逻辑
- 使用 `always_latch` 明确描述锁存（如果真需要）
- 使用参数化设计提高复用性
- 使用 generate 生成重复模块
- 使用 SystemVerilog 接口简化复杂连接

### ❌ 避免做

- `initial` 块给寄存器赋初值（综合工具忽略，没有效果）
- `#delay` 行为级延迟（不可综合，仿真和综合行为不一致）
- fork/join 并行块（不可综合，只用于仿真）
- 混合使用阻塞和非阻塞赋值在同一个 always 块
- 动态变量大小（不可综合）
- 递归调用（不可综合）

**❌ 错误示例：**

```systemverilog
// 错误：initial 块给寄存器赋初值，综合忽略
initial begin
  r_counter = '0;
end

// 错误：延迟不可综合
#10 req = 1'b1;

// 错误：混合阻塞非阻塞赋值
always @(posedge clk) begin
  a = b;  // 阻塞
  c <= d; // 非阻塞
end
```

## 命名约定

### 前缀约定

| 信号类型 | 前缀 | 示例 |
|----------|------|------|
| 输入端口 | `i_` | `i_clk` |
| 输出端口 | `o_` | `o_valid` |
| 双向端口 | `io_` | `io_data` |
| 寄存器输出 | `r_` | `r_state` |
| 组合逻辑连线 | `w_` | `w_next_state` |

### 大小写约定

- 模块/信号名称：小写加下划线 `snake_case` → `axi_interconnect`
- 参数/常量/宏：大写加下划线 `UPPER_CASE` → `DATA_WIDTH`
- 状态机状态：`ST_` 前缀大写 → `ST_IDLE`, `ST_DATA`

**✅ 好示例：**

```systemverilog
module uart_rx #(
  parameter CLK_FREQ = 50000000,
  parameter BAUD_RATE = 115200
)(
  input  wire i_clk,
  input  wire i_rst_n,
  input  wire i_rx,
  output logic o_data_valid,
  output logic [7:0] o_data
);
```

**❌ 坏示例：**

```systemverilog
// 混合风格，不好读
module UartRX (input clk, rst_n, ...);
parameter DataWidth = 32;
```

## 编码风格

### 缩进

- 4 个空格缩进，不使用 Tab
- 每个缩进层次增加 4 空格

### 行宽

- 最大 100 字符
- 超过换行对齐

### 端口排序

推荐顺序：
1. 时钟和复位
2. 配置接口
3. 数据输入
4. 数据输出

```systemverilog
// ✅ 好顺序
module my_module (
  input  wire        i_clk,      // 1. clock
  input  wire        i_rst_n,    // 2. reset
  input  wire [W-1:0] i_config,  // 3. config
  input  wire [W-1:0] i_data,    // 4. input data
  input  wire        i_valid,    //
  output logic [W-1:0] o_data,   // 5. output data
  output logic       o_valid    //
);
```

## 可综合性陷阱

### 锁存推断

**❌ 错误：不完全条件产生锁存**

```systemverilog
always_comb begin
  case (sel)
    2'b00: result = a;
    2'b01: result = b;
    2'b10: result = c;
    // 没有 default，sel=2'b11 时 result 保持原来值 → 锁存
  endcase
end
```

**✅ 正确：always default**

```systemverilog
always_comb begin
  result = '0; // 默认值
  case (sel)
    2'b00: result = a;
    2'b01: result = b;
    2'b10: result = c;
  endcase
end
// 或者
always_comb begin
  case (sel)
    2'b00: result = a;
    2'b01: result = b;
    2'b10: result = c;
    default: result = '0;
  endcase
end
```

### 组合逻辑环路

**❌ 错误：组合逻辑环路**

```systemverilog
// a 依赖 b，b 依赖 a → 组合环路，振荡
always_comb begin
  a = b + 1'b1;
end
always_comb begin
  b = a + 1'b1;
end
```

工具很难满足时序，结果不可预测，必须避免。

## 时序设计准则

### 流水线准则

- **输入打拍**：输入信号打一拍再使用，减少外部路径影响
- **输出打拍**：输出从寄存器出来，改善输出时序
- **分割长路径**：长组合逻辑插入寄存器流水线

**✅ 好示例：输出寄存器**

```systemverilog
// 输出从寄存器出来，满足输出延时要求
always_ff @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_valid <= 1'b0;
    o_data  <= '0;
  end else begin
    o_valid <= w_valid;
    o_data  <= w_data;
  end
end
```

### 大扇出处理

- 大扇出信号（> 32 负载）要寄存器分割
- 复制寄存器驱动不同群组
- 减少扇出，改善时序

```systemverilog
// ✅ 好：复制寄存器分割扇出
always_ff @(posedge i_clk) begin
  r_enable_group1 <= enable;
  r_enable_group2 <= enable;
end
// 分别驱动 r_enable_group1 和 r_enable_group2
```

### 跨时钟域

- 单信号慢到快：两级同步
- 单信号快到慢：脉冲展宽 + 两级同步，或者握手
- 多比特：异步 FIFO，或者格雷码

**❌ 错误：直接传送跨时钟域不同步**

```systemverilog
// clk_a 频率 100MHz，clk_b 频率 50MHz，不同时钟域
// 直接传送没有同步 → 亚稳定，可能出错
assign data_b = data_a;
```

**✅ 正确：两级同步**

```systemverilog
// 单控制信号，慢时钟到快时钟
(* async_reg = "true" *) logic r1;
(* async_reg = "true" *) logic r2;
always_ff @(posedge clk_b or negedge rst_b) begin
  if (!rst_b) begin
    r1 <= 1'b0;
    r2 <= 1'b0;
  end else begin
    r1 <= signal_a;
    r2 <= r1; // 输出 r2 到 clk_b 域使用
  end
end
```

### 禁止组合逻辑产生时钟

**❌ 错误：用组合逻辑分频得到时钟**

```systemverilog
// 组合逻辑产生毛刺，时钟树无法平衡，时序无法分析
always_comb begin
  gated_clk = clk & enable;
end
```

**✅ 正确：使用门控时钟单元，或者寄存器输出**

```systemverilog
// 使用工具自动插入门控时钟，或者专用单元
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    gated_clk_ff <= 1'b0;
  end else begin
    gated_clk_ff <= enable;
  end
end
```

## 复位设计准则

### 基本规则

- ✅ 整个项目保持一致：要么全异步复位，要么全同步复位
- ✅ 所有时序逻辑寄存器必须有复位（除了真正不需要的）
- ✅ 数据通路寄存器必须复位
- ✅ 不改变状态的存储器可以不复位
- ✅ 异步复位必须同步释放

### 异步复位同步释放

**✅ 正确：异步复位，同步释放**

```systemverilog
(* async_reg = "true" *) logic r_rst1;
(* async_reg = "true" *) logic r_rst2;
always_ff @(posedge clk or negedge async_rst_n) begin
  if (!async_rst_n) begin
    r_rst1 <= 1'b0;
    r_rst2 <= 1'b0;
  end else begin
    r_rst1 <= 1'b1;
    r_rst2 <= r_rst1; // 同步复位释放
  end
end
// 使用 r_rst2 作为同步后的复位
wire sync_rst_n = r_rst2;
```

## 面积优化

### 优化技巧

- 复用运算单元（分时复用）
- 合理状态编码：二进制编码面积最小，one-hot 速度最快
- 移除不必要的寄存器
- 使用工艺库提供的硬宏（乘法器、存储器）不要自己 inferred
- 删除死代码，没有使用的逻辑一定要删除

### 状态编码选择

| 编码方式 | 面积 | 速度 | 适用场景 |
|----------|------|------|----------|
| 二进制 | 最小 | 较慢 | 面积受限，低速 |
| 格雷码 | 小 | 中等 | 计数器，低功耗 |
| One-hot | 大 | 最快 | 高速，少状态 |

## 功耗优化

- 使用门控时钟关闭不使用的模块
- 操作数隔离：关闭不使用通路的翻转
- 格雷码编码计数器：只有一位翻转，降低翻转活动性
- 关断不使用模块时钟：动态功耗节省明显
- 避免不必要的翻转：流水线 stall 时停止翻转

## 代码审查检查清单

提交代码前检查：

- [ ] 命名符合约定（前缀，大小写）
- [ ] 所有端口信号都已声明
- [ ] case 语句有 default 处理
- [ ] 没有不完全条件产生锁存
- [ ] 复位正确处理（整个项目一致）
- [ ] 跨时钟域处理正确（有同步）
- [ ] 没有组合逻辑环路
- [ ] 所有输出都有定义
- [ ] 符合项目编码风格
- [ ] 参数化设计，可配置

## 工具检查

写完 RTL 运行以下检查：

1. **Lint 检查**：SpyGlass 或 Verilator，检查代码质量问题
2. **CDC 检查**：所有跨时钟域都检查，确认同步正确
3. **初步综合**：检查是否可综合，看面积大概多少
4. **仿真**：基本功能仿真通过

## 反模式（要避免）

❌ **魔法数字**：代码里直接写 8'h42，不说明含义 → 使用参数或`localparam`
❌ **重复代码**：相同代码复制粘贴多处 → 提取为公共模块
❌ **太长模块**：一个模块几千行 → 拆分更小模块
❌ **没有注释**：复杂算法完全没注释 → 注释说明为什么，不说明做什么
❌ **过度共享**：一个信号驱动太多地方 → 拆分寄存器减少扇出
❌ **忽略lint错误**：lint有警告不管 → 修复所有lint警告

## 代理协作

- RTL 编写完成后，使用 `code-reviewer` 代理进行代码审查
- 使用 `verification-engineer` 代理开发验证平台
- 如果是时序问题，让 `physical-design-engineer` 帮助分析
