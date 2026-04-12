
--以下是玩家被击飞的状态，目前貌似用不到

local upspd = 5     --升空速度
--有移动组件locomotor的才可以被击飞

local function DoMountSound(inst, mount, sound, ispredicted)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, ispredicted)
    end
end

local fc_fly_pre =  State{
    name = "fc_fly_pre",
    tags = { "flying", "notalking", "nopredict", "nomorph", "doing", "busy"},
    onenter = function(inst)
        if inst.Physics == nil then
            inst.sg:GoToState("idle",true) 
            return
        end
        
        inst.components.locomotor:Stop()

        local pos = Point(inst.Transform:GetWorldPosition())

        inst.Physics:SetMotorVel(0,upspd,0)     --向上推力

        inst.sg:SetTimeout(0.75)   --0.75秒后超市
    end,
    onupdate = function(inst)

    end,
    timeline = {
        TimeEvent(FRAMES*2, function(inst)  --第二帧判断一下，如果到了高度就取小力，防止连续击飞得过高
            local pos = Point(inst.Transform:GetWorldPosition())
            if pos.y > 2 then      --如果已经到达高度
                inst.Physics:Stop()
            end
        end), 
        },
    ontimeout = function(inst)  --超市后
        inst.sg:GoToState("fc_fly")    --下个状态
    end,
    onexit = function(inst)
        inst.Physics:Stop()
        inst.MiniMapEntity:SetEnabled(true)
    end,
}

local fc_fly_down = State {
    name = "fc_fly_down",
    tags = {"doing","notalking","busy", "flying", "nopredict", "nomorph", "nointerrupt"},
    onenter = function(inst)
        inst.Physics:Stop()
        inst.Physics:SetMotorVel(0,-upspd*2,0)
        
        inst.sg:SetTimeout(2)
    end,
    onupdate = function(inst)   --每帧判断，到地面就退出状态
        local tpos = Point(inst.Transform:GetWorldPosition())
        if tpos.y <= .05 then
            inst.Physics:Stop()
            inst.sg:GoToState("idle", true)
        end
    end,

    ontimeout = function(inst)  --超时也退出状态
        inst.sg:GoToState("idle", true)
    end,
    onexit = function(inst)
        inst.Physics:Stop()
    end
}


AddStategraphState("wilson",  fc_fly_pre)
AddStategraphState("wilson",  fc_fly_down)

local function ss1(inst)
    if inst.components.grue ~= nil then         --黑暗
        inst.components.grue:AddImmunity("cy_fc")
    end
    if inst.components.talker ~= nil then       --讲话
        inst.components.talker:IgnoreAll("cy_fc")
    end
    if inst.components.firebug ~= nil then      --着火
        inst.components.firebug:Disable()
    end
    if inst.components.playercontroller ~= nil then     --禁止操作
        inst.components.playercontroller:EnableMapControls(false)
        inst.components.playercontroller:Enable(false)
    end
    if inst.components.health then          --无敌
        inst.components.health:SetInvincible(true)
    end
