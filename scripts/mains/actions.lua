--- 关闭
local CY_TURNOFF = _G.Action({ priority = -1 })
CY_TURNOFF.id = "CY_TURNOFF"
CY_TURNOFF.str = "关闭"
CY_TURNOFF.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.cy_machine and tar.components.cy_machine:IsOn() then
        tar.components.cy_machine:TurnOff(tar)
        return true
    end
end
AddAction(CY_TURNOFF)

--- 关闭
local CY_TURNON = _G.Action({ priority = -1 })
CY_TURNON.id = "CY_TURNON"
CY_TURNON.str = "关闭"
CY_TURNON.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.cy_machine and not tar.components.cy_machine:IsOn() then
        tar.components.cy_machine:TurnOn(tar)
        return true
    end
end
AddAction(CY_TURNON)

AddComponentAction("SCENE", "cy_machine", function(inst, _, actions, right)
    if not right and not inst:HasTag("cooldown") and
        not inst:HasTag("fueldepleted") and
        not inst:HasTag("alwayson") and
        not inst:HasTag("emergency") and
        inst:HasTag("enabled") then
        local inventoryitem = inst.replica.inventoryitem
        local held = inventoryitem ~= nil and inventoryitem:IsHeld()
        if inst:HasTag("groundonlymachine") and (held or (inst.components.floater ~= nil and inst.components.floater:IsFloating())) then
            return
        elseif held then
            local equippable = inst.replica.equippable
            if equippable ~= nil and not equippable:IsEquipped() then
                return
            end
        end
        table.insert(actions, inst:HasTag("turnedon") and ACTIONS.CY_TURNOFF or ACTIONS.CY_TURNON)
    end
end)

AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.CY_TURNOFF, "give"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.CY_TURNOFF, "give"))
AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.CY_TURNON, "give"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.CY_TURNON, "give"))
