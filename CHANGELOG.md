# 版本更新记录

## v2.1.2 (2026-08-18)

- 数值平衡调整，技能强度按 3>2>1 排序
- 技能1 伤害倍率下调：2/3/4 → 1.8/2.4/3.0
- 技能2 伤害倍率下调：L1 3.5/4.8 → 3.0/3.4，L2 4.5/6.5 → 3.4/3.8
- 技能3 范围伤害倍率恢复至 4.0，还原精英三终极强度
- 天赋1 属性倍率下调：1.55/1.65 → 1.45/1.55
- 天赋2 skillEnergy 3 → 2，空手攻速 1.5 → 1.4
- 同步更新中英文技能与天赋描述

---

- Rebalanced skill values so strength is ordered skill 3 > 2 > 1
- Skill 1 damageMultiplier reduced: 2/3/4 → 1.8/2.4/3.0
- Skill 2 damage multipliers reduced: L1 3.5/4.8 → 3.0/3.4, L2 4.5/6.5 → 3.4/3.8
- Skill 3 aoeDamageMultiplier restored to 4.0, recovering Elite 3 ultimate strength
- Talent 1 stat multipliers reduced: 1.55/1.65 → 1.45/1.55
- Talent 2 skillEnergy reduced 3 → 2, bare-handed attack speed reduced 1.5 → 1.4
- Synced updated Chinese and English skill/talent descriptions

## v2.1.1 (2026-08-18)

- 将技能和天赋的激活与停用回调迁移至配置接口

---

- Migrated skill and talent activation/deactivation callbacks to the config interface

## v2.1.0 (2026-08-18)

- 重构伤害计算逻辑为内部加算，新增 chongyue_damage 模块
- 使用 SourceModifierList 创建伤害加成加法器，替代原有乘算逻辑
- 更新二技能 AOE 攻击等逻辑以适应新的伤害加成方式
- 修正中英文语言文件中三技能描述的物理伤害倍率，由 180% 调整为 260%

---

- Refactored damage calculation to internal additive stacking via new chongyue_damage module
- Replaced multiplicative logic with additive damage bonuses using SourceModifierList
- Updated Skill 2 AOE attack logic to work with the new additive damage system
- Corrected Skill 3 physical damage multiplier from 180% to 260% in Chinese and English locale files

## v2.0.5 (2026-08-07)

- Added English language support, updated UI text language options | 添加英文语言支持，更新界面文本语言选项

本项目的所有重要变更。

## v2.0.4 (2026-07-28)

- Added publish scripts with version bump and dependency check support | 新增发布脚本，支持版本升级与依赖检查
- Optimized language processing and fixed MergePOFile parameter configuration | 优化语言处理，修复 MergePOFile 参数设置
