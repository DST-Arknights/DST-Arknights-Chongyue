local duration = 30 * 5  --5个时段

------------------------light------------------------
local function light_resume(inst, time)
    --inst.fx:setprogress(1 - time / inst.components.spell.duration)
end
local function light_start(inst)
    --inst.fx:setprogress(0)
end
local function pushbloom(inst, target)
    if target.components.bloomer ~= nil then
        target.components.bloomer:PushBloom(inst, "shaders/anim.ksh", -1)
    else
        target.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end
local function popbloom(inst, target)
    if target.components.bloomer ~= nil then
        target.components.bloomer:PopBloom(inst)
    else
        target.AnimState:ClearBloomEffectHandle()
    end
end
local function OnOwnerChange(inst)
    local newowners = {}
    local owner = inst._target
    local isrider = false
    while true do
        newowners[owner] = true

        local rider = owner.components.rideable and owner.components.rideable:GetRider()
        local invowner = owner.components.inventoryitem and owner.components.inventoryitem.owner

        if inst._owners[owner] then
            inst._owners[owner] = nil
        else
            if owner.components.rideable then
                inst:ListenForEvent("riderchanged", inst._onownerchange, owner)
            end
            if not rider and owner.components.inventoryitem then
                inst:ListenForEvent("onputininventory", inst._onownerchange, owner)
                inst:ListenForEvent("ondropped", inst._onownerchange, owner)
            end
        end

        local nextowner = rider or invowner
        if not nextowner then break end
        isrider = rider ~= nil
        owner = nextowner
    end

    inst.fx.entity:SetParent(owner.entity)

    if inst._popbloom ~= nil and inst._popbloom ~= owner then
        popbloom(inst, inst._popbloom)
        if isrider then
            pushbloom(inst, owner)
            inst._popbloom = owner
        else
            inst._popbloom = nil
        end
    end

    for k, v in pairs(inst._owners) do
        if k:IsValid() then
            if k.components.inventoryitem then
                inst:RemoveEventCallback("onputininventory", inst._onownerchange, k)
                inst:RemoveEventCallback("ondropped", inst._onownerchange, k)
            end
            if k.components.rideable then
                inst:RemoveEventCallback("riderchanged", inst._riderchanged, k)
            end
        end
    end

    inst._owners = newowners
end
local function light_ontarget(inst, target)
    if target == nil or target:HasTag("playerghost") or target:HasTag("overcharge") then
        inst:Remove()
        return
    end

    local function forceremove()
        inst.components.spell:OnFinish()
    end

    inst._target = target
    target.mlzzlight = inst
    --FollowSymbol position still works on blank symbol, just
    --won't be visible, but we are an invisible proxy anyway.
    inst.Follower:FollowSymbol(target.GUID, "", 0, 0, 0)
    inst:ListenForEvent("onremove", forceremove, target)

    if target:HasTag("player") then
        inst:ListenForEvent("ms_becameghost", forceremove, target)
        if target:HasTag("electricdamageimmune") then
            inst:ListenForEvent("ms_overcharge", forceremove, target)
        end
        inst.persists = false
    else
        inst.persists = not target:HasTag("critter")
    end

    pushbloom(inst, target)
    OnOwnerChange(inst)
end
local function light_onfinish(inst)
    local target = inst.components.spell.target
    if target ~= nil then
        target.mlzzlight = nil

        popbloom(inst, target)

        if target.components.rideable ~= nil then
            local rider = target.components.rideable:GetRider()
            if rider ~= nil then
                popbloom(inst, rider)
            end
        end
    end
end
local function light_onremove(inst)
    inst.fx:Remove()
end
local function light_com(fxprefab)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst:Hide()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]

    inst:AddComponent("spell")
    inst.components.spell.spellname = "mlzzlight"
    inst.components.spell.duration = duration
    inst.components.spell.ontargetfn = light_ontarget
    inst.components.spell.onstartfn = light_start
    inst.components.spell.onfinishfn = light_onfinish
    inst.components.spell.resumefn = light_resume
    inst.components.spell.removeonfinish = true

    inst.persists = false --until we get a target
    inst.fx = SpawnPrefab(fxprefab)
    inst.OnRemoveEntity = light_onremove

    inst._owners = {}
    inst._onownerchange = function() OnOwnerChange(inst) end

    return inst
end

local function MakeLight1()
    return light_com("chongyue_light_fx1")
end
local function MakeLight2()
    return light_com("chongyue_light_fx2")
end
local function MakeLight3()
    return light_com("chongyue_light_fx3")
end
local function MakeLight4()
    return light_com("chongyue_light_fx4")
end
local function MakeLight5()
    return light_com("chongyue_light_fx5")
end

------------------------fx------------------------

local function light_comFx(li,lr)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Light:SetRadius(lr)
    inst.Light:SetIntensity(li / 3)
    inst.Light:SetFalloff(.9 / 2)
    inst.Light:SetColour(169/255, 231/255, 245/255)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst._lighttask = nil

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function MakeLightFx1()
    return light_comFx(.3, 2)
end
local function MakeLightFx2()
    return light_comFx(.45, 3)
end
local function MakeLightFx3()
    return light_comFx(.6, 4)
end
local function MakeLightFx4()
    return light_comFx(.75, 5)
end
local function MakeLightFx5()
    return light_comFx(.9, 7)
end

--------------------------------------------------




return Prefab("chongyue_light_fx1", MakeLightFx1)
,Prefab("chongyue_light_fx2", MakeLightFx2)
,Prefab("chongyue_light_fx3", MakeLightFx3)
,Prefab("chongyue_light_fx4", MakeLightFx4)
,Prefab("chongyue_light_fx5", MakeLightFx5)
,Prefab("chongyue_light_fx5", MakeLightFx5)

,Prefab("chongyue_light1", MakeLight1)
,Prefab("chongyue_light2", MakeLight2)
,Prefab("chongyue_light3", MakeLight3)
,Prefab("chongyue_light4", MakeLight4)
,Prefab("chongyue_light5", MakeLight5)
