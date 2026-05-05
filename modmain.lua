--一键GLOBAL，其他地方就不用写了
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
--ww
PrefabFiles = {
  "chongyue",
  "chongyue_none",
  "chongyue_fx",
}
--动画，资料引入
Assets = {
  Asset("ATLAS", "images/saveslot_portraits/chongyue.xml"),

  Asset("ATLAS", "images/selectscreen_portraits/chongyue.xml"),

  Asset("ATLAS", "images/selectscreen_portraits/chongyue_silho.xml"),

  Asset("ATLAS", "bigportraits/chongyue.xml"),

  Asset("ATLAS", "images/avatars/avatar_chongyue.xml"),

  Asset("ATLAS", "images/avatars/avatar_ghost_chongyue.xml"),

  Asset("ATLAS", "images/avatars/self_inspect_chongyue.xml"),

  Asset("ATLAS", "images/names_chongyue.xml"),

  Asset("ATLAS", "bigportraits/chongyue_none.xml"),

  Asset("SOUNDPACKAGE", "sound/cy_music.fev"),
  Asset("SOUND", "sound/cy_music.fsb"),

  Asset("ANIM", "anim/cyhud.zip"),

  Asset("ATLAS", "images/chongyue_skill.xml"),
}

AddMinimapAtlas("images/map_icons/chongyue.xml") --人物小地图显示

AddReplicableComponent("chongyue_qzbs")

modimport("modmain/chongyue_tuning")

ArkLogger:DeclareLogger('DEBUG', 'chongyue')
MergePOFile("languages/chongyue_chinese_s.po", "zh", true)

AddModCharacter("chongyue", "MALE") --人物性别定义

modimport("modmain/chongyue_actions.lua")
modimport("modmain/chongyue_sg.lua")
modimport("modmain/chongyue_ui.lua")
modimport("modmain/chongyue_recipes.lua")
modimport("modmain/chongyue_skill.lua")
modimport("modmain/chongyue_talent.lua")

DefineNetState("chongyue_qzbs", {
  max = "float:classified",
  current = "float:classified",
})

local voice = require("/chongyue_voice")
RegisterVoice("chongyue", voice)

