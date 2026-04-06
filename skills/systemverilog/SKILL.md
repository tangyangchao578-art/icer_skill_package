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

---

## 第一部分：设计使用的 SystemVerilog 特性（可综合子集）

以下特性用于 RTL 设计，可被综合工具综合为硬件。

### 步骤 1：接口定义

#### 1.1 创建基本接口

**做什么：** 定义接口，封装相关信号。

```systemverilog
// 定义 AXI 接口
interface axi_if #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input wire clk,
    input wire rst_n
);
    // 写地址通道
    logic [ADDR_WIDTH-1:0] awaddr;
    logic [2:0]            awprot;
    logic                  awvalid;
    logic                  awready;

    // 写数据通道
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                  wvalid;
    logic                  wready;

    // 写响应通道
    logic [1:0]            bresp;
    logic                  bvalid;
    logic                  bready;

    // 读地址通道
    logic [ADDR_WIDTH-1:0] araddr;
    logic [2:0]            arprot;
    logic                  arvalid;
    logic                  arready;

    // 读数据通道
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rvalid;
    logic                  rready;

    // 定义 modport 明确方向
    modport master (
        output awaddr, awprot, awvalid,
        input  awready,
        output wdata, wstrb, wvalid,
        input  wready,
        input  bresp, bvalid,
        output bready,
        output araddr, arprot, arvalid,
        input  arready,
        input  rdata, rresp, rvalid,
        output rready
    );

    modport slave (
        input  awaddr, awprot, awvalid,
        output awready,
        input  wdata, wstrb, wvalid,
        output wready,
        output bresp, bvalid,
        input  bready,
        input  araddr, arprot, arvalid,
        output arready,
        output rdata, rresp, rvalid,
        input  rready
    );
endinterface
```

**优点：**
- 自动整理一堆连线，减少代码量
- 减少连线错误
- 接口协议改变，只需要改一处
- 在 UVM 验证中更容易传递接口

#### 1.2 使用接口连接模块

**做什么：** 在模块中使用接口。

```systemverilog
// 定义使用接口的模块
module axi_master #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    axi_if.master axi  // 使用接口
);
    // 直接使用接口中的信号
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.awvalid <= 1'b0;
            axi.awaddr  <= '0;
        end else begin
            // 写地址逻辑
            axi.awvalid <= w_aw_valid;
            axi.awaddr  <= w_aw_addr;
        end
    end
endmodule

// 顶层连接
module top;
    logic clk;
    logic rst_n;

    // 实例化接口
    axi_if #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) axi_bus (.clk(clk), .rst_n(rst_n));

    // 实例化主设备
    axi_master u_master (
        .clk(clk),
        .rst_n(rst_n),
        .axi(axi_bus)  // 连接接口
    );

    // 实例化从设备
    axi_slave u_slave (
        .clk(clk),
        .rst_n(rst_n),
        .axi(axi_bus)  // 连接接口
    );
endmodule
```

---

### 步骤 2：always 块分类

#### 2.1 时序逻辑使用 always_ff

**做什么：** 使用 `always_ff` 描述时序逻辑，让工具自动检查。

```systemverilog
// 时序逻辑：使用 always_ff
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_state <= ST_IDLE;
        r_data  <= '0;
    end else begin
        r_state <= w_next_state;
        r_data  <= w_next_data;
    end
end
```

**优点：**
- 工具自动检查是否真的是时序逻辑
- 如果里面写了组合逻辑，工具会警告

#### 2.2 组合逻辑使用 always_comb

**做什么：** 使用 `always_comb` 描述组合逻辑，让工具自动检查锁存。

```systemverilog
// 组合逻辑：使用 always_comb
always_comb begin
    case (sel)
        2'b00: w_mux = a;
        2'b01: w_mux = b;
        2'b10: w_mux = c;
        default: w_mux = '0;
    endcase
end
```

