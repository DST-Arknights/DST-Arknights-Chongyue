local ARK_CONSTANTS = require("ark_constants")

RegisterControlDefinition("chongyue_skill2_levitate", {
  duration = 2,
  onApply = function (inst)
    local pos = inst:GetPosition()
    if inst.Physics then
        inst.Physics:Teleport(pos.x, 2, pos.z)
    else
        inst.Transform:SetPosition(pos.x, 2, pos.z)
    end
  end,
  onRemove = function (inst)
    local pos = inst:GetPosition()
    if inst.Physics then
        inst.Physics:Teleport(pos.x, 0, pos.z)
    else
        inst.Transform:SetPosition(pos.x, 0, pos.z)
    end
  end
})

local function SayActivateVoice(inst)
  -- 1-4随机
  local random = math.random(1, 4)
  local key = "CHONGYUE_SKILL_ACTIVATE_" .. random
  SayAndVoice(inst, key, { talk = false })
end

local SKILL3_LIGHT_MAX_STACKS = 5

local function GenSkillHitRecoveryEnergyListener(skill)
  local HitSymbol = Symbol(skill.id .. "_hit")
  return function(inst, data)
    if not data or not data.target then return end
    if skill:IsActivating() then return end
    if inst[HitSymbol] then return end
    inst[HitSymbol] = inst:DoTaskInTime(0, function() inst[HitSymbol] = nil end)
    skill:AddEnergyProgress(1)
  end
end

local Skill1CutBulletTaskSymbol = Symbol("chongyue_skill1_cut_bullet_task")
local function OnSkill1HitOther(inst, data)
  if not data or not data.target then return end
  local skill = inst.components.ark_skill and inst.components.ark_skill:GetSkill("chongyue_skill1") or nil
  if not skill then return end
  if not skill:IsActivating() then return end
  if not IsUnarmed(inst) then return end
  local fxCount = skill._currentActiveCostStacks
  for i = 1, fxCount do
    local target = data.target
    local fx = SpawnPrefab("chongyue_skill1_hit_fx")
    local x, y, z = target.Transform:GetWorldPosition()
    x = x + math.random() - 0.5
    y = y + math.random() + .5
    z = z + math.random() - .5
    fx.Transform:SetPosition(x, y, z)
  end
  if inst[Skill1CutBulletTaskSymbol] then return end
  inst[Skill1CutBulletTaskSymbol] = inst:DoTaskInTime(0, function()
    inst[Skill1CutBulletTaskSymbol] = nil
    skill:CutBullet()
  end)
end

-- 技能1 空手普攻的伤害倍率写入内部加法器(与天赋/AOE 加算)
-- 含充能层数: bonus = 倍率×充能层数-1, 保证技能1 单独普攻伤害不变(倍率×层数),
-- 同时让二/三技能触发时也能携带三倍充能的伤害(充能不再只通过 DoAttack 的 instancemult 生效)
local function RefreshSkill1DamageBonus(skill)
  local inst = skill.inst
  local adder = GetChongyueDamageAdder(inst)
  if skill:IsActivating() and IsUnarmed(inst) then
    local stacks = skill._currentActiveCostStacks or 1
    adder:SetModifier(skill, skill:GetLevelParams().damageMultiplier * stacks - 1)
  else
    adder:RemoveModifier(skill)
  end
end

local function OnSkill1Install(skill)
  skill._currentActiveCostStacks = 1
  skill:ListenForEvent("onhitother", GenSkillHitRecoveryEnergyListener(skill))
  skill:ListenForEventWhileActivating("onhitother", OnSkill1HitOther)
  -- 充能层数已并入加法器加成, 不再通过 DoAttack 的 instancemult 单独乘算
  -- 激活/结束/装备切换/读档恢复时刷新加法器加成
  skill:SetOnActivateEffect(function() RefreshSkill1DamageBonus(skill) end)
  skill:SetOnDeactivate(function() RefreshSkill1DamageBonus(skill) end)
  skill:ListenForEventWhileActivating("equip", function() RefreshSkill1DamageBonus(skill) end)
  skill:ListenForEventWhileActivating("unequip", function() RefreshSkill1DamageBonus(skill) end)
end

