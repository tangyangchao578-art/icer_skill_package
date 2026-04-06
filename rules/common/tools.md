# EDA 工具使用指南

## 目的

定义 EDA 工具使用的最佳实践，确保流程可重复、可自动化、可调试。

## 版本控制

- [ ] EDA 脚本必须纳入版本控制
- [ ] 记录工具版本号
- [ ] 使用相对路径，不依赖个人环境
- [ ] 配置文件使用模板，实际配置通过环境变量覆盖
- [ ] 不要提交二进制文件到版本控制

## 开源工具

### Yosys（逻辑综合）

- 使用 `read_verilog` 读入设计
- 使用 `hierarchy -check` 检查层次
- 使用 `synth` 进行综合
- 使用 `write_verilog` 输出网表
- 使用 `stat` 报告面积统计

### Verilator（仿真）

- 适合单元级仿真
- 使用 C++/SystemC 编译仿真
- 启用 `--assert` 支持断言
- 启用 `--coverage` 收集覆盖率
- 速度快，适合回归测试

### OpenROAD（布局布线）

- 开源 RTL-to-GDS 流程
- 支持 7nm 到 180nm 工艺
- 集成基本的物理优化
- 适合学术项目和原型设计

### SymbiFlow（FPGA 工具链）

- 开源 FPGA 工具链
- 支持 Xilinx 和 Intel FPGA
- 完全开源流程

## 商业工具

### Synopsys

- **Design Compiler**：逻辑综合
  - 使用 UPF 进行功耗管理
  - 使用 TCL 脚本控制流程
  - 保存中间检查点方便重启

- **IC Compiler II**：布局布线
  - 使用 Zroute 进行布线
  - 使用 CTS 进行时钟树综合
  - 支持高性能低功耗优化

- **PrimeTime**：静态时序分析
  - 生成准确的时序报告
  - 检查建立和保持时间
  - 支持 OCv 分析

- **VCS**：仿真
  - 支持 UVM
  - 支持覆盖率收集
  - 支持调试

- **SpyGlass**：lint CDC 检查
  - 进行代码质量检查
  - 进行 CDC 分析
  - 进行功耗分析

### Cadence

- **Genus**：逻辑综合
- **Innovus**：布局布线
- **Xcelium**：仿真
- **Conformal**：等价性检查
- **Tempus**：静态时序分析

### Siemens EDA

- **Questa**：仿真
- **Veloce**：硬件仿真
- **Calibre**：物理验证 DRC/LVS/PEX

## 脚本编写准则

- [ ] 使用 TCL 编写工具流程脚本
- [ ] 使用 Python 编写数据分析和流程控制脚本
- [ ] 支持增量运行：只重新运行修改的步骤
- [ ] 输出日志文件，方便问题定位
- [ ] 检查每个步骤是否成功，失败立即退出
- [ ] 生成 HTML 报告汇总结果

示例脚本框架：

```tcl
# 设置变量
set DESIGN "my_design"
set TOP "top_module"

# 读入设计
read_verilog $RTL_FILES
hierarchy -top $TOP

# 检查是否成功
if {![current_design]} {
  error "Failed to read design"
  exit 1
}

# 综合...
synth

# 输出结果
write_verilog -o $OUTPUT/netlist.v
```

## 环境管理

- 使用模块工具（module）管理不同工具版本
- 使用环境变量指定工艺库位置
- 不要硬编码路径
- 使用 `find` 自动搜索，不要写死路径

## 回归测试

- [ ] 每次代码提交自动运行回归
- [ ] 使用 Makefile 或 Python 脚本管理流程
- [ ] 对比结果和基准，发现变更
- [ ] 邮件通知失败结果

## 代理使用

- EDA 脚本开发：使用 **eda-scripting-developer** 代理
- 流程问题调试：使用 **build-error-resolver** 代理
