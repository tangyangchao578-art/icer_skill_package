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

---

## 步骤 1：模块骨架创建

开始编写 RTL 代码之前，先创建模块骨架。

### 1.1 创建文件

**做什么：** 创建 RTL 文件，文件名与模块名一致。

**怎么做：**
1. 文件名 = 模块名（小写加下划线）
2. 文件扩展名：SystemVerilog 用 `.sv`，Verilog 用 `.v`
3. 文件放在正确的目录层次

**✅ 好的命名：**
- 模块名 `axi_interconnect` → 文件名 `axi_interconnect.sv`
- 模块名 `ddr_controller` → 文件名 `ddr_controller.sv`

**❌ 不好的命名：**
- 模块名 `AXIInterconnect` → 文件名 `axi_interconnect.sv`（不一致）
- 模块名 `axi_interconnect` → 文件名 `AXI.sv`（不匹配）

### 1.2 编写文件头注释

**做什么：** 在文件开头添加标准注释头。

**模板：**

```systemverilog
//-----------------------------------------------------------------------------
// Module: module_name
// Description: 模块功能描述（一句话）
// Author: 作者名
// Date: 创建日期
// Version: 版本号
// Modification History:
//   Date       | Author  | Description
//   -----------|---------|-------------------------------------------
//   2024-01-15 | XXX     | Initial version
//   2024-01-20 | XXX     | Add feature X
//-----------------------------------------------------------------------------
```

### 1.3 声明模块和参数

**做什么：** 声明模块名、参数、端口。

**模板：**

```systemverilog
module module_name #(
    // 参数定义（参数化设计）
    parameter DATA_WIDTH = 32,
    parameter DEPTH       = 16,
    parameter ADDR_WIDTH  = $clog2(DEPTH)  // 派生参数
)(
    // 端口声明
    // 端口排序：时钟复位 → 配置 → 输入数据 → 输出数据
    input  wire                        i_clk,      // 时钟
    input  wire                        i_rst_n,    // 异步复位，低有效

    // 配置接口
    input  wire [DATA_WIDTH-1:0]       i_config,

    // 数据输入
    input  wire [DATA_WIDTH-1:0]       i_data,
    input  wire                        i_valid,
    output logic                       o_ready,

    // 数据输出
    output logic [DATA_WIDTH-1:0]      o_data,
    output logic                       o_valid,
    input  wire                        i_ready
);
```

**参数设计原则：**
- 所有可能变化的值都用参数
- 提供合理的默认值
- 派生参数自动计算（如 ADDR_WIDTH = $clog2(DEPTH)）

### 1.4 命名约定检查

**做什么：** 确保命名符合项目规范。

**标准命名约定：**

| 信号类型 | 前缀 | 示例 |
|----------|------|------|
| 输入端口 | `i_` | `i_clk`, `i_data` |
| 输出端口 | `o_` | `o_valid`, `o_data` |
| 双向端口 | `io_` | `io_data` |
| 寄存器输出 | `r_` | `r_state`, `r_counter` |
| 组合逻辑连线 | `w_` | `w_next_state`, `w_mux` |
| 参数/常量 | 大写 | `DATA_WIDTH`, `DEPTH` |
| 状态机状态 | `ST_` 前缀 | `ST_IDLE`, `ST_DATA` |

**检查清单：**
- [ ] 文件名与模块名一致
- [ ] 文件头注释完整
- [ ] 参数定义合理，有默认值
- [ ] 端口排序正确（时钟复位 → 配置 → 输入 → 输出）
- [ ] 命名符合约定

---

## 步骤 2：内部信号声明

模块骨架完成后，声明内部信号。

### 2.1 声明局部参数

**做什么：** 定义模块内部使用的常量。

```systemverilog
// 局部参数（外部不可覆盖）
localparam ST_IDLE = 2'b00;
localparam ST_DATA = 2'b01;
localparam ST_WAIT = 2'b10;
localparam ST_DONE = 2'b11;

// 派生参数
localparam ADDR_WIDTH = $clog2(DEPTH);
localparam DATA_MASK  = {DATA_WIDTH{1'b1}};
```

### 2.2 声明寄存器

**做什么：** 声明需要保存状态的信号。

