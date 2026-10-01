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
v2.2.1 (2026-10-01)
- No user-visible changes.
---
v2.2.0 (2026-09-11)
- Refactored voice registration logic, removed legacy voice files, and updated the voice paths
- Removed the chongyue_actions module import from modmain
- Migrated the changelog to a grouped Chinese-then-English format (Chinese first, English after)
- Cleaned up AI CLI diagnostic log entries that had been mixed into the changelog
]]

local UPDATE_ZH = [[
v2.2.1 (2026-10-01)
- 无用户可见改动。
---
v2.2.0 (2026-09-11)
- 重构语音注册逻辑，移除旧语音文件并更新语音路径
- 移除 modmain 中的 chongyue_actions 模块导入
- changelog 迁移为中英分组格式（中文在前，英文在后）
- 清理 changelog 中混入的 AI CLI 诊断日志表
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
version = "2.2.1" -- 版本号


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
