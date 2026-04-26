require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/portable_supply.zip"),
    Asset("ATLAS", "images/inventoryimages/portable_supply.xml"),
    Asset("IMAGE", "images/inventoryimages/portable_supply.tex"),
}

local function ondeploy(inst, pt, deployer)
    local turret = SpawnPrefab("cy_portablesupply")
    local entities = TheSim:FindEntities(pt.x, 0, pt.z, TUNING.CHONGYUE.SUPPLY_RANGE, {"cy_portablesupply"})
    if not entities or #(entities) == 0 then
        turret.Physics:SetCollides(false)
        turret.Physics:Teleport(pt.x, 0, pt.z)
        turret.Physics:SetCollides(true)
        turret.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
        turret.components.fueled:SetPercent(inst.components.fueled:GetPercent())
        turret._fuellevel = inst._fuellevel or 3
        inst:Remove()
    else
        if deployer and deployer.components.talker then
            deployer.components.talker:Say("附近已经有补给站了，不用再布置了")
            deployer.components.inventory:GiveItem(inst)
        end
    end
end

local function OnDismantle(inst, doer)
    inst.AnimState:PlayAnimation("hit")
    inst:ListenForEvent("animover", function()
        local item = SpawnPrefab("cy_portablesupply_item")
        item.components.fueled:SetPercent(inst.components.fueled:GetPercent())
        item._fuellevel = inst._fuellevel or 3
        if doer and doer.components.inventory then
            doer.components.inventory:GiveItem(item)
        else
            item.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
        inst:Remove()
    end)
end

local PLACER_SCALE = 1

local function OnEnableHelper(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateEntity()

            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.Transform:SetScale(PLACER_SCALE, PLACER_SCALE, PLACER_SCALE)

            inst.helper.AnimState:SetBank("firefighter_placement")
            inst.helper.AnimState:SetBuild("firefighter_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetAddColour(0, .2, .5, 0)

            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function TurnOn(inst)
    inst.components.fueled:StartConsuming()
    inst.Light:Enable(true)
    inst.AnimState:PushAnimation("idle_"..inst._fuellevel + 1, true)
    inst:AddTag("sanityaura")
end

local function TurnOff(inst)
    inst.components.fueled:StopConsuming()
    inst.Light:Enable(false)
    inst.AnimState:PushAnimation("idle_1")
    inst:RemoveTag("sanityaura")
end

local function OnFuelEmpty(inst)
    inst.components.cy_machine:TurnOff()
end

local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
    if inst.on == false then
        inst.components.cy_machine:TurnOn()
    end
end

local function OnFuelSectionChange(new, old, inst)
    if inst._fuellevel ~= new then
        inst._fuellevel = new
        if inst.components.cy_machine.ison then
            inst.Light:SetRadius(TUNING.TORCH_RADIUS[inst._fuellevel + 1])
            inst.Light:SetFalloff(TUNING.TORCH_FALLOFF[inst._fuellevel + 1])
            inst.AnimState:PushAnimation("idle_"..inst._fuellevel + 1, true)
        end
    end
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    if inst.components.cy_machine.ison then
        inst.AnimState:PushAnimation("idle_"..inst._fuellevel + 1, true)
    else
        inst.AnimState:PushAnimation("idle_1", true)
    end
end

local function onsave(inst, data)
end
local function onload(inst, data)

end
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, 0.5)

    inst.Light:Enable(false)
    inst.Light:SetRadius(TUNING.TORCH_RADIUS[4])
    inst.Light:SetFalloff(TUNING.TORCH_FALLOFF[4])
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(160/255,251/255,244/255)

    inst.AnimState:SetBank("portable_supply")
    inst.AnimState:SetBuild("portable_supply")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_1", true)

    inst.AnimState:SetScale(1.5, 1.5, 1.5)

    inst:AddTag("cy_portablesupply")
    inst:AddTag("structure")

    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._fuellevel = inst._fuellevel or 3

    inst:AddComponent("portablestructure")
    inst.components.portablestructure:SetOnDismantleFn(OnDismantle)
    
	inst:AddComponent("inspectable")

    inst:AddComponent("cy_machine")
    inst.components.cy_machine.turnonfn = TurnOn
    inst.components.cy_machine.turnofffn = TurnOff
    inst.components.cy_machine.cooldowntime = 0.5

    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled:SetTakeFuelFn(OnAddFuel)
    inst.components.fueled.accepting = true
    inst.components.fueled:SetSections(3)
    inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME) -- TUNING.TOTAL_DAY_TIME
    inst.components.fueled.bonusmult = 5
    inst.components.fueled.secondaryfueltype = FUELTYPE.CHEMICAL

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY

    if inst:HasTag("sanityaura") then
        inst:RemoveTag("sanityaura")
    end

    inst:AddComponent("cy_qzbsaura")
    inst.components.cy_qzbsaura.aura = TUNING.CHONGYUE.QZBSAURA

    inst:AddComponent("lootdropper")

    local recipe = AllRecipes["cy_portablesupply_item"]
    local loot = {}
    for i, v in ipairs(recipe.ingredients) do
        local amt = v.amount == 0 and 0 or math.max(1, math.ceil(v.amount / 2))
        for n = 1, amt do
            table.insert(loot, v.type)
        end
    end
    inst.components.lootdropper:SetLoot(loot)
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst.OnSave = onsave
    inst.OnLoad = onload
    return inst
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("portable_supply")
    inst.AnimState:SetBuild("portable_supply")
    inst.AnimState:PlayAnimation("place")

    inst.entity:SetPristine()

    inst._fuellevel = inst._fuellevel or 3

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/portable_supply.xml"
    inst.components.inventoryitem.imagename = "portable_supply"

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME)

    MakeHauntableLaunch(inst)

    inst:AddTag("largecreature")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy

    return inst
end

local function placer_postinit_fn(inst)
    --Show the flingo placer on top of the flingo range ground placer

    -- local placer2 = CreateEntity()

    -- --[[Non-networked entity]]
    -- placer2.entity:SetCanSleep(false)
    -- placer2.persists = false

    -- placer2.entity:AddTransform()
    -- placer2.entity:AddAnimState()

    -- placer2:AddTag("CLASSIFIED")
    -- placer2:AddTag("NOCLICK")
    -- placer2:AddTag("placer")

    -- placer2.Transform:SetScale(1.5, 1.5, 1.5)

    -- placer2.AnimState:SetBank("portable_supply")
    -- placer2.AnimState:SetBuild("portable_supply")
    -- placer2.AnimState:PlayAnimation("place")
    -- placer2.AnimState:SetLightOverride(1)

    -- if not TheNet:IsDedicated() then
    --     inst:AddComponent("deployhelper")
    --     inst.components.deployhelper.onenablehelper = OnEnableHelper
    -- end

    -- placer2.entity:SetParent(inst.entity)

    -- inst.components.placer:LinkEntity(placer2)
end

return Prefab("cy_portablesupply", fn, assets),
       Prefab("cy_portablesupply_item", itemfn, assets),
	   MakePlacer("cy_portablesupply_item_placer", "portable_supply", "portable_supply", "place", true, nil, nil, PLACER_SCALE, nil, nil, placer_postinit_fn)