```systemverilog
// 状态寄存器
logic [1:0]  r_state;
logic [ADDR_WIDTH-1:0] r_wr_addr;
logic [ADDR_WIDTH-1:0] r_rd_addr;

// 数据寄存器
logic [DATA_WIDTH-1:0] r_data;
logic r_valid;

// 计数器
logic [15:0] r_counter;
```

**寄存器命名规则：**
- 用 `r_` 前缀
- 用 `always_ff` 赋值
- 位宽明确

### 2.3 声明组合逻辑连线

**做什么：** 声明组合逻辑中间信号。

```systemverilog
// 组合逻辑连线
logic [1:0]  w_next_state;
logic [DATA_WIDTH-1:0] w_mux_data;
logic w_wr_enable;
logic w_rd_enable;
logic w_full;
logic w_empty;
```

**组合逻辑命名规则：**
- 用 `w_` 前缀
- 用 `always_comb` 赋值
- 必须在所有分支赋值

### 2.4 声明存储器

**做什么：** 如果模块需要存储器，声明存储器数组。

```systemverilog
// 存储器声明
logic [DATA_WIDTH-1:0] r_mem[DEPTH];

// 存储器读写
always_ff @(posedge i_clk) begin
    if (w_wr_enable) begin
        r_mem[r_wr_addr] <= i_data;
    end
end

always_ff @(posedge i_clk) begin
    if (w_rd_enable) begin
        o_data <= r_mem[r_rd_addr];
    end
end
```

**检查清单：**
- [ ] 所有局部参数都已声明
- [ ] 所有寄存器都已声明，位宽明确
- [ ] 所有组合逻辑连线都已声明
- [ ] 存储器声明正确（如果有）
- [ ] 命名符合约定（r_ 寄存器，w_ 组合逻辑）

---

## 步骤 3：时序逻辑编写

### 3.1 编写复位逻辑

**做什么：** 编写复位时序逻辑。

**异步复位模板：**

```systemverilog
// 异步复位，同步释放（推荐）
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_state <= ST_IDLE;
        r_data  <= '0;
        r_valid <= 1'b0;
    end else begin
        r_state <= w_next_state;
        r_data  <= w_next_data;
        r_valid <= w_next_valid;
    end
end
```

**同步复位模板：**

```systemverilog
// 同步复位
always_ff @(posedge i_clk) begin
    if (!i_rst_n) begin
        r_state <= ST_IDLE;
        r_data  <= '0;
        r_valid <= 1'b0;
    end else begin
        r_state <= w_next_state;
        r_data  <= w_next_data;
        r_valid <= w_next_valid;
    end
end
```

**项目级规则：**
> ⚠️ 整个项目保持一致！要么全异步复位，要么全同步复位。

### 3.2 编写状态寄存器

**做什么：** 编写状态机状态寄存器。

```systemverilog
// 状态寄存器
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_state <= ST_IDLE;
    end else begin
        r_state <= w_next_state;
    end
end
```

### 3.3 编写数据寄存器

**做什么：** 编写数据通路寄存器。

```systemverilog
// 数据寄存器
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_data  <= '0;
        r_valid <= 1'b0;
    end else if (w_wr_enable) begin
        r_data  <= i_data;
        r_valid <= 1'b1;
    end else if (w_rd_enable) begin
        r_valid <= 1'b0;
    end
end
```

### 3.4 编写计数器

**做什么：** 编写计数器逻辑。

```systemverilog
// 计数器
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_counter <= '0;
    end else if (w_counter_clear) begin
        r_counter <= '0;
    end else if (w_counter_enable) begin
        r_counter <= r_counter + 1'b1;
    end
end
```

### 3.5 编写输出寄存器

**做什么：** 输出信号从寄存器出来，改善时序。

```systemverilog
// 输出寄存器（改善输出时序）
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

**检查清单：**
- [ ] 复位逻辑正确
- [ ] 所有寄存器都有复位（或明确不需要复位）
- [ ] 使用非阻塞赋值（<=）
- [ ] 输出信号从寄存器出来
- [ ] 整个项目复位风格一致

---

## 步骤 4：组合逻辑编写

### 4.1 编写状态转换逻辑

**做什么：** 编写状态机下一状态逻辑。

```systemverilog
// 状态转换逻辑
always_comb begin
    // 默认值：保持当前状态
    w_next_state = r_state;

    case (r_state)
        ST_IDLE: begin
            if (i_valid && i_ready) begin
                w_next_state = ST_DATA;
            end
        end

        ST_DATA: begin
            if (w_data_done) begin
                w_next_state = ST_WAIT;
            end
        end

        ST_WAIT: begin
            if (w_wait_done) begin
                w_next_state = ST_DONE;
            end
        end

        ST_DONE: begin
            w_next_state = ST_IDLE;
        end

        default: begin
            w_next_state = ST_IDLE;
        end
    endcase
