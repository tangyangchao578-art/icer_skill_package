> 此文件扩展 [common/tools.md](../common/tools.md) IC EDA 工具特定内容。

# EDA 工具 - IC 特定扩展

## 开源 vs 商业工具选择指南

### 适合使用开源工具的场景

- 学术研究项目
- 原型验证
- 中小规模设计
- 成本敏感项目
- 不需要先进工艺支持

### 适合使用商业工具的场景

- 大规模工业设计
- 先进工艺（16nm 及以下）
- 需要完整签出流程
- 需要厂商支持
- 需要符合认证要求

## 流片签出要求

商业工具签出是工业流片的标准要求：

- DRC/LVS 必须使用 foundry 认可的工具
- 签出文件必须符合 foundry 要求
- 必须使用正确的工艺文件版本
- 必须满足所有 foundry 检查要求

## 工艺库管理

- 工艺库文件不要放到版本控制（大文件，IP）
- 使用环境变量指定工艺库位置
- 记录工艺库版本
- 不同项目使用对应工艺库版本
- 使用 symbolic link 指向实际位置

## 流程管理

### Makefile 管理流程

```makefile
synth:
  dc_shell -f scripts/synth.tcl | tee logs/synth.log

place:
  icc2_shell -f scripts/place.tcl | tee logs/place.log

route:
  icc2_shell -f scripts/route.tcl | tee logs/route.log
```

### 现代流程管理

- 使用 Python 脚本管理整个流程
- 使用 YAML 配置文件
- 支持增量运行
- 自动检查点保存
- 失败重试支持

## 结果管理

- 每次运行保存结果报告
- 使用版本号管理不同迭代结果
- 对比不同迭代的 QoR（质量结果）
- 记录面积、时序、功耗
- 绘制 QoR 改进曲线

## 日志管理

- 每个步骤输出日志文件
- 日志包含时间戳
- 错误信息明确
- 工具版本信息记录在日志开头
- 方便问题定位

## 环境变量设置示例

```bash
# .bashrc 或环境配置文件
export PDK_ROOT=/path/to/pdk
export STD_CELL_LIBRARY=$PDK_ROOT/libs/ref/stdcells
export TOOLS_INSTALL=/opt/eda
```

## 许可证管理

- 商业工具需要正确的许可证
- 检查许可证数量足够
- 集群运行考虑许可证分布
- 长期运行检查许可证续租

## 参考资源

使用 `eda-scripting` 技能获取 EDA 脚本开发指导。