**优点：**
- 工具自动检查是否完整赋值
- 如果产生锁存器，工具会警告
- 不需要写敏感列表，自动推断

#### 2.3 锁存器使用 always_latch

**做什么：** 如果确实需要锁存器，使用 `always_latch` 明确告诉工具。

```systemverilog
// 锁存器：使用 always_latch（确实需要时才用）
always_latch begin
    if (enable) begin
        latched_data = data_in;
    end
end
```

---

### 步骤 3：类型定义

#### 3.1 使用 typedef 定义类型

**做什么：** 定义自定义类型，提高代码可读性。

```systemverilog
// 定义地址类型
typedef logic [31:0] addr_t;

// 定义数据类型
typedef logic [63:0] data_t;

// 定义状态枚举
typedef enum logic [2:0] {
    ST_IDLE = 3'b000,
    ST_DATA = 3'b001,
    ST_WAIT = 3'b010,
    ST_DONE = 3'b011,
    ST_ERROR = 3'b100
} state_t;

// 定义结构体
typedef struct packed {
    addr_t address;
    data_t data;
    logic  valid;
    logic  ready;
} transaction_t;

// 使用自定义类型
module my_module (
    input  wire          clk,
    input  wire          rst_n,
    input  addr_t        i_addr,    // 使用 addr_t
    input  data_t        i_data,    // 使用 data_t
    output transaction_t o_trans    // 使用 transaction_t
);
    state_t r_state;  // 使用 state_t
    // ...
endmodule
```

**优点：**
- 提高代码可读性
- 类型检查更严格
- 修改位宽只需要改一处

#### 3.2 使用 struct 组织相关数据

**做什么：** 把相关数据放在一起。

```systemverilog
// 定义配置结构体
typedef struct packed {
    logic [3:0]  mode;
    logic [7:0]  threshold;
    logic        enable;
    logic        interrupt_en;
} config_t;

// 定义状态结构体
typedef struct packed {
    logic        busy;
    logic        error;
    logic [7:0]  counter;
    logic        done;
} status_t;

// 使用
config_t r_config;
status_t r_status;

// 赋值
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_config <= '0;
        r_status <= '0;
    end else begin
        r_config.mode <= i_mode;
        r_config.threshold <= i_threshold;
        r_config.enable <= i_enable;
    end
end
```

---

### 步骤 4：参数化设计

#### 4.1 使用参数提高复用性

**做什么：** 使用参数让模块可配置。

```systemverilog
module fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH       = 16,
    // 派生参数
    parameter ADDR_WIDTH  = $clog2(DEPTH)
)(
    input  wire                        i_clk,
    input  wire                        i_rst_n,

    // 写接口
    input  wire [DATA_WIDTH-1:0]       i_wr_data,
    input  wire                        i_wr_en,
    output logic                       o_full,

    // 读接口
    output logic [DATA_WIDTH-1:0]      o_rd_data,
    input  wire                        i_rd_en,
    output logic                       o_empty
);
    // 使用参数
    logic [DATA_WIDTH-1:0] r_mem[DEPTH];
    logic [ADDR_WIDTH-1:0] r_wr_addr;
    logic [ADDR_WIDTH-1:0] r_rd_addr;

    // ...
endmodule

// 实例化时配置参数
fifo #(
    .DATA_WIDTH (64),
    .DEPTH      (32)
) u_fifo (
    .i_clk     (clk),
    .i_rst_n   (rst_n),
    // ...
);
```

#### 4.2 使用 generate 生成重复模块

**做什么：** 使用 generate 生成重复结构。