end
```

**状态机编码原则：**
- **必须有 default 分支**
- **先给默认值**，避免锁存
- 使用 `case` 语句清晰表达状态转换

### 4.2 编写数据通路逻辑

**做什么：** 编写数据处理逻辑。

```systemverilog
// 数据通路逻辑
always_comb begin
    // 默认值
    w_mux_data = '0;
    w_wr_enable = 1'b0;
    w_rd_enable = 1'b0;

    case (r_state)
        ST_IDLE: begin
            if (i_valid && i_ready) begin
                w_wr_enable = 1'b1;
                w_mux_data = i_data;
            end
        end

        ST_DATA: begin
            // 数据处理逻辑
            w_mux_data = r_data + 1'b1;
        end

        default: begin
            // 默认处理
        end
    endcase
end
```

### 4.3 编写输出逻辑

**做什么：** 编写输出信号生成逻辑。

```systemverilog
// 输出逻辑
always_comb begin
    o_ready = (r_state == ST_IDLE);
    w_valid = (r_state == ST_DATA) && w_data_done;
end
```

### 4.4 避免 锁存器

**做什么：** 确保组合逻辑不会产生锁存器。

**锁存器产生原因：**
- 组合逻辑中信号没有在所有分支赋值
- `case` 语句没有 `default`
- `if` 语句没有 `else`

**✅ 正确：先给默认值**

```systemverilog
always_comb begin
    // 先给默认值，避免锁存
    w_result = '0;

    case (sel)
        2'b00: w_result = a;
        2'b01: w_result = b;
        2'b10: w_result = c;
        // 不需要 default，已经有默认值
    endcase
end
```

**✅ 正确：有 default 分支**

```systemverilog
always_comb begin
    case (sel)
        2'b00: w_result = a;
        2'b01: w_result = b;
        2'b10: w_result = c;
        default: w_result = '0;  // 必须
    endcase
end
```

**❌ 错误：没有默认值，会产生锁存**

```systemverilog
always_comb begin
    case (sel)
        2'b00: w_result = a;
        2'b01: w_result = b;
        2'b10: w_result = c;
        // sel = 2'b11 时，w_result 保持原值 → 锁存！
    endcase
