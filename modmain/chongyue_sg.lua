local function NextPunchAttackAnim(inst)
  local attackLoopAnim = {
    "chongyue_punch_attack_a",
    "chongyue_punch_attack_b",
  }
  if not inst._chongyue_punchattack_anim_index then
    inst._chongyue_punchattack_anim_index = 1
  else
    inst._chongyue_punchattack_anim_index = (inst._chongyue_punchattack_anim_index % #attackLoopAnim) + 1
  end
  return attackLoopAnim[inst._chongyue_punchattack_anim_index]
end

local function IsSkillActivating(inst, skill_name)
  local skill = inst.components.ark_skill and inst.components.ark_skill:GetSkill(skill_name) or nil
  if skill then
    return skill:IsActivating()
  end
  if inst.replica.ark_skill then
    return inst.replica.ark_skill:IsActivating(skill_name)
  end
  return false
end

AddStategraphPostInit("wilson", function(sg)
  local OldAttackOnEnter = sg.states["attack"].onenter
  sg.states["attack"].onenter = function(inst, ...)
    OldAttackOnEnter(inst, ...)
    if inst:HasTag("chongyue_punch_attack") and IsSGPunchAttack(inst) then
      local punchAttackAnim = "punch"
      if IsSkillActivating(inst, "chongyue_skill3") then
        punchAttackAnim = "chongyue_skill_3_loop_a"
      elseif IsSkillActivating(inst, "chongyue_skill1") then
        punchAttackAnim = "chongyue_skill_1"
      else
        punchAttackAnim = NextPunchAttackAnim(inst)
      end
      inst.AnimState:PlayAnimation(punchAttackAnim, false)
    end
  end
end)

AddStategraphPostInit("wilson_client", function(sg)
  local OldAttackOnEnter = sg.states["attack"].onenter
  sg.states["attack"].onenter = function(inst, ...)
    OldAttackOnEnter(inst, ...)
    if inst:HasTag("chongyue_punch_attack") and IsSGPunchAttack(inst) then
      local punchAttackAnim = "punch"
      if IsSkillActivating(inst, "chongyue_skill3") then
        punchAttackAnim = "chongyue_skill_3_loop_a"
      elseif IsSkillActivating(inst, "chongyue_skill1") then
        punchAttackAnim = "chongyue_skill_1"
      else
        punchAttackAnim = NextPunchAttackAnim(inst)
      end
      inst.AnimState:PlayAnimation(punchAttackAnim, false)
    end
  end
end)

local AOE_MUST_TAGS = { "_combat" }
local AOE_CANT_TAGS = { "INLIMBO", "wall", "companion", "DECOR", "invisible", "notarget", "noattack", "playerghost",
  "player" }

local function ChongyueSkill2AoeAttack(inst, range, validFn, damageBonus)
  local x, y, z = inst.Transform:GetWorldPosition()
  local targets = TheSim:FindEntities(x, y, z, range, AOE_MUST_TAGS, AOE_CANT_TAGS)
  local weapon = inst.components.combat:GetWeapon()
  local validTargets = {}
  local adder = GetChongyueDamageAdder(inst)
  for i, ent in ipairs(targets) do
    if inst.replica.combat:IsValidTarget(ent) and (not validFn or validFn(ent)) then
      table.insert(validTargets, ent)
      -- 技能2 的 AOE 加成(倍率-1)并入内部加法器, 与天赋加成加算
      local targetBonus = FunctionOrValue(damageBonus, ent) or 0
      adder:SetModifier("chongyue_skill2_aoe", targetBonus)
      local dmg, spdmg = inst.components.combat:CalcDamage(ent, weapon, inst.components.combat.areahitdamagepercent)
      adder:RemoveModifier("chongyue_skill2_aoe")
      inst:PushEvent("onareaattackother", { target = ent, weapon = weapon, stimuli = nil })
      ent.components.combat:GetAttacked(inst, dmg, weapon, nil, spdmg)
    end
  end
  return validTargets
end

-- 技能2 抬手: 命中所有目标并触发止戈(标记); 只有触发时已有止戈标记的目标才浮空.
-- 不造成伤害, 伤害统一在放手段一次性结算. 返回触发前已标记的目标(供放手段额外 480% 结算)
local function ChongyueSkill2MarkAndFloat(inst, range)
  local x, y, z = inst.Transform:GetWorldPosition()
  local targets = TheSim:FindEntities(x, y, z, range, AOE_MUST_TAGS, AOE_CANT_TAGS)
  local markedEntities = {}
  local talent1 = inst.components.ark_talent and inst.components.ark_talent:GetTalent("chongyue_talent1")
  local hasTalent1 = talent1 and talent1:IsActivating()
  for i, ent in ipairs(targets) do
    if inst.replica.combat:IsValidTarget(ent) then
      if hasTalent1 then
        -- 触发前已有止戈标记的目标: 记录并浮空
        if talent1:IsMarkedTarget(ent) then
          table.insert(markedEntities, ent)
          ApplyControl(ent, "chongyue_skill2_levitate", 0.5)
        end
        -- 命中的敌人必定触发止戈(标记), 供后续结算
        talent1:MarkTarget(ent)
      end
    end
  end
  return markedEntities
end

local chongyue_skill2 = State({
  name = "chongyue_skill2",
  tags = { "notalking", "nopredict", "nomorph", "doing", "busy", "nointerrupt" },

  onenter = function(inst)
    local skill = inst.components.ark_skill and inst.components.ark_skill:GetSkill("chongyue_skill2")
    if not skill or not IsUnarmed(inst) then
      inst.sg:GoToState("idle")
      return
    end
    local params = skill:GetLevelParams()
    inst.sg.statemem.params = params
    inst.components.locomotor:Stop()
    inst.Physics:Stop()
    inst.components.grue:AddImmunity("chongyue_skill2")
    inst.components.talker:IgnoreAll("chongyue_skill2")
    inst.components.playercontroller:EnableMapControls(false)
    inst.components.playercontroller:Enable(false)
    inst.components.health:SetInvincible(true)
    --inst.AnimState:PlayAnimation("emoteXL_waving4")  --播放的动画，暂时先用..
    inst.AnimState:PlayAnimation("chongyue_skill_2_begin")
    inst.sg:SetTimeout(1.5) --1.5秒后超时
  end,
  timeline = {
    TimeEvent(15 * FRAMES, function(inst)
      local params = inst.sg.statemem.params
      local x, y, z = inst.Transform:GetWorldPosition()
      inst.SoundEmitter:PlaySound("cy_music/se2/skill2")
      local fx1 = SpawnPrefab("firering_fx")
      fx1.Transform:SetPosition(x, y + 4, z)
      local fx2 = SpawnPrefab("chongyue_skill2_fx_up")
      fx2.Transform:SetPosition(x, y, z)
      -- 抬手: 上挑命中, 只有已有止戈标记的目标浮空; 命中目标全部打标记(供后续结算), 不造成伤害
      inst.sg.statemem.skill2MarkedEntities = ChongyueSkill2MarkAndFloat(inst, params.aoeRange)
    end),
    TimeEvent(30 * FRAMES, function(inst)
      inst.AnimState:PlayAnimation("chongyue_skill_2_end")
      local params = inst.sg.statemem.params
      local x, y, z = inst.Transform:GetWorldPosition()
      local fx1 = SpawnPrefab("firering_fx")
      fx1.Transform:SetPosition(x, y, z)
      local fx2 = SpawnPrefab("chongyue_skill2_fx_down")
      fx2.Transform:SetPosition(x, y, z)
      -- 放手: 一次性结算. 所有目标吃 AOE; 触发前已有止戈标记的目标额外吃 480%
      local markedEntities = inst.sg.statemem.skill2MarkedEntities or {}
      local targets = ChongyueSkill2AoeAttack(inst, params.aoeRange, nil, function(ent)
        local bonus = params.aoeDamageMultiplier - 1
        if table.contains(markedEntities, ent) then
          bonus = bonus + (params.talentDamageMultiplier - 1)
        end
        return bonus
      end)
      -- 技能1 充能只喂给本次下砸: 结算后消耗, 不再被后续连携/普攻白嫖
      local skill1 = inst.components.ark_skill and inst.components.ark_skill:GetSkill("chongyue_skill1")
      if skill1 and skill1:IsActivating() then
        skill1:CutBullet()
      end
      -- 额外触发三技能效果
      local skill3 = inst.components.ark_skill and inst.components.ark_skill:GetSkill("chongyue_skill3")
      if skill3 then
        if skill3:IsAutoActivated() then
          skill3:TryActivate()
        end
        if skill3:IsActivating() then
          for i, ent in ipairs(targets) do
            skill3:DoSkillAreaAttack(ent:GetPosition())
          end
        end
      end
    end),
  },

  ontimeout = function(inst)
    inst.sg:GoToState("idle", true)
  end,
  onexit = function(inst)
    inst.components.grue:RemoveImmunity("chongyue_skill2")
    inst.components.talker:StopIgnoringAll("chongyue_skill2")
    inst.components.playercontroller:EnableMapControls(true)
    inst.components.playercontroller:Enable(true)
    inst.components.health:SetInvincible(false)
  end,
})
AddStategraphState("wilson", chongyue_skill2)