```systemverilog
module multi_channel #(
    parameter NUM_CHANNELS = 4,
    parameter DATA_WIDTH   = 32
)(
    input  wire                        i_clk,
    input  wire                        i_rst_n,
    input  wire [NUM_CHANNELS-1:0]     i_valid,
    input  wire [NUM_CHANNELS*DATA_WIDTH-1:0] i_data,
    output logic [NUM_CHANNELS-1:0]    o_ready
);
    genvar i;

    generate
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin: gen_channels
            // 每个通道实例化一个处理模块
            channel_processor #(
                .DATA_WIDTH (DATA_WIDTH)
            ) u_processor (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_valid (i_valid[i]),
                .i_data  (i_data[i*DATA_WIDTH +: DATA_WIDTH]),
                .o_ready (o_ready[i])
            );
        end
    endgenerate
endmodule
```

**要点：**
- `genvar` 用于 generate 循环变量
- `begin: name` 给生成的块命名，方便访问

---

### 步骤 5：可综合性检查

设计使用的 SystemVerilog 特性必须是可综合的。

#### 5.1 可综合特性列表

| 特性 | 可综合？ | 说明 |
|------|----------|------|
| `logic` | ✅ | 替代 `reg` 和 `wire` |
| `always_ff` | ✅ | 时序逻辑 |
| `always_comb` | ✅ | 组合逻辑 |
| `always_latch` | ✅ | 锁存器 |
| `interface` | ✅ | 接口封装 |
| `modport` | ✅ | 接口方向定义 |
| `typedef` | ✅ | 类型定义 |
| `struct` | ✅ | 结构体 |
| `enum` | ✅ | 枚举 |
| `parameter` | ✅ | 参数 |
| `localparam` | ✅ | 局部参数 |
| `generate` | ✅ | 生成 |
| `$clog2()` | ✅ | 编译时计算对数 |

#### 5.2 不可综合特性列表

以下特性**只能用于验证**，不能用于设计：

| 特性 | 可综合？ | 说明 |
|------|----------|------|
| `class` | ❌ | 类，只能用于验证 |
| `dynamic array` | ❌ | 动态数组 |
| `associative array` | ❌ | 关联数组 |
| `queue` | ❌ | 队列 |
| `string` | ❌ | 字符串 |
| `virtual` | ❌ | 虚方法 |
| `program` | ❌ | 程序块 |
| `clocking block` | ❌ | 时钟块（设计不用） |
| `initial` | ❌ | 初始块（综合忽略） |
| `#delay` | ❌ | 延迟（综合忽略） |
| `fork/join` | ❌ | 并发块 |

#### 5.3 可综合性检查清单

- [ ] 没有使用动态数组
- [ ] 没有使用类
- [ ] 没有使用 `initial` 赋初值
- [ ] 没有使用 `#delay`
- [ ] 所有参数在编译时确定
- [ ] 所有循环次数在编译时确定
- [ ] 所有变量位宽确定

---

## 第二部分：验证使用的 SystemVerilog 特性

以下特性用于验证平台，不可综合。

### 步骤 6：面向对象编程

#### 6.1 类定义

**做什么：** 使用类封装验证组件。

```systemverilog
// 定义事务类
class transaction;
    rand logic [31:0] addr;
    rand logic [31:0] data;
    rand bit           read;  // 0=write, 1=read

    // 约束
    constraint addr_align {
        addr[1:0] == 2'b00;  // 地址 4 字节对齐
    }

    constraint addr_range {
        addr inside {[0:32'hFFFF_FFFF]};
    }

    // 打印函数
    function void print();
        $display("Transaction: addr=0x%h, data=0x%h, read=%b", addr, data, read);
    endfunction
endclass
```

#### 6.2 继承

**做什么：** 复用基类代码。

```systemverilog
// 基类
class base_transaction;
    rand logic [31:0] addr;
    rand logic [31:0] data;

    function void print();
        $display("addr=0x%h, data=0x%h", addr, data);
    endfunction
endclass

// 派生类
class burst_transaction extends base_transaction;
    rand int burst_length;

    constraint burst_range {
        burst_length inside {[1:16];
    }

    function void print();
        $display("addr=0x%h, data=0x%h, burst_length=%0d", addr, data, burst_length);
    endfunction
endclass
```

