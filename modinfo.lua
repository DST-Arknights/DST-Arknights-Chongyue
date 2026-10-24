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
version = "2.2.2" -- 版本号

-- 版本更新说明（由发布脚本自动维护，请勿手动编辑）
local UPDATE_EN = [[
v2.2.2 (2026-10-24)
- QZBS now recharges 1 point at a time; each positive recovery costs at least 1 supply, with no recharge when under 1 supply remains or when QZBS is full; skill-first charging and QZBS loss-pause behavior are preserved.
- Fixed a spawn crash for Chongyue with Nexus 2.12.1; QZBS supply charging now runs after the default skill handler and consumes only remaining supply.
- The current version is now shown in both mod descriptions.
- Migrated the dependency to Arknights Nexus.
---
v2.2.1 (2026-10-01)
- No user-visible changes.
]]

local UPDATE_ZH = [[
v2.2.2 (2026-10-24)
- QZBS 现在每次只充能 1 点；每次有效恢复至少消耗 1 点 supply，supply 不足 1 点或 QZBS 已满时不充能且不消耗；保留技能优先与 QZBS 损失暂停行为。
- 修复 Chongyue 在 Nexus 2.12.1 下生成时崩溃的问题；QZBS 的 supply 充能现在排在默认技能处理器之后，仅消耗剩余 supply。
- 两个模组描述中均显示当前版本号。
- 依赖迁移至 Arknights Nexus。
---
v2.2.1 (2026-10-01)
- 无用户可见改动。
]]

description = T({
    zh = [[留舰人员年、夕、令的兄长
与炎国兵部、司岁台等政府部门往来密切
此前担任移动城市玉门的武术教官
已卸任

当前版本: ]] .. version .. "\n" .. UPDATE_ZH,
    en = [[The elder brother of the year, evening, and order of the ship's personnel
He has close contact with government departments such as the Ministry of War and the Sui Tai of the Flame Country
He previously served as a martial arts instructor for the mobile city Yumen
He has retired

Current version: ]] .. version .. "\n" .. UPDATE_EN,
})
author = T({
    zh = "美工：xiaotianzihan 码师：夜雪 花菜 望月心灵",
    en = "Artist: xiaotianzihan Coder: 夜雪 花菜 望月心灵",
})


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
    {["DST-Arknights-Nexus"] = false},
}