local function OnSkill1Activate(skill)
  local maxActivationStacks = skill:GetLevelConfig().maxActivationStacks
  if skill.data.activationStacks >= maxActivationStacks - 1 then
    skill.data.activationStacks = 0
    -- 修改了skill.data.activationStacks, 需要手动同步状态
    skill:SyncStatus()
    skill._currentActiveCostStacks = maxActivationStacks
  else
    skill._currentActiveCostStacks = 1
  end
  skill.inst.SoundEmitter:PlaySound("cy_music/se2/skill1")
  SayActivateVoice(skill.inst)
end

local function OnSkill2Install(skill)
  skill:ListenForEvent("onhitother", GenSkillHitRecoveryEnergyListener(skill))
end

local function OnSkill2Activate(skill)
  skill.inst.SoundEmitter:PlaySound("cy_music/se2/skill1")
  SayActivateVoice(skill.inst)
  skill.inst.sg:GoToState("chongyue_skill2")
end

local function OnSkill2ActivateTest(skill)
  if not IsUnarmed(skill.inst) then
    return false, 'CHONGYUE_SKILL2_ACTIVATE_TEST_UNARMED_ONLY'
  end
  return true
end

local AOE_MUST_TAGS = { "_combat" }
local AOE_CANT_TAGS = { "INLIMBO", "wall", "companion", "DECOR", "invisible", "notarget", "noattack", "playerghost",
  "player" }
local function SetupSkill3Interface(skill)
  local inst = skill.inst
  skill:SetState("lightStack", 0)
  function skill:ShouldAutoActivated()
    return skill:GetActivateCount() >= SKILL3_LIGHT_MAX_STACKS
  end

  function skill:IsAutoActivated()
    return skill._auto_activated
  end

  function skill:SetAutoActivated(autoActivated)
    skill._auto_activated = autoActivated
  end

  function skill:SetSkill3AttackRangeVisible(value)
    if skill.inst.player_classified and skill.inst.player_classified._chongyue_skill3_attack_range then
      skill.inst.player_classified._chongyue_skill3_attack_range:set(value)
    end
  end

  function skill:EnableAutoAttackRange()
    if skill._auto_attack_range_applied then
      return
    end
    local params = skill:GetLevelParams()
    if inst.components.combat then
      local deltaRange = params.normalAttackRange - inst.components.combat.attackrange
      local deltaHitRange = (params.normalAttackRange + 1) - inst.components.combat.hitrange
      ArkLogger:Debug("chongyue", "Enabling auto attack range, delta", deltaRange, "new range", params.normalAttackRange)
      inst.components.combat.attackrangeaddmodifiers:SetModifier("chongyue_skill3", deltaRange)
      inst.components.combat.hitrangeaddmodifiers:SetModifier("chongyue_skill3", deltaHitRange)
    end
    self:SetSkill3AttackRangeVisible(params.normalAttackRange)
    skill._auto_attack_range_applied = true
  end

  function skill:DisableAutoAttackRange()
    if skill._auto_attack_range_applied then
      ArkLogger:Debug("chongyue", "Disabling auto attack range")
      if inst.components.combat then
        inst.components.combat.attackrangeaddmodifiers:RemoveModifier("chongyue_skill3")
        inst.components.combat.hitrangeaddmodifiers:RemoveModifier("chongyue_skill3")
      end
    end
    self:SetSkill3AttackRangeVisible(0)
    skill._auto_attack_range_applied = false
  end

  function skill:RefreshAutoAttackRangeByWeaponState()
    if skill:IsAutoActivated() and IsUnarmed(inst) then
      self:EnableAutoAttackRange()
    else
      -- 无论是否持武器, 只要不是空手激活状态就恢复原始攻击距离
      self:DisableAutoAttackRange()
    end
  end

  function skill:TryUnlockAutoActivate()
    if not skill:IsAutoActivated() and self:ShouldAutoActivated() then
      skill:SetAutoActivated(true)
      skill:PatchConfig({ activationMode = ARK_CONSTANTS.ACTIVATION_MODE.AUTO })
      self:RefreshAutoAttackRangeByWeaponState()
    end
  end

  function skill:AddLightStack()
    skill:SetState("lightStack", math.min(skill:GetState("lightStack") + 1, SKILL3_LIGHT_MAX_STACKS))
    self:KeepLightStackMoment()
    self:UpdateLightStack()
  end

  -- 保持一会灯光
  function skill:KeepLightStackMoment()
    skill.markedTimeForLight = GetTime()
  end

  function skill:UpdateLightStack()
    local lightStack = skill:GetState("lightStack")
    if lightStack == 0 then
      skill.lightFx.Light:Enable(false)
    else
      local intensity = math.min(0.1 + 0.05 * (lightStack - 1), 0.99)
      local radius = 2 + lightStack - 1
      ArkLogger:Debug("chongyue", "Updating skill3 light stack", lightStack, "intensity", intensity, "radius",
        radius)
      skill.lightFx.Light:SetRadius(radius)
      skill.lightFx.Light:SetIntensity(intensity)
      skill.lightFx.Light:Enable(true)
    end
    for i = 1, SKILL3_LIGHT_MAX_STACKS do
      if lightStack >= i then
        if not self.stackFxs[i] then
          local fx = SpawnPrefab("chongyue_skill3_stacks_fx_" .. i)
          local x, y, z = skill.inst.Transform:GetWorldPosition()
          fx.entity:SetParent(skill.inst.entity)
          fx.Transform:SetPosition(x, y, z)
          self.stackFxs[i] = fx
        end
      else
        if self.stackFxs[i] then
          self.stackFxs[i]:Remove()
          self.stackFxs[i] = nil
        end
      end
    end
  end

  function skill:DoSkillAreaAttack(pos, excludeEnt)
    local params = skill:GetLevelParams()
    local targets = TheSim:FindEntities(pos.x, pos.y, pos.z, params.aoeRange, AOE_MUST_TAGS, AOE_CANT_TAGS)
    local weapon = inst.components.combat:GetWeapon()
    local adder = GetChongyueDamageAdder(inst)
    for i, ent in ipairs(targets) do
      -- 下次攻击场景: 主目标由普攻承担 2.6 倍伤害, AOE 只覆盖周围, 避免重复命中
      if ent ~= excludeEnt and inst.replica.combat:IsValidTarget(ent) then
        -- 技能3 的 AOE 加成并入内部加法器, 与天赋加成加算
        adder:SetModifier("chongyue_skill3_aoe", params.aoeDamageMultiplier - 1)
        local dmg, spdmg = inst.components.combat:CalcDamage(ent, weapon, inst.components.combat.areahitdamagepercent)
        adder:RemoveModifier("chongyue_skill3_aoe")
        ent.components.combat:GetAttacked(inst, dmg, weapon, nil, spdmg)
      end
    end
    local fx = SpawnPrefab("chongyue_skill3_hit_fx")
    fx.Transform:SetPosition(pos.x, pos.y + 1, pos.z)
  end
