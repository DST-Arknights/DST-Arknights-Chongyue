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
    en = "The elder brother of the year, evening, and order of the ship's personnel\nHe has close contact with government departments such as the Ministry of War and the Sui Tai of the Flame Country\nHe previously served as a martial arts instructor for the mobile city Yumen\nHe has retired",
})
author = ChooseTranslationTable({
    zh = "美工：xiaotianzihan 码师：夜雪 花菜 望月心灵",
    en = "Artist: xiaotianzihan Coder: 夜雪 花菜 望月心灵",
})
version = "1.9.4" -- 版本号


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
        options = {{description = "", data = 0}},
        default = 0,
		tags = {},
    }
end
local keylist = {
    {description="Minus", data = 45},
    {description="Alt", data = 400},
    {description="Ctrl", data = 401},
    {description="Shift", data = 402},
    {description="Slash", data = 47},
    {description="LeftBracket", data = 91},
    {description="BackSlash", data = 92},
    {description="RightBracket", data = 93},
    {description="Tilde", data = 96},
    {description="A", data = 97},
    {description="B", data = 98},
    {description="C", data = 99},
    {description="D", data = 100},
    {description="E", data = 101},
    {description="F", data = 102},
    {description="G", data = 103},
    {description="H", data = 104},
    {description="I", data = 105},
    {description="J", data = 106},
    {description="K", data = 107},
    {description="L", data = 108},
    {description="M", data = 109},
    {description="N", data = 110},
    {description="O", data = 111},
    {description="P", data = 112},
    {description="Q", data = 113},
    {description="R", data = 114},
    {description="S", data = 115},
    {description="T", data = 116},
    {description="U", data = 117},
    {description="V", data = 118},
    {description="W", data = 119},
    {description="X", data = 120},
    {description="Y", data = 121},
    {description="Z", data = 122},
    {description="F1", data = 282},
    {description="F2", data = 283},
    {description="F3", data = 284},
    {description="F4", data = 285},
    {description="F5", data = 286},
    {description="F6", data = 287},
    {description="F7", data = 288},
    {description="F8", data = 289},
    {description="F9", data = 290},
    {description="F10", data = 291},
    {description="F11", data = 292},
    {description="F12", data = 293},

    {description="Up", data = 273},
    {description="Down", data = 274},
    {description="Right", data = 275},
    {description="Left", data = 276},
    {description="PageUp", data = 280},
    {description="PageDown", data = 281},

    {description="0", data = 48},
    {description="1", data = 49},
    {description="2", data = 50},
    {description="3", data = 51},
    {description="4", data = 52},
    {description="5", data = 53},
    {description="6", data = 54},
    {description="7", data = 55},
    {description="8", data = 56},
    {description="9", data = 57},
}

configuration_options = {
    AddTitle(ChooseTranslationTable({
        zh = "语音设置",
        en = "Voice Settings",
    })),
    {
        name = "chongyue_skill_sound_cd",
        label = ChooseTranslationTable({
            zh = "语音间隔",
            en = "Voice Interval",
        }),
        options = {
            {description = ChooseTranslationTable({
                zh = "5秒",
                en = "5 seconds",
            }), data = 5},
            {description = ChooseTranslationTable({
                zh = "2秒",
                en = "2 seconds",
            }), data = 2},
            {description = ChooseTranslationTable({
                zh = "1秒",
                en = "1 second",
            }), data = 1},
            {description = ChooseTranslationTable({
                zh = "无间隔",
                en = "No interval",
            }), data = 0},
 
        },
        default = 0
    },
    {
        name = "chongyue_skill_sound_type",
        label = ChooseTranslationTable({
            zh = "语音类型",
            en = "Voice Type",
        }),
        options = {
            {description = ChooseTranslationTable({
                zh = "普通话",
                en = "Mandarin",
            }), data = 1},
            {description = ChooseTranslationTable({
                zh = "方言",
                en = "Dialect",
            }), data = 2},
            {description = ChooseTranslationTable({
                zh = "日语",
                en = "Japanese",
            }), data = 3},
        },
        default = 1
    },

}
mod_dependencies = {
    -- { workshop = "workshop-3677284770"},
    {["DST-ArknightsItemPackage"] = false},
}