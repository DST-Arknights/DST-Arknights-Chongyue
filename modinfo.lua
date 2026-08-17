-- 这是本人制作的第一个mod，见谅。
-- 如果没有翻译，就别动这个文件。

--连一刻都没有为xiaotianzihan的离场感到悲伤。
--接下来到场的是
--宇宙超级无敌可爱猫猫 O (✿◡ω◡) o
--和 它的仆从  ( ;°Д °;)




-- 对不支持的语言兜底到英文（DST 原版 ChooseTranslationTable 只回退到 tbl[1]，
-- 但我们用字典键值而非数字索引，非 en/zh 语言会返回 nil 导致崩溃）
local function T(tbl)
    return ChooseTranslationTable(tbl) or tbl["en"]
end

name = T({
    zh = "重岳",
    en = "Chongyue",
})
-- 版本更新说明（由发布脚本自动维护，请勿手动编辑）
local UPDATE_EN = [[
v2.1.0 (2026-08-18)
- Refactored damage calculation to internal additive stacking via new chongyue_damage module
- Replaced multiplicative logic with additive damage bonuses using SourceModifierList
- Updated Skill 2 AOE attack logic to work with the new additive damage system
- Corrected Skill 3 physical damage multiplier from 180% to 260% in Chinese and English locale files
---
v2.0.5 (2026-08-07)
- Added English language support, updated UI text language options
]]

local UPDATE_ZH = [[
v2.1.0 (2026-08-18)
- 重构伤害计算逻辑为内部加算，新增 chongyue_damage 模块
- 使用 SourceModifierList 创建伤害加成加法器，替代原有乘算逻辑
- 更新二技能 AOE 攻击等逻辑以适应新的伤害加成方式
- 修正中英文语言文件中三技能描述的物理伤害倍率，由 180% 调整为 260%
---
v2.0.5 (2026-08-07)
- 添加英文语言支持，更新界面文本语言选项
]]

description = T({
    zh = [[留舰人员年、夕、令的兄长
与炎国兵部、司岁台等政府部门往来密切
此前担任移动城市玉门的武术教官
已卸任

]] .. UPDATE_ZH,
    en = [[The elder brother of the year, evening, and order of the ship's personnel
He has close contact with government departments such as the Ministry of War and the Sui Tai of the Flame Country
He previously served as a martial arts instructor for the mobile city Yumen
He has retired

]] .. UPDATE_EN,
})
author = T({
    zh = "美工：xiaotianzihan 码师：夜雪 花菜 望月心灵",
    en = "Artist: xiaotianzihan Coder: 夜雪 花菜 望月心灵",
})
version = "2.1.0" -- 版本号


forumthread = ""

-- 过期判定
api_version = 10

-- 兼容
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true

icon_atlas = "chongyuemodicon.xml"
icon = "chongyuemodicon.tex"

--添加设置标题栏
local function AddTitle(title)
    return {
        name = "",
        label = title,
        options = { { description = "", data = 0 } },
        default = 0,
        tags = {},
    }
end
configuration_options = {
    {
        name = "language",
        label = T({
            zh = "界面文本语言",
            en = "Text Language",
        }),
        hover = T({
            zh = "选择模组界面文本的语言 (Auto 跟随游戏语言)",
            en = "Choose the mod's UI text language (Auto follows game language)",
        }),
        options = {
            {
                description = T({
                    zh = "自动 (跟随游戏)",
                    en = "Auto (follow game)",
                }),
                data = "auto"
            },
            {
                description = T({
                    zh = "简体中文",
                    en = "Simplified Chinese",
                }),
                data = "zh"
            },
            {
                description = T({
                    zh = "英文",
                    en = "English",
                }),
                data = "en"
            },
        },
        default = "auto"
    },
    AddTitle(T({
        zh = "语音设置",
        en = "Voice Settings",
    })),
    {
        name = "chongyue_skill_sound_type",
        label = T({
            zh = "语音类型",
            en = "Voice Type",
        }),
        options = {
            {
                description = T({
                    zh = "普通话",
                    en = "Mandarin",
                }),
                data = "mandarin"
            },
            {
                description = T({
                    zh = "方言",
                    en = "Dialect",
                }),
                data = "dialect"
            },
            {
                description = T({
                    zh = "日语",
                    en = "Japanese",
                }),
                data = "japanese"
            },
        },
        default = "mandarin"
    },

}
mod_dependencies = {
    {["DST-ArknightsItemPackage"] = false},
}