end

local Skill3CutBulletTaskSymbol = Symbol("chongyue_skill3_cut_bullet_task")
local function OnSkill3HitOther(inst, data)
  local target = data and data.target or nil
  if not target then return end
  if not IsUnarmed(inst) then return end
  local skill = inst.components.ark_skill:GetSkill("chongyue_skill3")
  if not skill then return end
  if inst[Skill3CutBulletTaskSymbol] then return end
  -- 允许一帧内重复触发. 事件延时帧保证不会连锁反应
  inst[Skill3CutBulletTaskSymbol] = inst:DoTaskInTime(0, function()
    inst[Skill3CutBulletTaskSymbol] = nil
    skill:CutBullet()
  end)
end

local function OnSkill3Install(skill)
  local inst = skill.inst
  skill.lightFx = inst:SpawnChild("firefx_light")
  skill.lightFx.Light:SetFalloff(.45)
  skill.lightFx.Light:SetColour(169 / 255, 231 / 255, 245 / 255)
  skill.lightFx.Light:Enable(false)
  skill.stackFxs = {}
  SetupSkill3Interface(skill)
  skill:ListenForEvent("onhitother", GenSkillHitRecoveryEnergyListener(skill))
  skill:ListenForEventWhileActivating("onhitother", OnSkill3HitOther)
  skill:ListenForEvent("equip", function()
    skill:RefreshAutoAttackRangeByWeaponState()
  end)
  skill:ListenForEvent("unequip", function()
    skill:RefreshAutoAttackRangeByWeaponState()
  end)
  skill:HookFunction(inst.components.combat, "DoAttack",
    function(next, self, target, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
      if not target then
        return next(self, target, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
      end
      if skill:IsAutoActivated() and IsUnarmed(inst) then
        skill:TryActivate()
        -- 自动触发的情况下, 0.5秒后追加一次攻击
        for i = 1, skill:GetLevelParams().additionalAttack do
          inst:DoTaskInTime(0.5 + 0.5 * (i - 1), function()
            if target:IsValid() and inst.replica.combat:IsValidTarget(target) then
              next(self, target, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
            end
          end)
        end
      end
      if skill:IsActivating() and IsUnarmed(inst) then
        -- 下次攻击: 主目标的普攻合并进 AOE, 主目标与周围都造成 aoeDamageMultiplier(2.6) 倍伤害
        skill:DoSkillAreaAttack(target:GetPosition(), target)
        skill:CutBullet()
        local adder = GetChongyueDamageAdder(inst)
        adder:SetModifier("chongyue_skill3_next", skill:GetLevelParams().aoeDamageMultiplier - 1)
        next(self, target, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
        adder:RemoveModifier("chongyue_skill3_next")
        return
      end
      next(self, target, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
    end)
  -- 自动激活后持续时间内未攻击则减少层数
  skill:KeepLightStackMoment()
  skill:ListenForEvent("onhitother", function() skill:KeepLightStackMoment() end)
  skill:ListenForEvent("attacked", function() skill:KeepLightStackMoment() end)
  skill.lightPeriodicTask = inst:DoPeriodicTask(1, function()
    local params = skill:GetLevelParams()
    if GetTime() - skill.markedTimeForLight > params.outOfCombatKeepLightStackMomentDuration then
      skill:SetState("lightStack", math.max(0, skill:GetState("lightStack") - 1))
      skill:UpdateLightStack()
      skill:KeepLightStackMoment()
    end
  end)
end

local function OnSkill3Remove(skill)
  if skill._soundTask then
    skill._soundTask:Cancel()
    skill._soundTask = nil
  end
  if skill.lightFx then
    skill.lightFx:Remove()
    skill.lightFx = nil
  end
  if skill.lightPeriodicTask then
    skill.lightPeriodicTask:Cancel()
    skill.lightPeriodicTask = nil
  end

  for _, fx in pairs(skill.stackFxs) do
    if fx then
      fx:Remove()
    end
  end
  -- 攻击距离恢复
  if skill._auto_activated then
    skill:DisableAutoAttackRange()
  end
end

local function OnSkill3Activate(skill)
  SayActivateVoice(skill.inst)
  skill:AddLightStack()
  local inst = skill.inst
  -- sound task
  inst.SoundEmitter:PlaySound("cy_music/se2/skill3")
end

local function OnSkill3Deactivate(skill)
  skill:TryUnlockAutoActivate()
end

local function OnSkill3Load(skill, data)
  skill:UpdateLightStack()
  skill:TryUnlockAutoActivate()
  skill:RefreshAutoAttackRangeByWeaponState()
end

local skillConfig = { {
  id = 'chongyue_skill1',
  name = STRINGS.UI.ARK_SKILL.NAMES.CHONGYUE[1],
  lockedDesc = STRINGS.UI.ARK_SKILL.LOCKED_DESC.CHONGYUE[1],
  atlas = "images/chongyue_skill.xml",
  image = "skill1.tex",
  recipe_image = "skill1_recipe.tex",
  hotkey = KEY_Z,
  energyRecoveryMode = ARK_CONSTANTS.ENERGY_RECOVERY_MODE.ATTACK,
  activationMode = ARK_CONSTANTS.ACTIVATION_MODE.MANUAL,
  OnInstall = OnSkill1Install,
  OnActivate = OnSkill1Activate,
  levels = { {
    desc = STRINGS.UI.ARK_SKILL.LEVEL_DESC.CHONGYUE[1][1],
    activationEnergy = 6,
    maxActivationStacks = 3,
    bulletCount = 1,
    params = {
      damageMultiplier = 2,
    }
  }, {
    desc = STRINGS.UI.ARK_SKILL.LEVEL_DESC.CHONGYUE[1][2],
    activationEnergy = 6,
    maxActivationStacks = 3,
    bulletCount = 1,
    params = {
      damageMultiplier = 3,
    }
  }, {
    desc = STRINGS.UI.ARK_SKILL.LEVEL_DESC.CHONGYUE[1][3],
    activationEnergy = 6,
    maxActivationStacks = 3,
    bulletCount = 1,
    params = {
      damageMultiplier = 4,
    }
  } }
}, {
  id = 'chongyue_skill2',
  name = STRINGS.UI.ARK_SKILL.NAMES.CHONGYUE[2],
  lockedDesc = STRINGS.UI.ARK_SKILL.LOCKED_DESC.CHONGYUE[2],
  atlas = "images/chongyue_skill.xml",
  image = "skill2.tex",
  recipe_image = "skill2_recipe.tex",
  hotkey = KEY_X,
  energyRecoveryMode = ARK_CONSTANTS.ENERGY_RECOVERY_MODE.ATTACK,
  activationMode = ARK_CONSTANTS.ACTIVATION_MODE.MANUAL,
  OnInstall = OnSkill2Install,
  OnActivate = OnSkill2Activate,
  ActivateTest = OnSkill2ActivateTest,
  levels = { {
    desc = STRINGS.UI.ARK_SKILL.LEVEL_DESC.CHONGYUE[2][1],
    activationEnergy = 12,
    maxActivationStacks = 1,
    params = {
      aoeDamageMultiplier = 3.5,
      talentDamageMultiplier = 4.8,
      aoeRange = 8,
      maxTargets = 4,
    }
  }, {
    desc = STRINGS.UI.ARK_SKILL.LEVEL_DESC.CHONGYUE[2][2],
    activationEnergy = 11,
    maxActivationStacks = 1,
    params = {
      aoeDamageMultiplier = 4.5,
      talentDamageMultiplier = 6.5,
      aoeRange = 8,
      maxTargets = 4,
    }
  } }
}, {
  id = 'chongyue_skill3',
  name = STRINGS.UI.ARK_SKILL.NAMES.CHONGYUE[3],
  lockedDesc = STRINGS.UI.ARK_SKILL.LOCKED_DESC.CHONGYUE[3],
  atlas = "images/chongyue_skill.xml",
  image = "skill3.tex",
  recipe_image = "skill3_recipe.tex",
  hotkey = KEY_C,
  energyRecoveryMode = ARK_CONSTANTS.ENERGY_RECOVERY_MODE.ATTACK,
  activationMode = ARK_CONSTANTS.ACTIVATION_MODE.MANUAL,
  OnInstall = OnSkill3Install,
  OnRemove = OnSkill3Remove,
  OnActivate = OnSkill3Activate,
  OnDeactivate = OnSkill3Deactivate,
  OnLoad = OnSkill3Load,
  levels = { {
    desc = STRINGS.UI.ARK_SKILL.LEVEL_DESC.CHONGYUE[3][1],
    activationEnergy = 30,
    buffDuration = 20,
    bulletCount = 1,
    params = {
      aoeDamageMultiplier = 2.6,
      -- 多重攻击次数
      additionalAttack = 1,
      aoeRange = 2.5,
      -- 层数持续时间
      lightDuration = 15,
      -- 脱战后持续时间
      outOfCombatKeepLightStackMomentDuration = 15,
      -- 攻击距离延长
      normalAttackRange = 7.5,
    }
  } }
} }

for _, skill in ipairs(skillConfig) do
  RegisterArkSkill(skill)
end

-- 3技能的攻击范围显示
AddPrefabPostInit("player_classified", function(inst)
  inst._chongyue_skill3_attack_range = net_float(inst.GUID, "chongyue_skill3_attack_range",
    "chongyue_skill3_attack_range_dirty")
  inst:ListenForEvent("chongyue_skill3_attack_range_dirty", function()
    local value = inst._chongyue_skill3_attack_range:value()
    if inst._parent then
      if value <= 0 then
        if inst._chongyue_skill3_attack_range_fx then
          inst._chongyue_skill3_attack_range_fx:Remove()
          inst._chongyue_skill3_attack_range_fx = nil
        end
        return
      end
      if not inst._chongyue_skill3_attack_range_fx then
        inst._chongyue_skill3_attack_range_fx = SpawnPrefab("reticuleaoecatapultwakeup")
        inst._chongyue_skill3_attack_range_fx.Transform:SetNoFaced()
        inst._chongyue_skill3_attack_range_fx.entity:SetParent(inst._parent.entity)
        inst._chongyue_skill3_attack_range_fx.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
      end
      -- 基准大小16
      inst._chongyue_skill3_attack_range_fx.AnimState:SetScale(value / 10, value / 10)
    end
    -- WARN: 这里本来应该继续做AttachClassified双向劫持保证数据同步的, 但这里时差不太会导致问题, 就先这样了
  end)
end)
