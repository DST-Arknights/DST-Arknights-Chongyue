# 版本更新记录

## v2.1.1 (2026-08-18)

[claude-code:unrecognized_model] {"model":"deepseek-v4-flash","query_source":"generate_session_title"}
- Migrated skill and talent activation/deactivation callbacks to the config interface | 将技能和天赋的激活与停用回调迁移至配置接口

## v2.1.0 (2026-08-18)

[claude-code:unrecognized_model] {"model":"deepseek-v4-flash","query_source":"generate_session_title"}
- Refactored damage calculation to internal additive stacking via new chongyue_damage module | 重构伤害计算逻辑为内部加算，新增 chongyue_damage 模块
- Replaced multiplicative logic with additive damage bonuses using SourceModifierList | 使用 SourceModifierList 创建伤害加成加法器，替代原有乘算逻辑
- Updated Skill 2 AOE attack logic to work with the new additive damage system | 更新二技能 AOE 攻击等逻辑以适应新的伤害加成方式
- Corrected Skill 3 physical damage multiplier from 180% to 260% in Chinese and English locale files | 修正中英文语言文件中三技能描述的物理伤害倍率，由 180% 调整为 260%

## v2.0.5 (2026-08-07)

- Added English language support, updated UI text language options | 添加英文语言支持，更新界面文本语言选项

本项目的所有重要变更。

## v2.0.4 (2026-07-28)

- Added publish scripts with version bump and dependency check support | 新增发布脚本，支持版本升级与依赖检查
- Optimized language processing and fixed MergePOFile parameter configuration | 优化语言处理，修复 MergePOFile 参数设置
