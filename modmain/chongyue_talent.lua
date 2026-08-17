local function OnTalent1Install(talent)
  local inst = talent.inst

  function talent:MarkTarget(target)
    if not talent:IsActivating() then return end
    local params = talent:GetLevelParams()
    target:AddTag("an_end_to_war_marked")
    if not target._end_to_war_fx then
      local fx = SpawnPrefab("chongyue_talent1_fx")
      fx.entity:SetParent(target.entity)
      local fxSymbol = AddAliveFx(target, fx)
      target._end_to_war_fx = fxSymbol
    end
    if target._end_to_war_remove_task then
      target._end_to_war_remove_task:Cancel()
    end
    target._end_to_war_remove_task = target:DoTaskInTime(params.markDuration, function()
      target:RemoveTag("an_end_to_war_marked")
      if target._end_to_war_fx then
        RemoveAliveFx(target, target._end_to_war_fx)
        target._end_to_war_fx = nil
      end
      target._end_to_war_remove_task = nil
    end)
  end

  function talent:IsMarkedTarget(target)
    return target:HasTag("an_end_to_war_marked")
  end
  talent:ListenForEventWhileActivating("onhitother", function(inst, data)
    if not data or not data.target then return end
    local params = talent:GetLevelParams()
    if math.random() < params.probability then
      talent:MarkTarget(data.target)
    end
  end)

  -- 天赋1 的伤害倍率并入内部加法器: 按目标是否标记, 在每次伤害结算前写入/移除加成
  local function RefreshTalent1DamageBonus(target)
    local adder = GetChongyueDamageAdder(inst)
    if target and talent:IsMarkedTarget(target) then
      adder:SetModifier(talent, talent:GetLevelParams().damageMultiplier - 1)
    else
      adder:RemoveModifier(talent)
    end
  end
  talent:HookFunctionWhileActivating(inst.components.combat, "CalcDamage",
    function(next, self, target, weapon, multiplier)
      RefreshTalent1DamageBonus(target)
      return next(self, target, weapon, multiplier)
    end)
  -- 天赋锁定时清掉加法器里的天赋加成(由配置接口 OnDeactivate 处理)
end

local function OnTalent2Install(talent)
  local inst = talent.inst
  local KEEP_SKILL_COUNT_TIME = 0.2
  local COUNT_RESET_TIME = 0.2
  local killCountSymbol = Symbol("all_are_guests_kill_count")
  local killTaskSymbol = Symbol("all_are_guests_kill_task")
  inst[killCountSymbol] = 0
  talent:ListenForEventWhileActivating("killed", function (inst, data)
    local ark_skill_comp = inst.components.ark_skill
    if not ark_skill_comp then return end
    local needCount = false
    local skills = ark_skill_comp:GetAllSkills()
    for _, skill in ipairs(skills) do
      if skill:IsActivating() or ((GetTime() - (skill:GetLastDeactivateTime() or 999)) < KEEP_SKILL_COUNT_TIME) then
        needCount = true
        break
      end
    end
    if needCount then
      inst[killCountSymbol] = inst[killCountSymbol] + 1
    else
      inst[killCountSymbol] = 0
      return
    end
    if inst[killTaskSymbol] then return end
    inst[killTaskSymbol] = inst:DoTaskInTime(COUNT_RESET_TIME, function()
      local params = talent:GetLevelParams()
      if inst[killCountSymbol] >= 1 then
        for _, skill in ipairs(skills) do
          skill:AddEnergyProgress(params.skillEnergy)
        end
      end
      inst[killTaskSymbol] = nil
      inst[killCountSymbol] = 0
    end)
  end)
  function talent:RefreshTalent2AttackSpeedMultiplier()
    local key = "chongyue_talent2_attack_speed"
    if IsUnarmed(inst) then
      local params = talent:GetLevelParams()
      inst.components.combat.attackspeedmodifiers:SetModifier(inst, params.unarmedAttackSpeedMultiplier, key)
    else
      inst.components.combat.attackspeedmodifiers:SetModifier(inst, 1, key)
    end
  end
  talent:ListenForEventWhileActivating("equip", function()
    talent:RefreshTalent2AttackSpeedMultiplier()
  end)
  talent:ListenForEventWhileActivating("unequip", function()
    talent:RefreshTalent2AttackSpeedMultiplier()
  end)
end

local function OnTalent2Activate(talent)
  talent:RefreshTalent2AttackSpeedMultiplier()
end

local function OnTalent2Deactivate(talent)
  talent:RefreshTalent2AttackSpeedMultiplier()
end

RegisterArkTalent({
  id        = "chongyue_talent1",
  atlas     = "images/chongyue_skill.xml",
  image     = "skill1.tex",
  name      = STRINGS.UI.ARK_TALENT.NAMES.CHONGYUE[1],
  levels    = {
    {
      desc = STRINGS.UI.ARK_TALENT.LEVEL_DESC.CHONGYUE[1][1],
      params = {
        damageMultiplier = 1.45,
        probability = 0.18,
        -- 标记持续时间
        markDuration = 2.5,
      },
    },
    {
      desc = STRINGS.UI.ARK_TALENT.LEVEL_DESC.CHONGYUE[1][2],
      params = {
        damageMultiplier = 1.55,
        probability = 0.18,
        -- 标记持续时间
        markDuration = 2.5,
      },
    },
  },
  OnInstall = OnTalent1Install,
  OnDeactivate = function(talent)
    GetChongyueDamageAdder(talent.inst):RemoveModifier(talent)
  end,
})

RegisterArkTalent({
  id        = "chongyue_talent2",
  atlas     = "images/chongyue_skill.xml",
  image     = "skill2.tex",
  name      = STRINGS.UI.ARK_TALENT.NAMES.CHONGYUE[2],
  levels    = {
    {
      desc = STRINGS.UI.ARK_TALENT.LEVEL_DESC.CHONGYUE[2][1],
      params = {
        -- 击杀恢复技力
        skillEnergy = 2,
        -- 空手攻速加成
        unarmedAttackSpeedMultiplier = 1.4,
      },
    },
  },
  OnInstall = OnTalent2Install,
  OnActivate = OnTalent2Activate,
  OnDeactivate = OnTalent2Deactivate,
})