


local function zg_lightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetColour(250 / 255, 250 / 255, 170 / 255)
    inst.Light:SetIntensity(.9)
    inst.Light:SetFalloff(.9)
    inst.Light:SetRadius(1.2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end




local fx = {
    {   --出拳特效
        name = "attack_0_fx",
        bank = "attack_0_fx",
        build ="attack_0_fx",
        anim = "anim",
        fn = function(inst)
			-- local scale = 1
			-- inst.AnimState:SetScale(scale, scale)
		end,

    },
    {
        name = "attack_skill_1_fx",
        bank = "attack_skill_1_fx",
        build ="attack_skill_1_fx",
        anim = "0",
        fn = function(inst)
            local n = math.ceil(math.random(3))
            inst.AnimState:PlayAnimation(tostring(n))
			local scale = 2
			inst.AnimState:SetScale(scale, scale)
		end,

    },

    {   
        name = "attack_skill_3_fx",
        bank = "attack_skill_3_fx",
        build ="attack_skill_3_fx",
        anim = "anim",
        fn = function(inst)
			local scale = 3
			inst.AnimState:SetScale(scale, scale)
		end,

    },

    
 
}
local fx2 = {
    {
        name = "attack_skill_2_fx",
        bank = "attack_skill_2_fx",
        build ="attack_skill_2_fx",
        anim = "down",
        fn = function(inst)
			--up
            --down
            local scale = 2
			inst.AnimState:SetScale(scale, scale)
		end,

    },    {
        name = "skill_0_fx",
        bank = "skill_0_fx",
        build ="skill_0_fx",
        anim = "anim",
        fn = function(inst)
			local scale = 2
			inst.AnimState:SetScale(scale, scale)
            inst.AnimState:PlayAnimation("anim",true)
            local x,y,z = inst.Transform:GetWorldPosition()
            inst.Transform:SetPosition(x,y+1,z)
		end,
        norm = true,

    },{--背后
        name = "skill_3_fx",
        bank = "skill_3_fx",
        build ="skill_3_fx",
        anim = "def",
        fn = function(inst)
            inst.AnimState:SetSortOrder(-1)
            local x,y,z = inst.Transform:GetWorldPosition()
            inst.Transform:SetPosition(x,y+2,z)
            
			-- 0-4 
		end,
        norm = true,
    },
}
--- 
local function PlaySound(inst, sound)
    inst.SoundEmitter:PlaySound(sound)
end
local function MakeFx(t)
    local assets =
    {
        Asset("ANIM", "anim/"..t.build..".zip")
    }

    local function startfx(proxy)
        --print ("SPAWN", debugstack())
        local inst = CreateEntity(t.name)

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        local parent = proxy.entity:GetParent()
        if parent ~= nil then
            inst.entity:SetParent(parent.entity)
        end

        if t.nameoverride == nil and t.description == nil then
            inst:AddTag("FX")
        end
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.Transform:SetFromProxy(proxy.GUID)

        if t.autorotate and parent ~= nil then
            inst.Transform:SetRotation(parent.Transform:GetRotation())
        end

        if t.sound ~= nil then
            inst.entity:AddSoundEmitter()
            if t.update_while_paused then
                inst:DoStaticTaskInTime(t.sounddelay or 0, PlaySound, t.sound)
            else
                inst:DoTaskInTime(t.sounddelay or 0, PlaySound, t.sound)
            end
        end

        if t.sound2 ~= nil then
            if inst.SoundEmitter == nil then
                inst.entity:AddSoundEmitter()
            end
            if t.update_while_paused then
                inst:DoStaticTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
            else
                inst:DoTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
            end
        end

        inst.AnimState:SetBank(t.bank)
        inst.AnimState:SetBuild(t.build)
        inst.AnimState:PlayAnimation(FunctionOrValue(t.anim)) -- THIS IS A CLIENT SIDE FUNCTION
        if t.update_while_paused then
            inst.AnimState:AnimateWhilePaused(true)
        end
        if t.tint ~= nil then
            inst.AnimState:SetMultColour(t.tint.x, t.tint.y, t.tint.z, t.tintalpha or 1)
        elseif t.tintalpha ~= nil then
            inst.AnimState:SetMultColour(1, 1, 1, t.tintalpha)
        end
        --print(inst.AnimState:GetMultColour())
        if t.transform ~= nil then
            inst.AnimState:SetScale(t.transform:Get())
        end

        if t.nameoverride ~= nil then
            if inst.components.inspectable == nil then
                inst:AddComponent("inspectable")
            end
            inst.components.inspectable.nameoverride = t.nameoverride
            inst.name = t.nameoverride
        end

        if t.description ~= nil then
            if inst.components.inspectable == nil then
                inst:AddComponent("inspectable")
            end
            inst.components.inspectable.descriptionfn = t.description
        end

        if t.bloom then
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end

		if t.animqueue then
	        inst:ListenForEvent("animqueueover", inst.Remove)
	    else
	        inst:ListenForEvent("animover", inst.Remove)
	    end

        if t.fn ~= nil then
            if t.fntime ~= nil then
                if t.update_while_paused then
                    inst:DoStaticTaskInTime(t.fntime, t.fn)
                else
                    inst:DoTaskInTime(t.fntime, t.fn)
                end
            else
                t.fn(inst)
            end
        end

        if TheWorld then
            TheWorld:PushEvent("fx_spawned", inst)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            if t.update_while_paused then
                inst:DoStaticTaskInTime(0, startfx, inst)
            else
                inst:DoTaskInTime(0, startfx, inst)
            end
        end

        if t.twofaced then
            inst.Transform:SetTwoFaced()
        elseif t.eightfaced then
            inst.Transform:SetEightFaced()
        elseif t.sixfaced then
            inst.Transform:SetSixFaced()
        elseif not t.nofaced then
            inst.Transform:SetFourFaced()
        end

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return Prefab(t.name, fn, assets)
end
local function MakeFx2(t)
    local assets =
    {
        Asset("ANIM", "anim/"..t.build..".zip")
    }
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        --Dedicated server does not need to spawn the local fx
        --if not TheNet:IsDedicated() then
            if t.nameoverride == nil and t.description == nil then
                inst:AddTag("FX")
            end
            
            --[[Non-networked entity]]
            inst.entity:SetCanSleep(false)

            if t.sound ~= nil then
                if t.update_while_paused then
                    inst:DoStaticTaskInTime(t.sounddelay or 0, PlaySound, t.sound)
                else
                    inst:DoTaskInTime(t.sounddelay or 0, PlaySound, t.sound)
                end
            end
        
            if t.sound2 ~= nil then
                if inst.SoundEmitter == nil then
                    inst.entity:AddSoundEmitter()
                end
                if t.update_while_paused then
                    inst:DoStaticTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
                else
                    inst:DoTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
                end
            end
        
            inst.AnimState:SetBank(t.bank)
            inst.AnimState:SetBuild(t.build)
            inst.AnimState:PlayAnimation(FunctionOrValue(t.anim)) -- THIS IS A CLIENT SIDE FUNCTION
            if t.update_while_paused then
                inst.AnimState:AnimateWhilePaused(true)
            end
            if t.tint ~= nil then
                inst.AnimState:SetMultColour(t.tint.x, t.tint.y, t.tint.z, t.tintalpha or 1)
            elseif t.tintalpha ~= nil then
                inst.AnimState:SetMultColour(1, 1, 1, t.tintalpha)
            end
            --print(inst.AnimState:GetMultColour())
            if t.transform ~= nil then
                inst.AnimState:SetScale(t.transform:Get())
            end
        
            if t.nameoverride ~= nil then
                if inst.components.inspectable == nil then
                    inst:AddComponent("inspectable")
                end
                inst.components.inspectable.nameoverride = t.nameoverride
                inst.name = t.nameoverride
            end
        
            if t.description ~= nil then
                if inst.components.inspectable == nil then
                    inst:AddComponent("inspectable")
                end
                inst.components.inspectable.descriptionfn = t.description
            end
        
            if t.bloom then
                inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            end
            if not t.norm then
                if t.animqueue then
                    inst:ListenForEvent("animqueueover", inst.Remove)
                else
                    inst:ListenForEvent("animover", inst.Remove)
                end
            end
            
        
            if t.fn ~= nil then
                if t.fntime ~= nil then
                    if t.update_while_paused then
                        inst:DoStaticTaskInTime(t.fntime, t.fn)
                    else
                        inst:DoTaskInTime(t.fntime, t.fn)
                    end
                else
                    t.fn(inst)
                end
            end
        
            if TheWorld then
                TheWorld:PushEvent("fx_spawned", inst)
            end
        --end


        if t.twofaced then
            inst.Transform:SetTwoFaced()
        elseif t.eightfaced then
            inst.Transform:SetEightFaced()
        elseif t.sixfaced then
            inst.Transform:SetSixFaced()
        elseif not t.nofaced then
            inst.Transform:SetFourFaced()
        end

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        return inst
    end

    return Prefab(t.name, fn, assets)
end

local prefs = {}
for k,v in pairs(fx) do
    table.insert(prefs, MakeFx(v))
end
for k,v in pairs(fx2) do
    table.insert(prefs, MakeFx2(v))
end

--table.insert(prefs, Prefab("i11_zglight", zg_lightfn))

return unpack(prefs)