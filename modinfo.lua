-- 这是本人制作的第一个mod，见谅。
-- 如果没有翻译，就别动这个文件。

--连一刻都没有为xiaotianzihan的离场感到悲伤。
--接下来到场的是
--宇宙超级无敌可爱猫猫 O (✿◡ω◡) o
--和 它的仆从  ( ;°Д °;)




name = ChooseTranslationTable({
    zh = "重岳",
    en = "Chongyue",
})
description = ChooseTranslationTable({
    zh = "留舰人员年、夕、令的兄长\n与炎国兵部、司岁台等政府部门往来密切\n此前担任移动城市玉门的武术教官\n已卸任",
    en =
    "The elder brother of the year, evening, and order of the ship's personnel\nHe has close contact with government departments such as the Ministry of War and the Sui Tai of the Flame Country\nHe previously served as a martial arts instructor for the mobile city Yumen\nHe has retired",
})
author = ChooseTranslationTable({
    zh = "美工：xiaotianzihan 码师：夜雪 花菜 望月心灵",
    en = "Artist: xiaotianzihan Coder: 夜雪 花菜 望月心灵",
})
version = "2.0.1" -- 版本号


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
    AddTitle(ChooseTranslationTable({
        zh = "语音设置",
        en = "Voice Settings",
    })),
    {
        name = "chongyue_skill_sound_type",
        label = ChooseTranslationTable({
            zh = "语音类型",
            en = "Voice Type",
        }),
        options = {
            {
                description = ChooseTranslationTable({
                    zh = "普通话",
                    en = "Mandarin",
                }),
                data = "mandarin"
            },
            {
                description = ChooseTranslationTable({
                    zh = "方言",
                    en = "Dialect",
                }),
                data = "dialect"
            },
            {
                description = ChooseTranslationTable({
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
    -- { workshop = "workshop-3677284770"},
    { ["DST-ArknightsItemPackage"] = false },
}
