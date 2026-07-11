local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
  Asset("ANIM", "anim/chongyue.zip"),
  Asset("ANIM", "anim/player_chongyue.zip"),
  Asset("ANIM", "anim/ghost_chongyue_build.zip"),
  Asset("ANIM", "anim/ghost_chongyue.zip"),
  Asset("ATLAS", "images/map_icons/chongyue.xml"),
}

local CURRENT_MIGRATION_VERSION = 1

local function InstallDefaultSKills(inst)
  inst.components.ark_skill:AddSkill("chongyue_skill1")
  inst.components.ark_skill:AddSkill("chongyue_skill2")
  inst.components.ark_skill:AddSkill("chongyue_skill3")
  inst.components.ark_talent:AddTalent("chongyue_talent1")
  inst.components.ark_talent:AddTalent("chongyue_talent2")
end

local function onbecamehuman(inst, data)
  inst.components.chongyue_qzbs:SetCurrent(50)
end

local function onbecameghost(inst)
  --死亡后会失去所有百式
  if inst.components.chongyue_qzbs ~= nil then
    inst.components.chongyue_qzbs:SetCurrent(0)
  end
end

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
  start_inv[string.lower(k)] = v.CHONGYUE
end
local prefabs = FlattenTree(start_inv, true)
local function OnLoad(inst, data)
  inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
  inst:ListenForEvent("ms_becameghost", onbecameghost)

  if inst:HasTag("playerghost") then
    onbecameghost(inst)
  else
    onbecamehuman(inst)
  end
  -- 小于等1版本的安装技能
  if data == nil or data.current_migration_version == nil or data.current_migration_version < 1 then
    InstallDefaultSKills(inst)
  end
end

local function OnApplyQzbs(inst, current)
  -- 工具效率
  local workBonus = (75 + current) / 100
  inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, workBonus, inst)
  inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE, workBonus, inst)
  inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, workBonus, inst)
  -- 防御
  local defBonus = math.floor((current - 60) / 2) / 100
  inst.components.health.externalabsorbmodifiers:SetModifier(inst, defBonus, 'chongyue_qzbs')
  -- 伤害
  inst.components.combat.defaultdamageaddmodifiers:SetModifier(inst, current, 'chongyue_qzbs')
end

local function OnHungerDelta(inst, data)
  if not inst.components.chongyue_qzbs or data == nil then return end
  if data.newpercent > TUNING.CHONGYUE.NOGOOD_MAX or data.newpercent < TUNING.CHONGYUE.NOGOOD_MIN then
    inst.components.chongyue_qzbs:SetLossRate(1.5)
  else
    inst.components.chongyue_qzbs:SetLossRate(1)
  end
end

local function OnApplyElite(inst, elite)
  if inst.components.chongyue_qzbs then
    local max = 60 + (elite - 1) * 20
    inst.components.chongyue_qzbs:SetMax(max)
  end
  local maxHealthModified = TUNING.CHONGYUE_ELITE[elite] and TUNING.CHONGYUE_ELITE[elite].MAX_HEALTH_MODIFIED or 0
  inst.components.health.maxhealthaddmodifiers:SetModifier(inst, maxHealthModified, 'chongyue_elite_health')
  local maxSanityModified = TUNING.CHONGYUE_ELITE[elite] and TUNING.CHONGYUE_ELITE[elite].MAX_SANITY_MODIFIED or 0
  local sanityPercent = inst.components.sanity:GetPercent()
  inst.components.sanity:SetMax(TUNING.CHONGYUE_SANITY + maxSanityModified)
  inst.components.sanity:SetPercent(sanityPercent)
end

local hitOtherSymbol = Symbol("chongyue_hit_other")
local function OnHitOther(inst, data)
  if not inst.components.chongyue_qzbs then return end
  if not data or not data.target then return end
  if inst[hitOtherSymbol] then return end
  inst[hitOtherSymbol] = inst:DoTaskInTime(0, function() inst[hitOtherSymbol] = nil end)
  local current = inst.components.chongyue_qzbs.current
  local delta = (-(current * current) / 1000) + (current / 10)
  delta = math.max(delta, 1)
  inst.components.chongyue_qzbs:DoDelta(delta)