end
local function sd1(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:RemoveImmunity("cy_fc")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:StopIgnoringAll("cy_fc")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Enable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:EnableMapControls(true)
        inst.components.playercontroller:Enable(true)
    end
    if inst.components.health then
        inst.components.health:SetInvincible(false)
    end
end
--拂尘技能施法状态
local cy_fc =  State{
    name = "cy_fc",
    tags = { "notalking", "nopredict", "nomorph", "doing", "busy", "nointerrupt"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.Physics:Stop()
        ss1(inst)
        --inst.AnimState:PlayAnimation("emoteXL_waving4")  --播放的动画，暂时先用..
        inst.AnimState:PlayAnimation("skill_2_begin")
        inst.AnimState:PushAnimation("skill_2_end",false)
        inst.sg:SetTimeout(0.6)   --0.6秒后超时
    end,
    ontimeout = function(inst) 
        inst.sg:GoToState("idle",true) 
    end,
    onexit = function(inst)
        sd1(inst) 
    end,
}
AddStategraphState("wilson",  cy_fc)

--重写攻击状态以实现攻速功能
local attack = State{
    name = "attack",
    tags = { "attack", "notalking", "abouttoattack", "autopredict" },

    onenter = function(inst)
        if inst.components.combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end
        if inst.sg.laststate == inst.sg.currentstate then
            inst.sg.statemem.chained = true
        end
        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        local cooldown = inst.components.combat.min_attack_period
        if inst.components.rider:IsRiding() then
            if equip ~= nil and (equip.components.projectile ~= nil or equip:HasTag("rangedweapon")) then
                inst.AnimState:PlayAnimation("player_atk_pre")
                inst.AnimState:PushAnimation("player_atk", false)

                if (equip.projectiledelay or 0) > 0 then
                    --V2C: Projectiles don't show in the initial delayed frames so that
                    --     when they do appear, they're already in front of the player.
                    --     Start the attack early to keep animation in sync.
                    inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
                    if inst.sg.statemem.projectiledelay > FRAMES then
                        inst.sg.statemem.projectilesound =
                            (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                            (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                            (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                            "dontstarve/wilson/attack_weapon"
                    elseif inst.sg.statemem.projectiledelay <= 0 then
                        inst.sg.statemem.projectiledelay = nil
                    end
                end
                if inst.sg.statemem.projectilesound == nil then
                    inst.SoundEmitter:PlaySound(
                        (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                        (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                        (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                        "dontstarve/wilson/attack_weapon",
                        nil, nil, true
                    )
                end
                cooldown = math.max(cooldown, 13 * FRAMES)
            else
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
                cooldown = math.max(cooldown, 16 * FRAMES)
            end
        elseif equip ~= nil and equip:HasTag("toolpunch") then

            -- **** ANIMATION WARNING ****
            -- **** ANIMATION WARNING ****
            -- **** ANIMATION WARNING ****

            --  THIS ANIMATION LAYERS THE LANTERN GLOW UNDER THE ARM IN THE UP POSITION SO CANNOT BE USED IN STANDARD LANTERN GLOW ANIMATIONS.

            inst.AnimState:PlayAnimation("toolpunch")
            inst.sg.statemem.istoolpunch = true
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, inst.sg.statemem.attackvol, true)
            cooldown = math.max(cooldown, 13 * FRAMES)
        elseif equip ~= nil and equip:HasTag("whip") then
            inst.AnimState:PlayAnimation("whip_pre")
            inst.AnimState:PushAnimation("whip", false)
            inst.sg.statemem.iswhip = true
            inst.SoundEmitter:PlaySound("dontstarve/common/whip_pre", nil, nil, true)
            cooldown = math.max(cooldown, 17 * FRAMES)
        elseif equip ~= nil and equip:HasTag("pocketwatch") then
            inst.AnimState:PlayAnimation(inst.sg.statemem.chained and "pocketwatch_atk_pre_2" or "pocketwatch_atk_pre" )
            inst.AnimState:PushAnimation("pocketwatch_atk", false)
            inst.sg.statemem.ispocketwatch = true
            cooldown = math.max(cooldown, 15 * FRAMES)
            if equip:HasTag("shadow_item") then
                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow", nil, nil, true)
                inst.AnimState:Show("pocketwatch_weapon_fx")
                inst.sg.statemem.ispocketwatch_fueled = true
            else
                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre", nil, nil, true)
                inst.AnimState:Hide("pocketwatch_weapon_fx")
            end
        elseif equip ~= nil and equip:HasTag("book") then
            inst.AnimState:PlayAnimation("attack_book")
            inst.sg.statemem.isbook = true
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
            cooldown = math.max(cooldown, 19 * FRAMES)
        elseif equip ~= nil and equip:HasTag("chop_attack") and inst:HasTag("woodcutter") then
            inst.AnimState:PlayAnimation(inst.AnimState:IsCurrentAnimation("woodie_chop_loop") and inst.AnimState:GetCurrentAnimationFrame() <= 7 and "woodie_chop_atk_pre" or "woodie_chop_pre")
            inst.AnimState:PushAnimation("woodie_chop_loop", false)
            inst.sg.statemem.ischop = true
            cooldown = math.max(cooldown, 11 * FRAMES)
        elseif equip ~= nil and equip:HasTag("jab") then
            inst.AnimState:PlayAnimation("spearjab_pre")
            inst.AnimState:PushAnimation("spearjab", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
            cooldown = math.max(cooldown, 21 * FRAMES)
        elseif equip ~= nil and equip.components.weapon ~= nil and not equip:HasTag("punch") then
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            if (equip.projectiledelay or 0) > 0 then
                --V2C: Projectiles don't show in the initial delayed frames so that
                --     when they do appear, they're already in front of the player.
                --     Start the attack early to keep animation in sync.
                inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
                if inst.sg.statemem.projectiledelay > FRAMES then
                    inst.sg.statemem.projectilesound =
                        (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                        (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                        (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                        "dontstarve/wilson/attack_weapon"
                elseif inst.sg.statemem.projectiledelay <= 0 then
                    inst.sg.statemem.projectiledelay = nil
                end
            end
            if inst.sg.statemem.projectilesound == nil then
                inst.SoundEmitter:PlaySound(
                    (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                    (equip:HasTag("shadow") and "dontstarve/wilson/attack_nightsword") or
                    (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                    (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                    "dontstarve/wilson/attack_weapon",
                    nil, nil, true
                )
            end
            cooldown = math.max(cooldown, 13 * FRAMES)
        elseif equip ~= nil and (equip:HasTag("light") or equip:HasTag("nopunch")) then
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
            cooldown = math.max(cooldown, 13 * FRAMES)
        elseif inst:HasTag("beaver") then
            inst.sg.statemem.isbeaver = true
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
            cooldown = math.max(cooldown, 13 * FRAMES)
        elseif inst:HasTag("weremoose") then
            inst.sg.statemem.ismoose = true
            if inst.AnimState:IsCurrentAnimation("punch_a") or inst.AnimState:IsCurrentAnimation("punch_c") then
                inst.AnimState:PlayAnimation("punch_b")
                if inst:HasTag("weremoosecombo") then
                    inst.sg:AddStateTag("nointerrupt")
                end
            elseif inst.AnimState:IsCurrentAnimation("punch_b") then
                if inst:HasTag("weremoosecombo") then
                    inst.sg.statemem.ismoosesmash = true
                    inst.sg:AddStateTag("nointerrupt")
                    inst.AnimState:PlayAnimation("moose_slam")
                    inst.SoundEmitter:PlaySound("meta2/woodie/weremoose_groundpound", nil, nil, true)
                else
                    inst.AnimState:PlayAnimation("punch_c")
                end
            else
                inst.AnimState:PlayAnimation("punch_a")
            end
            cooldown = math.max(cooldown, 15 * FRAMES)
        else    --这里是空手攻击
            local as = 1
            if inst:HasTag("cy_ksl") then
                local netas = inst.net_cy_ptas:value()
                if netas ~= nil then
                    as = 1 / netas
                end
            end
            
            if inst:HasTag("skill_ww") then
                inst.AnimState:PlayAnimation("skill_3_loop_a")
            elseif inst:HasTag("skill_cy") then
                inst.AnimState:PlayAnimation("skill_1")
            elseif inst:HasTag("cy_ksl") then
                if inst.cyptn then
                    inst.cyptn = false
                    inst.AnimState:PlayAnimation("attact_b")
                else
                    inst.cyptn = true
                    inst.AnimState:PlayAnimation("attact_a")
                end
            else
                inst.AnimState:PlayAnimation("punch")
            end
            
            inst.AnimState:SetDeltaTimeMultiplier(1)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
            --cooldown = math.max(cooldown, as * 24 * FRAMES)
            cooldown = as * 24 * FRAMES
        end

        inst.sg:SetTimeout(cooldown)

        if target ~= nil then
            inst.components.combat:BattleCry()
            if target:IsValid() then
                inst:FacePoint(target:GetPosition())
                inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
            end
        end
    end,

    onupdate = function(inst, dt)
        if (inst.sg.statemem.projectiledelay or 0) > 0 then
            inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
            if inst.sg.statemem.projectiledelay <= FRAMES then
                if inst.sg.statemem.projectilesound ~= nil then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.projectilesound, nil, nil, true)
                    inst.sg.statemem.projectilesound = nil
                end
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end
        end
    end, 

    timeline =
    {
        TimeEvent(5 * FRAMES, function(inst)
            if inst.sg.statemem.ismoose and not inst.sg.statemem.ismoosesmash then
                inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/punch", nil, nil, true)
            end
        end),
        TimeEvent(6 * FRAMES, function(inst)
            if inst.sg.statemem.isbeaver then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            elseif inst.sg.statemem.ischop then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
            end
        end),
        TimeEvent(7 * FRAMES, function(inst)
            if inst.sg.statemem.ismoose then
                if inst.sg.statemem.ismoosesmash then
                    inst:PushMooseSmashShake()
                    inst.sg:RemoveStateTag("nointerrupt")

                    local x, y, z = inst.Transform:GetWorldPosition()
                    local rot = inst.Transform:GetRotation()

                    --V2C: first frame is blank, so no need to worry about forcing instant facing update
                    local fx = SpawnPrefab("weremoose_smash_fx")
                    fx.Transform:SetPosition(x, 0, z)
                    fx.Transform:SetRotation(rot)
                    fx._owner:set(inst)

                    inst:ClearBufferedAction()
                    inst.components.combat.ignorehitrange = true
                    inst.components.combat:SetDefaultDamage(TUNING.SKILLS.WOODIE.MOOSE_SMASH_DAMAGE)
                    local dist = 1
                    local radius = 2
                    rot = rot * DEGREES
                    x = x + dist * math.cos(rot)
                    z = z - dist * math.sin(rot)
                    for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + 3, MOOSE_AOE_MUST_TAGS, MOOSE_AOE_CANT_TAGS)) do
                        if v ~= inst and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) then
                            local range = radius + v:GetPhysicsRadius(0)
                            local dsq = v:GetDistanceSqToPoint(x, y, z)
                            if dsq < range * range and
                                (	v == inst.sg.statemem.attacktarget or --would mean we force attacked if needed
                                    not inst:TargetForceAttackOnly(v)
                                ) and
                                inst.components.combat:CanTarget(v) and
                                not inst.components.combat:IsAlly(v)
                            then
                                if v.components.planarentity ~= nil then
                                    inst.components.planardamage:AddBonus(inst, TUNING.SKILLS.WOODIE.MOOSE_SMASH_PLANAR_DAMAGE, "weremoose_smash")
                                end
                                inst.components.combat:DoAttack(v)
                                inst.components.planardamage:RemoveBonus(inst, "weremoose_smash")
                            end
                        end
                    end
                    inst.components.combat:SetDefaultDamage(TUNING.WEREMOOSE_DAMAGE)
                    inst.components.combat.ignorehitrange = false
                else
                    inst:PerformBufferedAction()
                end
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),
        TimeEvent(8 * FRAMES, function(inst)
            if not (inst.sg.statemem.isbeaver or
                    inst.sg.statemem.ismoose or
                    inst.sg.statemem.iswhip or
                    inst.sg.statemem.ispocketwatch or
                    inst.sg.statemem.isbook) and
                inst.sg.statemem.projectiledelay == nil then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),
        TimeEvent(10 * FRAMES, function(inst)
            if inst.sg.statemem.iswhip or inst.sg.statemem.isbook or inst.sg.statemem.ispocketwatch then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),
        TimeEvent(17*FRAMES, function(inst)
            if inst.sg.statemem.ispocketwatch then
                inst.SoundEmitter:PlaySound(inst.sg.statemem.ispocketwatch_fueled and "wanda2/characters/wanda/watch/weapon/pst_shadow" or "wanda2/characters/wanda/watch/weapon/pst")
            end
        end),
    },


    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
    end,

    events =
    {
        EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
    end,
}
local attack2 = State{
    name = "attack",
    tags = { "attack", "notalking", "abouttoattack" },

    onenter = function(inst)
        local combat = inst.replica.combat
        if combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end

        local cooldown = combat:MinAttackPeriod()
        if inst.sg.laststate == inst.sg.currentstate then
            inst.sg.statemem.chained = true
        end
        combat:StartAttack()
        inst.components.locomotor:Stop()
        local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local rider = inst.replica.rider
        if rider ~= nil and rider:IsRiding() then
            if equip ~= nil and (equip:HasTag("rangedweapon") or equip:HasTag("projectile")) then
                inst.AnimState:PlayAnimation("player_atk_pre")
                inst.AnimState:PushAnimation("player_atk", false)
                if (equip.projectiledelay or 0) > 0 then
                    --V2C: Projectiles don't show in the initial delayed frames so that
                    --     when they do appear, they're already in front of the player.
                    --     Start the attack early to keep animation in sync.
                    inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
                    if inst.sg.statemem.projectiledelay > FRAMES then
                        inst.sg.statemem.projectilesound =
                            (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                            (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                            (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                            "dontstarve/wilson/attack_weapon"
                    elseif inst.sg.statemem.projectiledelay <= 0 then
                        inst.sg.statemem.projectiledelay = nil
                    end
                end
                if inst.sg.statemem.projectilesound == nil then
                    inst.SoundEmitter:PlaySound(
                        (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                        (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                        (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                        "dontstarve/wilson/attack_weapon",
                        nil, nil, true
                    )
                end
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 13 * FRAMES)
                end
            else
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, rider:GetMount(), "angry")
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 16 * FRAMES)
                end
            end
        elseif equip ~= nil and equip:HasTag("toolpunch") then
            inst.AnimState:PlayAnimation("toolpunch")
            inst.sg.statemem.istoolpunch = true
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
            if cooldown > 0 then
                cooldown = math.max(cooldown, 13 * FRAMES)
            end
        elseif equip ~= nil and equip:HasTag("whip") then
            inst.AnimState:PlayAnimation("whip_pre")
            inst.AnimState:PushAnimation("whip", false)
            inst.sg.statemem.iswhip = true
            inst.SoundEmitter:PlaySound("dontstarve/common/whip_pre", nil, nil, true)
            if cooldown > 0 then
                cooldown = math.max(cooldown, 17 * FRAMES)
            end
        elseif equip ~= nil and equip:HasTag("pocketwatch") then
            inst.AnimState:PlayAnimation(inst.sg.statemem.chained and "pocketwatch_atk_pre_2" or "pocketwatch_atk_pre" )
            inst.AnimState:PushAnimation("pocketwatch_atk", false)
            inst.sg.statemem.ispocketwatch = true
            cooldown = math.max(cooldown, 15 * FRAMES)
            if equip:HasTag("shadow_item") then
                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow", nil, nil, true)
                inst.AnimState:Show("pocketwatch_weapon_fx")
                inst.sg.statemem.ispocketwatch_fueled = true
            else
                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre", nil, nil, true)
                inst.AnimState:Hide("pocketwatch_weapon_fx")
            end
        elseif equip ~= nil and equip:HasTag("book") then
            inst.AnimState:PlayAnimation("attack_book")
            inst.sg.statemem.isbook = true
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
            if cooldown > 0 then
                cooldown = math.max(cooldown, 19 * FRAMES)
            end
        elseif equip ~= nil and equip:HasTag("chop_attack") and inst:HasTag("woodcutter") then
            inst.AnimState:PlayAnimation(inst.AnimState:IsCurrentAnimation("woodie_chop_loop") and inst.AnimState:GetCurrentAnimationFrame() <= 7 and "woodie_chop_atk_pre" or "woodie_chop_pre")
            inst.AnimState:PushAnimation("woodie_chop_loop", false)
            inst.sg.statemem.ischop = true
            cooldown = math.max(cooldown, 11 * FRAMES)
        elseif equip ~= nil and equip:HasTag("jab") then
            inst.AnimState:PlayAnimation("spearjab_pre")
            inst.AnimState:PushAnimation("spearjab", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
            if cooldown > 0 then
                cooldown = math.max(cooldown, 21 * FRAMES)
            end
        elseif equip ~= nil and
            equip.replica.inventoryitem ~= nil and
            equip.replica.inventoryitem:IsWeapon() and
            not equip:HasTag("punch") then
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            if (equip.projectiledelay or 0) > 0 then
                --V2C: Projectiles don't show in the initial delayed frames so that
                --     when they do appear, they're already in front of the player.
                --     Start the attack early to keep animation in sync.
                inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
                if inst.sg.statemem.projectiledelay > FRAMES then
                    inst.sg.statemem.projectilesound =
                        (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                        (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                        (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                        "dontstarve/wilson/attack_weapon"
                elseif inst.sg.statemem.projectiledelay <= 0 then
                    inst.sg.statemem.projectiledelay = nil
                end
            end
            if inst.sg.statemem.projectilesound == nil then
                inst.SoundEmitter:PlaySound(
                    (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                    (equip:HasTag("shadow") and "dontstarve/wilson/attack_nightsword") or
                    (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                    (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                    "dontstarve/wilson/attack_weapon",
                    nil, nil, true
                )
            end
            if cooldown > 0 then
                cooldown = math.max(cooldown, 13 * FRAMES)
            end
        elseif equip ~= nil and
            (equip:HasTag("light") or
            equip:HasTag("nopunch")) then
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
            if cooldown > 0 then
                cooldown = math.max(cooldown, 13 * FRAMES)
            end
        elseif inst:HasTag("beaver") then
            inst.sg.statemem.isbeaver = true
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
            if cooldown > 0 then
                cooldown = math.max(cooldown, 13 * FRAMES)
            end
        elseif inst:HasTag("weremoose") then
            inst.sg.statemem.ismoose = true
            if inst.AnimState:IsCurrentAnimation("punch_a") or inst.AnimState:IsCurrentAnimation("punch_c") then
                inst.AnimState:PlayAnimation("punch_b")
            elseif inst.AnimState:IsCurrentAnimation("punch_b") then
                if inst:HasTag("weremoosecombo") then
                    inst.sg.statemem.ismoosesmash = true
                    inst.AnimState:PlayAnimation("moose_slam")
                    inst.SoundEmitter:PlaySound("meta2/woodie/weremoose_groundpound", nil, nil, true)
                else
                    inst.AnimState:PlayAnimation("punch_c")
                end
            else
                inst.AnimState:PlayAnimation("punch_a")
            end
            if cooldown > 0 then
                cooldown = math.max(cooldown, 15 * FRAMES)
            end
        else
            local as = 1
            if inst.prefab == "chongyue" then
                local netas = inst.net_cy_ptas:value()
                if netas ~= nil then
                    as = 1 / netas
                end
            end
            
            if inst:HasTag("skill_ww") then
                inst.AnimState:PlayAnimation("skill_3_loop_a")
            elseif inst:HasTag("skill_cy") then
                inst.AnimState:PlayAnimation("skill_1")
            elseif inst:HasTag("cy_ksl") then
                if inst.cyptn then
                    inst.cyptn = false
                    inst.AnimState:PlayAnimation("attact_b")
                else
                    inst.cyptn = true
                    inst.AnimState:PlayAnimation("attact_a")
                end
                
            else
                inst.AnimState:PlayAnimation("punch")
            end
            
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
            if cooldown > 0 then
                --cooldown = math.max(cooldown, as * 24 * FRAMES)
                cooldown = as * 24 * FRAMES
            end
        end

        local buffaction = inst:GetBufferedAction()
        if buffaction ~= nil then
            inst:PerformPreviewBufferedAction()

            if buffaction.target ~= nil and buffaction.target:IsValid() then
                inst:FacePoint(buffaction.target:GetPosition())
                inst.sg.statemem.attacktarget = buffaction.target
                inst.sg.statemem.retarget = buffaction.target
            end
        end

        if cooldown > 0 then
            inst.sg:SetTimeout(cooldown)
        end
    end,

    onupdate = function(inst, dt)
        if (inst.sg.statemem.projectiledelay or 0) > 0 then
            inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
            if inst.sg.statemem.projectiledelay <= FRAMES then
                if inst.sg.statemem.projectilesound ~= nil then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.projectilesound, nil, nil, true)
                    inst.sg.statemem.projectilesound = nil
                end
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end
        end
    end,

    timeline =
    {
        TimeEvent(5 * FRAMES, function(inst)
            if inst.sg.statemem.ismoose and not inst.sg.statemem.ismoosesmash then
                inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/punch", nil, nil, true)
            end
        end),
        TimeEvent(6 * FRAMES, function(inst)
            if inst.sg.statemem.isbeaver then
                inst:ClearBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            elseif inst.sg.statemem.ischop then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
            end
        end),
        TimeEvent(7 * FRAMES, function(inst)
            if inst.sg.statemem.ismoose then
                if inst.sg.statemem.ismoosesmash then
                    inst:PushMooseSmashShake()

                    --V2C: first frame is blank, so no need to worry about forcing instant facing update
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local fx = SpawnPrefab("weremoose_smash_fx")
                    fx.Transform:SetPosition(x, 0, z)
                    fx.Transform:SetRotation(inst.Transform:GetRotation())
                end
                inst:ClearBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),
        TimeEvent(8 * FRAMES, function(inst)
            if not (inst.sg.statemem.isbeaver or
                    inst.sg.statemem.ismoose or
                    inst.sg.statemem.iswhip or
                    inst.sg.statemem.ispocketwatch or
                    inst.sg.statemem.isbook) and
                inst.sg.statemem.projectiledelay == nil then
                inst:ClearBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),
        TimeEvent(10 * FRAMES, function(inst)
            if inst.sg.statemem.iswhip or inst.sg.statemem.isbook or inst.sg.statemem.ispocketwatch then
                inst:ClearBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),
        TimeEvent(17*FRAMES, function(inst)
            if inst.sg.statemem.ispocketwatch then
                inst.SoundEmitter:PlaySound(inst.sg.statemem.ispocketwatch_fueled and "wanda2/characters/wanda/watch/weapon/pst_shadow" or "wanda2/characters/wanda/watch/weapon/pst")
            end
        end),
    },

    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
    end,

    events =
    {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.replica.combat:CancelAttack()
        end
    end,
}

AddStategraphState("wilson",  attack)
AddStategraphState("wilson_client",  attack2)





