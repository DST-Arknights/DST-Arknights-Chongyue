local YZT = "chongyue"
local function SpawnFx2(inst, first)
    local fx = SpawnPrefab("attack_skill_2_fx")
    if first then
        fx.AnimState:PlayAnimation("up")
    else
        fx.AnimState:PlayAnimation("down")
    end
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function getskillatk(inst, dammult, attacker)
    local stimuli
    if stimuli == nil and attacker.components.electricattacks ~= nil then --电系增伤
        stimuli = "electric"
    end
    attacker:PushEvent("onattackother", { target = inst, weapon = nil, projectile = nil, stimuli = stimuli })

    local reflected_dmg = 0
    local reflected_spdmg
    local reflect_list = {}
    if attacker.components.combat ~= nil then
        local mult = 1

        local _weapon_cmp = nil
        --雷电增伤
        if stimuli == "electric" and not
            (
                inst:HasTag("electricdamageimmune") or
                (inst.components.inventory ~= nil and inst.components.inventory:IsInsulated())
            )
        then
            local electric_damage_mult = TUNING.ELECTRIC_DAMAGE_MULT
            local electric_wet_damage_mult = TUNING.ELECTRIC_WET_DAMAGE_MULT

            mult = electric_damage_mult + electric_wet_damage_mult *
                (inst.components.moisture ~= nil and inst.components.moisture:GetMoisturePercent() or (inst:GetIsWet() and 1 or 0))
        end
        --计算伤害
        local dmg, spdmg = attacker.components.combat:CalcDamage(inst, nil, mult)

        inst.components.combat:GetAttacked(attacker, dmg * dammult, nil, stimuli, spdmg, true)
    end
end

local function say(inst, str)
    if inst.components.talker then
        inst.components.talker:Say(str)
    end
end
local function zhige(target)           --拂尘二段触发止戈
    if target.task_l_ispro ~= nil then --刷新计时
        target.task_l_ispro:Cancel()
    end
    if target._lightzg == nil then -- 没有光效生成光效
        target._lightzg = SpawnPrefab("skill_0_fx")
        target._lightzg.entity:SetParent(target.entity)
    end
    target:AddTag("cy_zhige")
    target.task_l_ispro = target:DoTaskInTime(TUNING.CHONGYUE.ZGtime, function()
        target:RemoveTag("cy_zhige")
        if target._lightzg ~= nil then
            target._lightzg:Remove()
            target._lightzg = nil
        end
    end)
end
local function fchit(inst, attacker) --第一次遍历，攻击并击飞带天赋的
    local dammult = attacker.components.cy_jyh:GetJ() + 2.5
    WNAPI.dotask_wxwb(inst)
    --attacker.components.combat:DoAttack(inst, nil, nil, nil, dammult, 8)
    getskillatk(inst, dammult, attacker)
    if inst.sg == nil or inst.components.locomotor == nil then
        return
    end
    if inst.sg and inst.sg:HasState("hit") then
        --if inst.prefab == "daywalker" and (inst.defeated or not inst.hostile or inst.sg:HasStateTag("tired")) then

        if inst.prefab ~= "daywalker" then --算啦，反正疯猪挨打会直接进入hit
            inst.sg:GoToState("hit")
        end
    end

    --筛选第一天赋携带者
    if not inst:HasTag("cy_zhige") then
        return
    end
    inst:AddTag("isfcfly")
    local x2, y2, z2 = inst.Transform:GetWorldPosition()
    if inst.Physics then
        inst.Physics:Teleport(x2, y2 + 2, z2)
    else
        inst.Transform:SetPosition(x2, y2 + 2, z2)
    end
end
local function fchit2(inst, attacker) --第二次遍历，攻击并击落空中单位
    if inst.sg == nil or inst.components.locomotor == nil then
        return
    end
    if not inst:HasTag("isfcfly") and not inst:HasTag("flying") then --没被一段击飞，也不是飞行生物
        return
    end

    inst:RemoveTag("isfcfly") --就算没有这个tag，直接移除也没问题所以不用判断
    zhige(inst)

    local dammult = (attacker.components.cy_jyh:GetJ() * 1.7) + 3.1
    WNAPI.dotask_wxwb(inst)
    --attacker.components.combat:DoAttack(inst, nil, nil, nil, dammult, 8)
    getskillatk(inst, dammult, attacker)
    local x2, y2, z2 = inst.Transform:GetWorldPosition()

    local fx2 = SpawnPrefab("groundpound_fx")   --生成坠地特效
    fx2.Transform:SetPosition(x2, 0, z2)
    local fxr = inst:GetPhysicsRadius(.5) or .2 --根据目标物理碰撞半径  的一半
    fx2.Transform:SetScale(fxr, fxr, fxr)       --设置特效大小

    if inst.Physics then
        inst.Physics:Teleport(x2, 0, z2)
    else
        inst.Transform:SetPosition(x2, 0, z2)
    end
    if inst.sg and inst.sg:HasStateTag("hit") and (not inst.components.health or not inst.components.health:IsDead()) then
        inst.sg:GoToState("hit")
    end
end
local AOE_MUST_TAGS = { "_combat" }
local AOE_CANT_TAGS = { "INLIMBO", "wall", "companion", "DECOR", "invisible", "notarget", "noattack", "playerghost",
    "player" }