end

local function GetQzbsRechargeAmount(inst, charger, data)
  if not inst.components.chongyue_qzbs then
    return 0
  end
  return inst.components.chongyue_qzbs:GetRechargeAmount()
end

local function RechargeQzbs(inst, charger, amount, data)
  if not inst.components.chongyue_qzbs then
    return 0
  end
  return inst.components.chongyue_qzbs:Recharge(amount)
end

local function OnSave(inst, data)
  data.current_migration_version = CURRENT_MIGRATION_VERSION
end

local function OnNewSpawn(inst) --玩家初次降临时
  OnLoad(inst)
  InstallDefaultSKills(inst)
end
----
local CommonPostInit = function(inst)
  -- Minimap icon
  inst.MiniMapEntity:SetIcon("chongyue.tex")
  inst:AddTag("chongyue_qzbs")
  inst:AddTag("chongyue")
  inst:AddTag("chongyue_punch_attack")
  inst:AddTag("ark_character")
end
-- server only
local MasterPostInit = function(inst)
  inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

  inst.soundsname = "wilson"

  inst:AddTag("cy_ksl")

  inst.components.health:SetMaxHealth(TUNING.CHONGYUE_HEALTH)
  inst.components.hunger:SetMax(TUNING.CHONGYUE_HUNGER)
  inst.components.sanity:SetMax(TUNING.CHONGYUE_SANITY)

  inst.components.talker.colour = { x = 197 / 255, y = 153 / 255, z = 81 / 255 }

  inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
  inst.components.locomotor:SetExternalSpeedMultiplier(inst, "chongyue_speed", TUNING.CHONGYUE.SPEED)

  inst:AddComponent("ark_elite")
  inst.components.ark_elite:SetRarity(6)
  inst.components.ark_elite:SetOnApplyElite(OnApplyElite)
  inst:AddComponent("ark_skill")
  inst.components.ark_skill:DeclareBuiltin("chongyue_skill1", {
    requiredElite = 1,
    eliteLevelMap = { [1] = 1, [2] = 2, [3] = 3 }
  })
  inst.components.ark_skill:DeclareBuiltin("chongyue_skill2", {
    requiredElite = 2,
    eliteLevelMap = { [2] = 1, [3] = 2 }
  })
  inst.components.ark_skill:DeclareBuiltin("chongyue_skill3", {
    requiredElite = 3,
    eliteLevelMap = { [3] = 1 }
  })
  inst:AddComponent("ark_talent")
  inst.components.ark_talent:DeclareBuiltin("chongyue_talent1", {
    requiredElite = 2,
    eliteLevelMap = { [2] = 1, [3] = 2 },
  })
  inst.components.ark_talent:DeclareBuiltin("chongyue_talent2", {
    requiredElite = 3,
    eliteLevelMap = { [3] = 1 },
  })
  inst:AddComponent("i18n_talker")
  inst.components.i18n_talker:SetupVoice("chongyue")
  inst.components.i18n_talker:SetVoiceLang(TUNING.CHONGYUE.VOICE_LANG)
  inst:AddComponent("chongyue_qzbs")
  inst.components.chongyue_qzbs:SetOnCurrent(OnApplyQzbs)

  inst:AddComponent("ark_supply_rechargeable")
  inst.components.ark_supply_rechargeable:AddRechargeGroup("chongyue_qzbs", {
    getrechargeamountfn = GetQzbsRechargeAmount,
    rechargefn = RechargeQzbs,
  })

  inst:ListenForEvent("hungerdelta", OnHungerDelta)
  inst:ListenForEvent("onhitother", OnHitOther)

  inst.OnSave = OnSave
  inst.OnLoad = OnLoad
  inst.OnNewSpawn = OnNewSpawn
end
return MakePlayerCharacter("chongyue", prefabs, assets, CommonPostInit, MasterPostInit, prefabs)
