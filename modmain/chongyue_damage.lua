-- 重岳 技能与天赋 伤害倍率内部加算
-- 参考物品包 ark_buff.lua: 每实例内置一个"伤害加成加法器"(additive SourceModifierList),
-- 所有原本互乘的伤害倍率来源(技能1/2/3、天赋1)都 SetModifier 写入加成(倍率-1),
-- 加法器 dirty 回调把 1+总和 写入 externaldamagemultipliers, 同类型倍率内部加算后一次性乘入。
-- 加法器按 inst 懒创建, 各技能/天赋自包含维护自己的加成, 不依赖具体角色, 支持动态组装到任意角色。

local SourceModifierList = require("util/sourcemodifierlist")

local SYM_ADDER = Symbol("chongyue_damage_bonus_adder")

local function ApplyAdderToDamageMultiplier(inst, total)
  if inst.components.combat then
    inst.components.combat.externaldamagemultipliers:SetModifier("chongyue_damage_adder", 1 + total)
  end
end

-- 获取/创建该 inst 的伤害加成加法器
function GLOBAL.GetChongyueDamageAdder(inst)
  local adder = inst[SYM_ADDER]
  if not adder then
    adder = SourceModifierList(inst, 0, SourceModifierList.additive, ApplyAdderToDamageMultiplier)
    inst[SYM_ADDER] = adder
  end
  return adder
end
