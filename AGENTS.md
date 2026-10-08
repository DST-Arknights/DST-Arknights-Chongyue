# 重岳项目协作约定

## 共享规范与依赖

- 通用的 DST Lua、Prefab、状态图、客户端/主机分层、国际化、资源处理、发布和验证规范，统一遵循共享项目 `DST-Arknights-AICoding` 中与任务匹配的 skill；本文件只补充重岳项目特有约定。
- 本项目依赖 `DST-Arknights-Nexus`（源枢）。源枢的位置从记忆中查找；记忆不明确时先询问用户。保持 `modinfo.lua` 的依赖键和源枢提供的运行时 API 契约，不在本项目复制源枢实现。

## 入口与玩法范围

- `modmain.lua` 负责 Prefab、语言、语音、配置和模块注册；`scripts/init.lua` 负责脚本侧入口初始化。
- `modmain/chongyue_tuning.lua`、`chongyue_talent.lua`、`chongyue_skill.lua`、`chongyue_sg.lua`、`chongyue_damage.lua`、`chongyue_recipes.lua` 和 `chongyue_ui.lua` 分别承载数值、天赋、技能、状态图、伤害、配方和 UI。
- `scripts/components/chongyue_qzbs.lua` 与 `chongyue_qzbs_replica.lua` 是重岳 QZBS 系统的主从端组件；修改同步字段或接口时必须同时检查两端。
- `scripts/prefabs/`、`scripts/widgets/`、`scripts/speech_chongyue.lua` 和 `languages/` 分别维护角色/特效 Prefab、UI、语音台词和双语文本。

## 资源与文案约定

- 运行时资源位于 `anim/`、`images/`、`sound/` 和 `bigportraits/`；可编辑图片来源优先使用 `imageSource/`，不要只改生成后的图集。
- `languages/chongyue_chinese_s.po`、`chongyue_english.po` 与 `chongyue_voice.lua` 必须保持角色、技能、天赋和配置文案的中英文对应。
- 资源注册、Prefab 名、图集名、动画 bank/build 名和语音事件名必须与脚本中的实际引用一致。
- `tools/publish.ps1` 仅保留本项目的发布入口；通用发布参数和验证步骤遵循 `DST-Arknights-AICoding` 的 skill。

## 项目专属检查

- 调整技能、天赋或 QZBS 时，检查主从端组件、状态图、UI、配方注册和双语 PO 是否同步。
- 调整语音或资源时，确认来源文件、运行时文件和脚本注册仍对应；静态检查不足以代替按共享 skill 规定的目标验证。