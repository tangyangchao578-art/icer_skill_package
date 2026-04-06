---
name: rtl-coding
description: RTL 编码技能
description.zh: RTL 编码技能
author: ICER Skill Package
categories: front-end
---

# RTL 编码技能

当用户需要编写 RTL 代码时，启用此技能。此技能提供可综合、可验证、可维护的 RTL 编码指导。

## 使用时机

- 编写新的 RTL 模块
- 修改现有的 RTL 代码
- RTL 代码重构优化
- RTL 代码审查

## 基本模板

### 同步时序逻辑模板

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

✅ **推荐：**
- 使用 `always_ff` 描述时序逻辑
- 使用 `always_comb` 描述组合逻辑
- 使用参数化设计
- 使用 generate 生成重复模块

❌ **避免：**
- `initial` 块给寄存器赋初值（综合忽略）
- `#delay` 行为级延迟（不可综合）
- fork/join 并行块（不可综合）
- 混合使用阻塞和非阻塞赋值在同一个 always块

## 命名约定

- 输入：`i_*`
- 输出：`o_*`
- 寄存器：`r_*`
- 连线：`w_*`
- 参数/常量：大写 `PARAMETER_NAME`
- 状态：`ST_*`

## 时序设计准则

- 输出尽量从寄存器出（输出流水线）
- 输入打拍再使用（输入流水线）
- 避免长组合逻辑路径
- 大扇出信号寄存器分割
- 跨时钟域必须同步
- 不要用组合逻辑产生时钟

## 复位设计准则

- 整个项目保持一致：要么全异步复位，要么全同步复位
- 数据通路寄存器必须复位
- 不改变状态的存储器可以不复位
- 异步复位需要同步释放

## 面积优化

- 复用运算单元
- 合理状态编码（二进制最小面积）
- 去除不必要的寄存器
- 使用工艺库提供的硬宏（乘法器、存储器）

## 功耗优化

- 使用门控时钟
- 操作数隔离
- 格雷码编码计数器
- 关断不使用模块时钟

## 代码审查检查清单

- [ ] 命名符合约定
- [ ] 所有端口有定义
- [ ] default case 存在
- [ ] 没有不完全条件产生锁存
- [ ] 复位正确
- [ ] 跨时钟域处理正确
- [ ] 满足编码风格

## 工具检查

- 运行 lint 检查（SpyGlass/Verilator）
- 运行 CDC 检查（所有跨时钟域）
- 运行初步综合检查面积时序

## 代理协作

- RTL 编写完成后，使用 `code-reviewer` 代理进行代码审查
- 使用 `verification-engineer` 代理开发验证平台
