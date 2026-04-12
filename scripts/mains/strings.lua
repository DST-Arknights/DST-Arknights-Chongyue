-- 角色选择界面
STRINGS.CHARACTER_TITLES.chongyue = "重岳"
STRINGS.CHARACTER_NAMES.chongyue = "朔"
STRINGS.CHARACTER_DESCRIPTIONS.chongyue = "*千招百式在一息\n*再去练练吧"
STRINGS.CHARACTER_QUOTES.chongyue = "千招百式在一息"
STRINGS.CHARACTER_SURVIVABILITY.chongyue = "无我"

-- 自定义语音字符串
--STRINGS.CHARACTERS.CHONGYUE = require "speech_chongyue"

-- 游戏中的名字 
STRINGS.NAMES.CHONGYUE = "重岳"

STRINGS.CHARACTERS.CHONGYUE = require "speech_chongyue"  --角色语言
-- 被检查时，他人的默认响应
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CHONGYUE = 
{
	GENERIC = "宗师",
	ATTACKER = "我觉得这不理智",
	MURDERER = "为何!",
	REVIVER = "谢谢。",
	GHOST = "龙哥就是龙！",
}

local wb = {
    i11_jy1 = {'精英化一阶', '可以提升至精英化一阶'},
    i11_jy2 = {'精英化二阶', '可以提升至精英化二阶'},
    cy_portablesupply = {'便携补给站', '一个可以随身携带的补给站'},
    cy_portablesupply_item = {'便携补给站', '一个可以随身携带的补给站'},
}
for a,b in pairs(wb) do
    STRINGS.NAMES[string.upper(a)] = b[1]
    STRINGS.RECIPE_DESC[string.upper(a)]= b[2] or b[3] or b[1]
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(a)] =b[3] or b[2] or '这是'..b[1]..'！'
end