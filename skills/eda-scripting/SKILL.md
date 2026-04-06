---
name: eda-scripting
description: EDA工具脚本开发技能
description.zh: EDA工具脚本开发技能
author: ICER Skill Package
categories: tools
---

# EDA 工具脚本开发技能

当用户需要开发 EDA 工具自动化流程脚本时，启用此技能。

## 使用时机

- 综合脚本开发
- 布局布线脚本开发
- 仿真脚本开发
- 回归测试脚本开发
- 结果分析脚本开发

## TCL 脚本最佳实践

### 脚本结构

```tcl
# 配置
set DESIGN "my_design"
set TOP "top_module"
set OUTPUT_DIR "./output"

# 创建输出目录
file mkdir $OUTPUT_DIR

# 读入设计
puts "Reading design..."
read_verilog $RTL_FILES
hierarchy -top $TOP

# 检查错误
if {![current_design]} {
  error "Failed to read design"
  exit 1
}

# 综合...

# 输出结果
write_verilog -o $OUTPUT_DIR/${TOP}.netlist.v
write_sdc -o $OUTPUT_DIR/${TOP}.sdc

puts "Done."
```

### TCL 编码准则

- [ ] 变量使用小写加下划线
- [ ] 每个步骤输出日志信息 `puts "Step ..."`
- [ ] 检查每个步骤是否成功，失败立即退出
- [ ] 使用文件操作创建输出目录
- [ ] 使用环境变量获取工艺库路径，不要硬编码

## Python 脚本最佳实践

### 用于：

- 结果数据分析
- 流程控制
- 批量处理
- 报告生成

### 编码准则：

- 使用函数组织代码
- 使用 argparse 处理命令行参数
- 使用 logging 输出日志
- 异常捕获处理
- 类型提示增加可读性

示例：

```python
import argparse
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', help='Input report file', required=True)
    args = parser.parse_args()
    
    logger.info(f"Processing {args.input}")
    # process...

if __name__ == '__main__':
    main()
```

## Makefile 流程管理

```makefile
.PHONY: synth place route signoff clean

synth:
	mkdir -p logs
	dc_shell -f scripts/synth.tcl | tee logs/synth.log

place:
	mkdir -p logs
	icc2_shell -f scripts/place.tcl | tee logs/place.log

route:
	mkdir -p logs
	icc2_shell -f scripts/route.tcl | tee logs/route.log

signoff:
	pt_shell -f scripts/signoff.tcl | tee logs/signoff.log

clean:
	rm -rf output/* logs/*
```

## 环境管理

- 使用环境变量指定工艺库位置
```bash
export PDK_ROOT=/opt/pdk/180nm
export STD_CELL_LIBRARY=$(PDK_ROOT)/libs/stdcells
```
- 不要硬编码绝对路径在脚本中
- 使用模块工具管理不同工具版本
```bash
module load synopsys/dc/2021.03
```

## 增量运行支持

- 支持只运行修改过的步骤
- 保存检查点，方便重启
- 不要每次都从头运行
- 节省运行时间

## 结果收集和报告

- 收集每个步骤的关键结果（面积、WNS、功耗）
- 生成对比报告
- 追踪 QoR (Quality of Results) 变化
- 帮助评估优化效果

## 回归测试

- 每次 RTL 修改自动运行全流程
- 对比结果，发现回归
- 邮件通知失败
- 夜间自动运行

## 常见错误处理

- 工具license失败：脚本应该检测并退出，不继续运行
- 磁盘空间不够：提前检查
- 输入文件不存在：提前检查
- 清晰的错误信息帮助定位问题

## 版本控制

- 所有脚本纳入版本控制
- 不要提交二进制结果
- 记录工具版本
- 记录修改历史

## 代理协作

- 使用 `eda-scripting-developer` 代理进行 EDA 脚本开发
- 复杂流程分解为多个脚本