#### 6.3 多态

**做什么：** 运行时选择不同实现。

```systemverilog
// 基类
virtual class sequence;
    pure virtual task body();
endclass

// 派生类 1
class read_sequence extends sequence;
    virtual task body();
        // 读序列
    endtask
endclass

// 派生类 2
class write_sequence extends sequence;
    virtual task body();
        // 写序列
    endtask
endclass

// 使用多态
sequence seq;
seq = read_sequence::new();
seq.body();  // 执行读序列

seq = write_sequence::new();
seq.body();  // 执行写序列
```

---

### 步骤 7：约束随机验证

#### 7.1 定义约束

**做什么：** 定义随机约束，生成合法激励。

```systemverilog
class axi_transaction;
    rand logic [31:0] addr;
    rand logic [31:0] data;
    rand logic [3:0]  strb;
    rand bit           read;  // 0=write, 1=read
    rand int           delay;

    // 地址对齐约束
    constraint addr_align {
        addr % 4 == 0;  // 4 字节对齐
    }

    // 地址范围约束
    constraint addr_range {
        addr inside {[32'h0000_0000:32'h0000_FFFF]};  // 64KB 范围
    }

    // 写选通约束
    constraint strb_valid {
        if (read) {
            strb == 4'hF;  // 读操作，选通全 1
        } else {
            strb inside {4'h1, 4'h3, 4'hF};  // 写操作，合法选通
        }
    }

    // 延迟约束
    constraint delay_range {
        delay inside {[0:10]};
    }

    // 读写比例约束
    constraint read_write_ratio {
        read dist {0 := 60, 1 := 40};  // 60% 写，40% 读
    }
endclass
```

#### 7.2 使用约束

```systemverilog
program test;
    axi_transaction trans;

    initial begin
        trans = new();

        repeat(100) begin
            if (!trans.randomize()) begin
                $error("Randomization failed");
            end

            trans.print();

            // 发送事务
            drive_transaction(trans);
        end
    end
endprogram
```

---

### 步骤 8：功能覆盖率

#### 8.1 定义覆盖组

**做什么：** 定义功能覆盖点。

```systemverilog
class axi_transaction;
    rand logic [31:0] addr;
    rand logic [31:0] data;
    rand bit           read;

    // 覆盖组
    covergroup addr_cg @(posedge clk);
        option.per_instance = 1;

        // 地址覆盖点
        addr_cp: coverpoint addr {
            bins low    = {[0:32'h0000_3FFF]};
            bins mid    = {[32'h0000_4000:32'h0000_BFFF]};
            bins high   = {[32'h0000_C000:32'h0000_FFFF]};
            bins others = default;
        }

        // 读写覆盖点
        read_cp: coverpoint read {
            bins write = {0};
            bins read  = {1};
        }

        // 交叉覆盖
        addr_read_cross: cross addr_cp, read_cp;
    endgroup

    // 构造函数
    function new();
        addr_cg = new();
    endfunction
endclass
```

#### 8.2 使用覆盖组

```systemverilog
program test;
    axi_transaction trans;

    initial begin
        trans = new();

        repeat(1000) begin
            trans.randomize();
            drive_transaction(trans);
            trans.addr_cg.sample();  // 采样覆盖组
        end

        // 报告覆盖率
        $display("Address coverage: %0.2f%%", trans.addr_cg.get_coverage());
    end
endprogram
```

---

## 第三部分：编码风格

### 步骤 9：排版格式

#### 9.1 缩进和行宽

**规则：**
- 缩进：4 个空格，**不使用 Tab**
- 行宽：最大 100 字符，超过换行对齐

```systemverilog
// ✅ 好：缩进 4 空格，行宽合理
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_state <= ST_IDLE;
        r_data  <= '0;
    end else begin
        r_state <= w_next_state;
        r_data  <= w_next_data;
    end
end

// ✅ 好：长行换行对齐
assign w_result = (sel == 2'b00) ? a :
                  (sel == 2'b01) ? b :
                  (sel == 2'b10) ? c : '0;
```

