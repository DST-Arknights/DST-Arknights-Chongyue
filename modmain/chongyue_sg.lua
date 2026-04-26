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

local function ChongyueSkill2AoeAttack(inst, range, validFn, damageMultiplier)
  local x, y, z = inst.Transform:GetWorldPosition()
  local targets = TheSim:FindEntities(x, y, z, range, AOE_MUST_TAGS, AOE_CANT_TAGS)
  local weapon = inst.components.combat:GetWeapon()
  local validTargets = {}
  for i, ent in ipairs(targets) do
    if inst.replica.combat:IsValidTarget(ent) and (not validFn or validFn(ent)) then
      table.insert(validTargets, ent)
      local targetDamageMultiplier = FunctionOrValue(damageMultiplier, ent)
      local dmg, spdmg = inst.components.combat:CalcDamage(ent, weapon, inst.components.combat.areahitdamagepercent)
      dmg = dmg * (targetDamageMultiplier or 1)
      inst:PushEvent("onareaattackother", { target = ent, weapon = weapon, stimuli = nil })
      ent.components.combat:GetAttacked(inst, dmg, weapon, nil, spdmg)
    end
  end
  return validTargets
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
      local targets = ChongyueSkill2AoeAttack(inst, params.aoeRange, nil, params.aoeDamageMultiplier / 2) -- 两段伤害所以减半
      local talent1MarkedEntities = {}
      inst.sg.statemem.talent1MarkedEntities = talent1MarkedEntities
      -- 查找天赋, 浮空
      local talent1 = inst.components.ark_talent and inst.components.ark_talent:GetTalent("chongyue_talent1")
      if talent1 and talent1:IsActivating() then
        for i, ent in ipairs(targets) do
          if inst.replica.combat:IsValidTarget(ent) then
            if talent1:IsMarkedTarget(ent) then
              table.insert(talent1MarkedEntities, ent)
              ApplyControl(ent, "chongyue_skill2_levitate", 0.5)
            end
            talent1:MarkTarget(ent)
          end
        end
      end
    end),
    TimeEvent(30 * FRAMES, function(inst)
      inst.AnimState:PlayAnimation("chongyue_skill_2_end")
      local params = inst.sg.statemem.params
      local talent1MarkedEntities = inst.sg.statemem.talent1MarkedEntities
      local x, y, z = inst.Transform:GetWorldPosition()
      local fx1 = SpawnPrefab("firering_fx")
      fx1.Transform:SetPosition(x, y, z)
      local fx2 = SpawnPrefab("chongyue_skill2_fx_down")
      fx2.Transform:SetPosition(x, y, z)
      -- 第二段伤害
      local targets = ChongyueSkill2AoeAttack(inst, params.aoeRange, nil, function(ent)
        local damageMultiplier = params.aoeDamageMultiplier / 2
        if table.contains(talent1MarkedEntities, ent) then
          damageMultiplier = damageMultiplier + params.talentDamageMultiplier
        end
        return damageMultiplier
      end) -- 两段伤害所以减半, 已标记目标将额外伤害并入本次结算
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
      -- if skill1 and skill1:IsActivating() then
      --   skill1:CutBullet()
      -- end
      -- if skill3 and skill3:IsActivating() then
      --   skill3:CutBullet()
      -- end
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
