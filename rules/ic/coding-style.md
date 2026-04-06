> 此文件扩展 [common/coding-style.md](../common/coding-style.md) IC 编码风格特定内容。

# 编码风格 - IC 特定扩展

## SystemVerilog IC 特定编码风格

### 端口列表排序

推荐排序：

1. 时钟和复位
2. 输入接口
3. 输出接口
4. 配置接口

便于阅读：

```systemverilog
module mymodule
  (
  // Clock and reset
  input  wire        i_clk,
  input  wire        i_rst_n,

  // Configuration inputs
  input  wire [W-1:0] i_config,

  // Data inputs
  input  wire [W-1:0] i_data,
  input  wire        i_valid,

  // Data outputs
  output logic [W-1:0] o_data,
  output logic        o_valid
  );
```

### 参数化设计

- 使用 `parameter` 进行参数化
- 参数默认值合理
- 支持不同位宽配置
- 支持深度配置

### generate 语句使用

- generate 用于例化多个相同模块
- generate 用于条件例化
- generate 块要加名字
- 便于调试层次访问

### 宏使用

- 宏用于全局配置
- 不要过度使用宏
- 宏定义放在头文件
- 使用 `ifdef  endif` 包裹

### 注释要点

- 每个模块开头注释说明功能
- 每个端口注释说明含义
- 复杂算法注释说明原理
- 修改记录标注重要修改

### 版本控制

- 不要在代码中留注释掉的旧代码
- 版本控制保存历史
- 删除不需要的代码

## TCL 脚本编码风格 IC 特定

- 变量名使用小写加下划线
- 每个步骤输出日志信息
- 检查错误，失败退出
- 使用过程封装公共操作
- 支持增量编译

### 推荐结构：

```tcl
# Step 1: Read design
puts "Step 1: Reading design..."
read_verilog $rtl_files
if {![current_design]} {
  error "Failed to read design"
  exit 1
}

# Step 2: Read constraints
puts "Step 2: Reading constraints..."
read_sdc $constraint_file
```

## Python 脚本编码风格 IC 特定

- 使用函数模块化
- 使用类组织相关操作
- 文档字符串说明功能
- 使用 argparse 处理命令行参数
- 日志输出帮助调试

## 可维护性

- 代码清晰比代码短小重要
- 可读代码比聪明代码重要
- 注释说明为什么，不是做什么
- 一致的风格比完美风格重要

## 参考资源

使用 `rtl-coding` 技能获取更详细的 RTL 编码指导。