#### 9.2 端口声明

**规则：** 每个端口单独一行，加注释。

```systemverilog
module my_module #(
    parameter DATA_WIDTH = 32
)(
    // 时钟和复位
    input  wire                        i_clk,      // 时钟
    input  wire                        i_rst_n,    // 异步复位，低有效

    // 配置接口
    input  wire [DATA_WIDTH-1:0]       i_config,   // 配置数据

    // 数据输入
    input  wire [DATA_WIDTH-1:0]       i_data,     // 输入数据
    input  wire                        i_valid,    // 输入有效

    // 数据输出
    output logic [DATA_WIDTH-1:0]      o_data,     // 输出数据
    output logic                       o_valid     // 输出有效
);
```

#### 9.3 注释规范

**文件头注释：**

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
//-----------------------------------------------------------------------------
```

**端口注释：** 每个端口后面加注释

**代码注释：** 注释解释**为什么**，不解释**做什么**

```systemverilog
// ✅ 好：注释解释为什么
// 格雷码计数器，降低功耗，因为只有一位翻转
always_ff @(posedge clk) begin
    r_gray <= r_binary ^ (r_binary >> 1);
end

// ❌ 坏：注释解释做什么（代码已经说明了）
// 这是一个计数器
always_ff @(posedge clk) begin
    r_counter <= r_counter + 1'b1;
end
```

---

## 第四部分：工具支持

### 步骤 10：工具使用

#### 10.1 商业工具

| 工具 | 公司 | 用途 |
|------|------|------|
| VCS | Synopsys | 仿真 |
| Xcelium | Cadence | 仿真 |
| Questa | Siemens | 仿真 |
| Design Compiler | Synopsys | 综合 |
| Genus | Cadence | 综合 |

#### 10.2 开源工具

| 工具 | 用途 |
|------|------|
| Verilator | Lint 检查、仿真 |
| Icarus Verilog | 仿真 |
| Yosys | 综合 |

---

## 最终检查清单

### 设计代码检查

- [ ] 没有使用动态数组、类等不可综合特性
- [ ] 使用 `always_ff` 描述时序逻辑
- [ ] 使用 `always_comb` 描述组合逻辑
- [ ] 组合逻辑有默认值，避免锁存器
- [ ] `case` 语句有 `default` 分支
- [ ] 所有参数在编译时确定
- [ ] 所有循环次数在编译时确定
- [ ] 文件名和模块名一致
- [ ] 命名符合约定
- [ ] 注释完整

### 验证代码检查

- [ ] 使用类封装验证组件
- [ ] 使用约束随机生成激励
- [ ] 使用功能覆盖率收集覆盖
- [ ] 测试用例有自检机制
- [ ] 覆盖率达到目标

---

## 反模式（要避免）

❌ **在设计中使用验证特性**：动态数组、类、队列等不可综合

```systemverilog
// ❌ 设计中错误使用
int dynamic_array[];  // 不可综合
class my_class;       // 不可综合
```

❌ **没有给 generate 块命名**：生成的模块层次不好访问

```systemverilog
// ❌ 不好
generate
    for (i = 0; i < 4; i++) begin  // 没有名字
        // ...
    end
endgenerate

// ✅ 好
generate
    for (i = 0; i < 4; i++) begin: gen_channels  // 有名字
        // ...
    end
endgenerate
```

❌ **混合 Verilog 和 SystemVerilog 不必要**：统一都用 SystemVerilog 更好

❌ **文件和模块名不一致**：找代码困难

---

## 代理协作

- 使用 `rtl-designer` 代理进行 RTL 设计
- 使用 `verification-engineer` 代理进行验证平台开发
- 使用 `code-reviewer` 代理进行代码审查
