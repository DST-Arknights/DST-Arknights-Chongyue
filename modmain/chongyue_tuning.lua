-- Your character's stats
TUNING.CHONGYUE_HEALTH                          = 100
TUNING.CHONGYUE_HUNGER                          = 150
TUNING.CHONGYUE_SANITY                          = 140

-- 初始携带物品
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.CHONGYUE = {

}
--初始百式值
TUNING.CHONGYUE                                 = {}
--移动速度倍率
TUNING.CHONGYUE.SPEED                           = 1.2
TUNING.CHONGYUE.NOGOOD_MAX                      = 0.95
TUNING.CHONGYUE.NOGOOD_MIN                      = 0.2

TUNING.CHONGYUE_ELITE                           = { {
  MAX_HEALTH_MODIFIED = 0,
  MAX_SANITY_MODIFIED = 0,
}, {
  MAX_HEALTH_MODIFIED = 0,
  MAX_SANITY_MODIFIED = 20,
}, {
  MAX_HEALTH_MODIFIED = 50,
  MAX_SANITY_MODIFIED = 60,
}
}

TUNING.CHONGYUE.VOICE_LANG = GetModConfigData("chongyue_skill_sound_type")