local function DoFc(inst)
    SpawnFx2(inst, true)
    inst.components.cy_qzbs:S2DoDelta()
    inst.sg:GoToState("cy_fc")
    local x, y, z = inst.Transform:GetWorldPosition()
    --inst.SoundEmitter:PlaySound("cy_music/i11se/skill2",nil,TUNING.CHONGYUE.SEval)
    inst.SoundEmitter:PlaySound("cy_music/se2/skill2", nil, TUNING.CHONGYUE.SEval)
    local fx1 = SpawnPrefab("firering_fx")
    fx1.Transform:SetPosition(x, y + 4, z)
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 8, AOE_MUST_TAGS, AOE_CANT_TAGS)) do
        if v:IsValid() and not v:IsInLimbo() and
            not (v.components.health ~= nil and v.components.health:IsDead()) then
            --v.components.combat:GetAttacked(inst, 10, nil, "electric", {planar = 2})
            fchit(v, inst)
        end
    end
    inst:DoTaskInTime(0.5, function() --wiki写击飞2秒，2倍速一秒， 但这里先0.5秒
        --
        SpawnFx2(inst, false)
        local fx1 = SpawnPrefab("groundpoundring_fx")
        fx1.Transform:SetPosition(x, 0, z)
        --local fx2 = SpawnPrefab("alterguardian_spintrail_fx")
        --fx2.Transform:SetPosition(x, y, z)
        --local tscale = 2.5
        local tscale1 = 0.9
        fx1.Transform:SetScale(tscale1, tscale1, tscale1)
        --fx2.Transform:SetScale(tscale,tscale,tscale)

        for i, v in ipairs(TheSim:FindEntities(x, y, z, 8, AOE_MUST_TAGS, AOE_CANT_TAGS)) do
            if v:IsValid() and not v:IsInLimbo() and
                not (v.components.health ~= nil and v.components.health:IsDead()) then
                --v.components.combat:GetAttacked(inst, 10, nil, "electric", {planar = 2})
                fchit2(v, inst)
            end
        end
    end)
end

--

local function ACT2(inst)
    if not inst.sg or inst.sg:HasStateTag("busy") then
        return
    end
    if inst.components.cy_jyh == nil or inst.components.cy_jyh:GetJ() < 1 then
        say(inst, "精一解锁该技能")
        return
    end
    if inst.components.cy_qzbs == nil or not inst.components.cy_qzbs:S2Ready() then --技力不足
        say(inst, "技力不够")
        return
    end
    DoFc(inst)
    WNAPI.say_yy(inst)
end

local function ACT1(inst)
    if inst:HasTag("skill_cy") then --这一拳打出去才能使用哦
        say(inst, "已经激活了")
        return
    end
    if inst.components.cy_qzbs == nil or not inst.components.cy_qzbs:S1Ready() then --技力不足
        say(inst, "技力不够")
        return
    end
    inst:AddTag("skill_cy")
end
local function ACT3(inst)
    TheWorld.state.autumnlength = 1
    if inst:HasTag("skill_ww") then --这一拳打出去才能使用哦
        say(inst, "已经激活了")
        return
    end
    if inst.components.cy_jyh == nil or inst.components.cy_jyh:GetJ() < 2 then
        say(inst, "精二解锁该技能")
        return
    end
    if inst.components.cy_qzbs == nil or not inst.components.cy_qzbs:S3Ready() then --技力不足
        say(inst, "技力不够")
        return
    end

    -- local fx  =  SpawnPrefab("tauntfire_fx")
    -- fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:AddTag("skill_ww")
end

--

AddModRPCHandler(modname, "acts111", function(player) --服务器收到消息啦
    if not player:HasTag("playerghost") and not player.components.health:IsDead() then
        ACT1(player)
    end
end)
AddModRPCHandler(modname, "acts222", function(player) --服务器收到消息啦
    if not player:HasTag("playerghost") and not player.components.health:IsDead() then
        ACT2(player)
    end
end)
AddModRPCHandler(modname, "acts333", function(player) --服务器收到消息啦
    if not player:HasTag("playerghost") and not player.components.health:IsDead() then
        ACT3(player)
    end
end)
--

TheInput:AddKeyDownHandler(TUNING.CHONGYUE.S1key, function() --从本地监听，按下对应按键后发消息给服务器
    local player = ThePlayer
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local IsHUDActive = screen and screen.name == "HUD"
    if player and player:IsValid() and player.prefab == YZT and not player:HasTag("playerghost") and IsHUDActive then
        SendModRPCToServer(MOD_RPC[modname]["acts111"])
    end
end)
TheInput:AddKeyDownHandler(TUNING.CHONGYUE.S2key, function()
    local player = ThePlayer
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local IsHUDActive = screen and screen.name == "HUD"
    if player and player:IsValid() and player.prefab == YZT and not player:HasTag("playerghost") and IsHUDActive then
        SendModRPCToServer(MOD_RPC[modname]["acts222"])
    end
end)
TheInput:AddKeyDownHandler(TUNING.CHONGYUE.S3key, function()
    local player = ThePlayer
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local IsHUDActive = screen and screen.name == "HUD"
    if player and player:IsValid() and player.prefab == YZT and not player:HasTag("playerghost") and IsHUDActive then
        SendModRPCToServer(MOD_RPC[modname]["acts333"])
    end
end)

AddClientModRPCHandler("cy_client", "private_circle", function(state)
    if not ThePlayer.cy_private_circle and state then
        local circle = SpawnPrefab("cy_private_circle")
        circle.Transform:SetScale(1.2, 1.2, 1.2)
        circle.entity:SetParent(ThePlayer.entity)
        ThePlayer.cy_private_circle = circle
    elseif ThePlayer.cy_private_circle and not state then
        ThePlayer.cy_private_circle:Remove()
        ThePlayer.cy_private_circle = nil
    end
end)
