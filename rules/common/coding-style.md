# 编码风格

## 目的

定义统一的 RTL/SystemVerilog/TCL 编码风格，提高代码可读性和可维护性。

## SystemVerilog/Verilog 编码风格

### 命名约定

- **模块名**：小写字母加下划线 `snake_case`
- **信号名**：小写字母加下划线 `snake_case`
- **常量/参数**：大写字母加下划线 `UPPER_CASE`
- **状态机状态**：`ST_xxx` 格式，大写
- **宏定义**：`` 反引号开头，大写 `DEFINE`

### 前缀约定

- 输入端口：`i_` 前缀
- 输出端口：`o_` 前缀
- 双向端口：`io_` 前缀
- 内部寄存器：`r_` 前缀
- 内部连线：`w_` 前缀

示例：
```systemverilog
input  wire        i_clk;
input  wire        i_rst_n;
output logic       o_valid;
logic              r_data;
wire               w_next;
```

### 文件组织

- 一个文件一个模块
- 文件名和模块名一致
- 按层次组织目录结构
- 每个目录存放一个子系统

### 缩进和格式

- 使用 4 个空格缩进，不使用 Tab
- 每行长度不超过 80-100 字符
- 每个 port 声明占一行
- 每个 signal 声明占一行
- begin/end 单独占一行

### 编码结构推荐

```systemverilog
module module_name
  (
  // Clock and reset
  input  wire        i_clk,
  input  wire        i_rst_n,

  // Inputs
  input  wire [W-1:0] i_data,
  input  wire        i_valid,

  // Outputs
  output logic [W-1:0] o_data,
  output logic       o_valid
  );

// Local parameters
localparam STATE_IDLE  = 2'b00;
localparam STATE_DATA = 2'b01;

// Internal signals
logic [1:0] r_state;
logic [1:0] w_next_state;

// Next state logic
always_comb begin
  case (r_state)
    STATE_IDLE: begin
      if (i_valid) begin
        w_next_state = STATE_DATA;
      end else begin
        w_next_state = STATE_IDLE;
      end
    end
    // ... other states
    default: begin
      w_next_state = STATE_IDLE;
    end
  endcase
end

// State register
always_ff @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    r_state <= STATE_IDLE;
  end else begin
    r_state <= w_next_state;
  end
end

endmodule
```

## 可综合性准则

- [ ] 使用 `always_ff` 描述时序逻辑
- [ ] 使用 `always_comb` 描述组合逻辑
- [ ] 不用 `initial` 块对寄存器赋初值
- [ ] 不用 `#delay` 延迟
- [ ] 不用 fork/join 并行块（除了仿真）

## TCL 脚本编码风格

- 命令小写，参数大写
- 使用注释说明每个步骤
- 变量使用小写加下划线
- 复杂流程分多个文件
- 使用过程封装重复操作

## Python 脚本编码风格

遵循 PEP 8：
- 4 空格缩进
- 小写加下划线命名
- 最大行宽 79 字符
- 适当空行分隔逻辑块
- 文档字符串说明函数功能

## 代理使用

代码编写完成后，使用 **code-reviewer** 代理检查编码风格。
