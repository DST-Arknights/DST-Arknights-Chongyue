

-- Your character's stats
TUNING.CHONGYUE_HEALTH = 100
TUNING.CHONGYUE_HUNGER = 150
TUNING.CHONGYUE_SANITY = 140

-- 初始携带物品
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.CHONGYUE = {

}

--初始百式值
TUNING.CHONGYUE = {}
TUNING.CHONGYUE.BS_start = 60
TUNING.CHONGYUE.BSMAX_start = 80
TUNING.CHONGYUE.BSMAX_J2 = 100
--移动速度倍率
TUNING.CHONGYUE.SPEED = 1.2

--额外减少阈值
TUNING.CHONGYUE.NOGOOD_min = 0.2
TUNING.CHONGYUE.NOGOOD_max = 0.95
--减少倍率
TUNING.CHONGYUE.NOGOOD_spd = 1.5

--便携补给站影响范围
TUNING.CHONGYUE.SUPPLY_RANGE = 6
--便携补给站回复千招百式基础倍率
TUNING.CHONGYUE.QZBSAURA = 1
--便携补给站回复千招百式每级燃料附赠倍率
TUNING.CHONGYUE.QZBSAURA_FULED = 0.25

--精英化数值
TUNING.CHONGYUE.J1_sanity = 160
TUNING.CHONGYUE.J2_sanity = 200

TUNING.CHONGYUE.J2_hp = 150

TUNING.CHONGYUE.AS = 1.0
TUNING.CHONGYUE.J2_AS = 1.5

--止戈触发概率
TUNING.CHONGYUE.ZGran = 0.18
--持续时间
TUNING.CHONGYUE.ZGtime = 2.5

--我无aoe范围半径
TUNING.CHONGYUE.AsR2  =  7.5
TUNING.CHONGYUE.WWAOEr = 3
TUNING.CHONGYUE.WWCT = 15   --多长时间不攻击会掉一层

--冲盈按键
TUNING.CHONGYUE.S1key = GetModConfigData("chongyue_chongying_key")
--浮尘按键
TUNING.CHONGYUE.S2key = GetModConfigData("chongyue_fuchen_key")
--我无按键
TUNING.CHONGYUE.S3key = GetModConfigData("chongyue_wuwo_key")

TUNING.CHONGYUE.startlv = GetModConfigData("chongyue_startlv")

--音效大小
TUNING.CHONGYUE.SEval = 1
--语音大小
TUNING.CHONGYUE.SAval = 1
--语音冷却
TUNING.CHONGYUE.SAcd = GetModConfigData("chongyue_skill_sound_cd")
--语音类型
TUNING.CHONGYUE.SAtype = tonumber(GetModConfigData("chongyue_skill_sound_type")) or 1

    --来自泥岩的位置表
local mudrock_skill_badge_position_list = {
    {1, 1, {200, -150, 0}}, 
    {1, 0, {200, 0, 0}}, 
    {1, 2, {200, 150, 0}}, 
    {0, 2, {-200, 150, 0}}, 
    {0, 0, {-200, 0, 0}},
    {0, 1, {-200, -150, 0}}, 
    {2, 1, {-600, -150, 0}}, 
    {2, 0, {-500, 0, 0}}, 
    {2, 2, {-500, 150, 0}}}       
TUNING.CHONGYUE.skill_badge_position = mudrock_skill_badge_position_list[GetModConfigData("chongyue_skill_badge_position")]