end
```

**检查清单：**
- [ ] 所有组合逻辑都有默认值
- [ ] `case` 语句有 `default` 分支
- [ ] 使用 `always_comb` 让工具检查锁存
- [ ] 使用阻塞赋值（=）
- [ ] 没有组合逻辑环路

---

## 步骤 5：跨时钟域处理

如果模块涉及多个时钟域，必须正确处理跨时钟域信号。

### 5.1 识别跨时钟域信号

**做什么：** 列出所有跨时钟域信号。

**输出：** 跨时钟域信号列表

| 信号名 | 源时钟域 | 目标时钟域 | 信号类型 |
|--------|----------|------------|----------|
| cpu_req | clk_cpu | clk_ddr | 多比特数据 |
| cpu_req_valid | clk_cpu | clk_ddr | 单比特控制 |
| ddr_ack | clk_ddr | clk_cpu | 单比特控制 |

### 5.2 单比特信号同步（慢到快）

**场景：** 单比特控制信号，从慢时钟域到快时钟域。

**方法：** 两级同步器

```systemverilog
// 单比特信号同步（慢时钟域 → 快时钟域）
module cdc_single_bit (
    input  wire i_clk_fast,    // 快时钟
    input  wire i_rst_n,
    input  wire i_signal_slow, // 慢时钟域信号
    output logic o_signal_fast // 同步后的信号
);
    (* async_reg = "true" *) logic r_sync1;
    (* async_reg = "true" *) logic r_sync2;

    always_ff @(posedge i_clk_fast or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_sync1 <= 1'b0;
            r_sync2 <= 1'b0;
        end else begin
            r_sync1 <= i_signal_slow;
            r_sync2 <= r_sync1;
        end
    end

    assign o_signal_fast = r_sync2;
endmodule
```

**要点：**
- 使用两级寄存器
- 添加 `async_reg` 属性，告诉工具这是跨时钟域寄存器
- 快时钟频率至少是慢时钟的 2-3 倍

### 5.3 单比特信号同步（快到慢）

**场景：** 单比特脉冲信号，从快时钟域到慢时钟域。

**方法：** 脉冲展宽 + 两级同步

```systemverilog
// 单比特脉冲同步（快时钟域 → 慢时钟域）
module cdc_pulse (
    input  wire i_clk_fast,    // 快时钟
    input  wire i_clk_slow,    // 慢时钟
    input  wire i_rst_n,
    input  wire i_pulse_fast,  // 快时钟域脉冲
    output logic o_pulse_slow  // 慢时钟域脉冲
);
    // 快时钟域：展宽脉冲
    logic r_toggle_fast;
    always_ff @(posedge i_clk_fast or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_toggle_fast <= 1'b0;
        end else if (i_pulse_fast) begin
            r_toggle_fast <= ~r_toggle_fast;  // 翻转
        end
    end

    // 慢时钟域：两级同步
    (* async_reg = "true" *) logic r_sync1;
    (* async_reg = "true" *) logic r_sync2;
    (* async_reg = "true" *) logic r_sync3;

    always_ff @(posedge i_clk_slow or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_sync1 <= 1'b0;
            r_sync2 <= 1'b0;
            r_sync3 <= 1'b0;
        end else begin
            r_sync1 <= r_toggle_fast;
            r_sync2 <= r_sync1;
            r_sync3 <= r_sync2;
        end
    end

    // 边沿检测
    assign o_pulse_slow = r_sync2 ^ r_sync3;
endmodule
```

### 5.4 多比特数据同步

**场景：** 多比特数据总线跨时钟域。

**方法：** 异步 FIFO

```systemverilog
// 异步 FIFO（简化版，实际使用 IP 或验证过的模块）
module async_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH       = 16
)(
    // 写时钟域
    input  wire                        i_wr_clk,
    input  wire                        i_wr_rst_n,
    input  wire [DATA_WIDTH-1:0]       i_wr_data,
    input  wire                        i_wr_en,
    output logic                       o_full,

    // 读时钟域
    input  wire                        i_rd_clk,
    input  wire                        i_rd_rst_n,
    output logic [DATA_WIDTH-1:0]      o_rd_data,
    input  wire                        i_rd_en,
    output logic                       o_empty
);
    // 使用格雷码指针跨时钟域
    // 实际实现略，使用 IP 或验证过的模块
endmodule
```

**要点：**
- 多比特数据**不能用两级同步器**
- 必须使用异步 FIFO 或握手协议
- 地址指针用格雷码

### 5.5 检查跨时钟域正确性

**做什么：** 使用 CDC 检查工具验证。

**工具：**
- SpyGlass CDC
- Questa CDC
- Vivado CDC

**检查清单：**
- [ ] 所有跨时钟域信号都已识别
- [ ] 单比特信号使用两级同步器
- [ ] 多比特数据使用异步 FIFO 或握手
- [ ] 添加了 `async_reg` 属性
- [ ] CDC 检查工具通过，无违例

---

## 步骤 6：低功耗编码

### 6.1 使用时钟门控

**做什么：** 让工具自动插入门控时钟。

**✅ 好：有使能信号，工具可以插入门控**

```systemverilog
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_data <= '0;
    end else if (i_enable) begin  // 使能信号
        r_data <= i_data;
    end
    // 没有 else，i_enable 为低时保持
end
```

**❌ 不好：一直翻转，无法门控**

```systemverilog
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_data <= '0;
    end else begin
        r_data <= i_data;  // 每个周期都更新，无法门控
    end
end
```

### 6.2 操作数隔离

**做什么：** 关闭不使用通路的翻转。

**✅ 好：选择通路不使用时停止翻转**

```systemverilog
// 选通 A 通路时，B 通路不翻转
always_comb begin
    if (i_sel == 2'b00) begin
        w_result = a_operand;
    end else if (i_sel == 2'b01) begin
        w_result = b_operand;
    end else begin
        w_result = '0;
    end
end
```

**工具会自动在 a_operand 和 b_operand 前插入门控。**

### 6.3 格雷码计数器

**做什么：** 计数器使用格雷码，减少翻转。

```systemverilog
// 二进制计数器：每次可能多位翻转
// 0111 → 1000：四位都翻转

// 格雷码计数器：每次只有一位翻转
// 0100 → 0101：只有一位翻转
```

**格雷码计数器实现：**

```systemverilog
module gray_counter #(
    parameter WIDTH = 4
)(
    input  wire                i_clk,
    input  wire                i_rst_n,
    input  wire                i_enable,
    output logic [WIDTH-1:0]   o_gray
);
    logic [WIDTH-1:0] r_binary;

    // 二进制计数器
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_binary <= '0;
        end else if (i_enable) begin
            r_binary <= r_binary + 1'b1;
        end
    end

    // 二进制转格雷码
    assign o_gray = r_binary ^ (r_binary >> 1);
endmodule
```

### 6.4 低功耗编码检查

**检查清单：**
- [ ] 所有寄存器都有使能条件
- [ ] 不使用的数据通路已隔离
- [ ] 计数器使用格雷码（如果适用）
- [ ] 门控时钟插入率 > 90%

---

## 步骤 7：代码风格检查

### 7.1 Lint 检查

**做什么：** 运行 Lint 工具检查代码质量。

**工具：**
- SpyGlass Lint
- Verilator
- Vivado Lint

**常见 Lint 警告：**

| 警告类型 | 说明 | 解决方法 |
|----------|------|----------|
| 锁存器推断 | 组合逻辑不完整 | 添加默认值 |
| 未使用信号 | 声明但未使用 | 删除或使用 |
| 位宽不匹配 | 赋值位宽不一致 | 明确位宽 |
| 多驱动 | 同一信号多处驱动 | 检查逻辑 |

### 7.2 命名检查

**做什么：** 检查命名是否符合规范。

**检查项：**
- [ ] 输入端口以 `i_` 开头
- [ ] 输出端口以 `o_` 开头
- [ ] 寄存器以 `r_` 开头
- [ ] 组合逻辑以 `w_` 开头
- [ ] 参数大写
- [ ] 状态以 `ST_` 开头

### 7.3 代码风格检查

**做什么：** 检查代码风格。

**检查项：**
- [ ] 每个文件一个模块
- [ ] 文件名和模块名一致
- [ ] 端口按顺序：时钟复位 → 配置 → 输入 → 输出
- [ ] 每个端口有注释
- [ ] 缩进 4 空格，不用 Tab
- [ ] 行宽不超过 100 字符
- [ ] 每个模块有文件头注释

---

## 步骤 8：初步仿真验证

### 8.1 编写简单测试

**做什么：** 编写基本功能测试，验证 RTL 正确性。

```systemverilog
module tb_module_name;
    // 时钟和复位
    logic clk;
    logic rst_n;

    // DUT 端口
    logic [31:0] i_data;
    logic        i_valid;
    logic        o_ready;
    logic [31:0] o_data;
    logic        o_valid;
    logic        i_ready;

    // 实例化 DUT
    module_name u_dut (
        .i_clk   (clk),
        .i_rst_n (rst_n),
        .i_data  (i_data),
        .i_valid (i_valid),
        .o_ready (o_ready),
        .o_data  (o_data),
        .o_valid (o_valid),
        .i_ready (i_ready)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz
    end

    // 复位
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    // 测试
    initial begin
        // 等待复位释放
        @(posedge rst_n);
        repeat(10) @(posedge clk);

        // 测试用例 1：基本读写
        i_data  = 32'h12345678;
        i_valid = 1;
        i_ready = 1;
        @(posedge clk);
        i_valid = 0;

        // 等待输出
        wait(o_valid);
        $display("Output data: 0x%h", o_data);

        // 测试用例 2：...

        // 结束
        #100 $finish;
    end
endmodule
```

### 8.2 运行仿真

**做什么：** 运行仿真，检查波形。

**工具：**
- VCS (Synopsys)
- Xcelium (Cadence)
- Questa (Siemens)
- Verilator (开源)

**检查项：**
- [ ] 复位后状态正确
- [ ] 基本功能正常
- [ ] 输出时序符合预期
- [ ] 无 X 态

### 8.3 检查覆盖率

**做什么：** 检查功能覆盖率和代码覆盖率。

**覆盖率类型：**
- 代码覆盖率：行覆盖、分支覆盖、状态覆盖
- 功能覆盖率：功能点覆盖

**目标：**
- 代码覆盖率 > 95%
- 功能覆盖率 > 90%

---

## 步骤 9：代码提交前检查

### 9.1 自查清单

提交代码前，逐项检查：

**可综合性检查：**
- [ ] 没有使用 `initial` 给寄存器赋初值
- [ ] 没有使用 `#delay` 延迟
- [ ] 没有使用 `fork/join`
- [ ] 所有循环次数在编译时确定
- [ ] 没有混合使用阻塞和非阻塞赋值

**命名检查：**
- [ ] 文件名和模块名一致
- [ ] 信号命名符合约定
- [ ] 参数命名大写

**代码质量检查：**
- [ ] 没有 锁存器
- [ ] `case` 语句有 `default`
- [ ] 没有组合逻辑环路
- [ ] 输出信号从寄存器出来

**跨时钟域检查：**
- [ ] 所有跨时钟域信号都有同步处理
- [ ] 单比特用两级同步器
- [ ] 多比特用异步 FIFO 或握手

**低功耗检查：**
- [ ] 有使能条件可以门控时钟
- [ ] 计数器考虑格雷码

**仿真检查：**
- [ ] 基本功能测试通过
- [ ] 无 X 态
- [ ] Lint 无错误

### 9.2 代码审查

**做什么：** 提交代码审查请求。

**审查重点：**
- 功能正确性
- 代码可读性
- 可维护性
- 性能考虑
- 功耗考虑

### 9.3 提交版本控制

**提交信息格式：**

```
feat: 添加 XXX 模块

- 实现 XXX 功能
- 支持 YYY 配置
- 添加 ZZZ 测试
```

---

## 最终检查清单

代码完成前必须检查：

- [ ] 文件名和模块名一致
- [ ] 文件头注释完整
- [ ] 参数化设计，有默认值
- [ ] 端口排序正确
- [ ] 命名符合约定
- [ ] 寄存器有复位
- [ ] 组合逻辑有默认值
- [ ] 没有 锁存器
- [ ] 没有 `initial` 赋初值
- [ ] 没有 `#delay`
- [ ] 跨时钟域处理正确
- [ ] Lint 无错误
- [ ] 基本仿真通过

---

## 反模式（要避免）

❌ **魔法数字**：代码里直接写 `8'h42`，不说明含义

```systemverilog
// ❌ 不好
if (r_state == 2'b01) ...

// ✅ 好
localparam ST_DATA = 2'b01;
if (r_state == ST_DATA) ...
```

❌ **重复代码**：相同代码复制粘贴多处

```systemverilog
// ❌ 不好：三个地方相同的逻辑
always_comb begin
    if (sel == 0) result = a;
    else if (sel == 1) result = b;
    else result = c;
end

// ✅ 好：提取为函数
function automatic [DATA_WIDTH-1:0] mux3 (
    input [1:0] sel,
    input [DATA_WIDTH-1:0] a, b, c
);
    case (sel)
        2'b00: mux3 = a;
        2'b01: mux3 = b;
        default: mux3 = c;
    endcase
endfunction
```

❌ **太长模块**：一个模块几千行

- 拆分成多个小模块
- 每个模块 < 500 行

❌ **没有注释**：复杂算法完全没注释

- 注释说明**为什么**，不说明**做什么**
- 代码已经说明了做什么

❌ **忽略 Lint 警告**：Lint 有警告不管

- 所有 Lint 警告都要处理
- 真正没问题才 waiver

---

## 工具支持

### 商业工具

| 工具 | 用途 |
|------|------|
| SpyGlass | Lint 检查、CDC 检查 |
| VCS | 仿真 |
| Xcelium | 仿真 |
| Design Compiler | 综合 |

### 开源工具

| 工具 | 用途 |
|------|------|
| Verilator | Lint 检查、仿真 |
| Icarus Verilog | 仿真 |
| Yosys | 综合 |

---

## 代理协作

- RTL 编写完成后，使用 `verification-engineer` 代理开发验证平台
- 使用 `code-reviewer` 代理进行代码审查
- 如果是时序问题，使用 `physical-design-engineer` 代理帮助分析
