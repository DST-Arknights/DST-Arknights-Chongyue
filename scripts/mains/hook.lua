local function ks(inst)
    if inst.components.cy_qzbs == nil then
        return
    end
    inst.components.cy_qzbs:StartUp()   --技力开始增长

    inst:AddTag("cy_ksl")   --加tag以便判断
         
    if inst.components.combat ~= nil then
        if inst:HasTag("cy_atkcombo") then 
            inst.components.combat:SetRange(TUNING.CHONGYUE.AsR2, TUNING.CHONGYUE.AsR2+1)
            SendModRPCToClient(CLIENT_MOD_RPC["cy_client"]["private_circle"], inst.userid, true)
        end
        inst.components.combat.externaldamagemultipliers:SetModifier("cywyjt", 1)
        --inst.components.combat.externaldamagemultipliers:RemoveModifier("cywyjt")
    end
    
end
local function noks(inst)
    if inst.components.cy_qzbs == nil then
        return
    end
    inst.components.cy_qzbs:StopUp()

    inst:RemoveTag("cy_ksl")
    if inst.components.combat ~= nil then
        inst.components.combat:SetRange(2, 2)
        local dammult = inst.wqdmult or 1
        inst.components.combat.externaldamagemultipliers:SetModifier("cywyjt", dammult)
    end
end

local function nohealth(inst)
    if inst:HasTag("cy_nogood") then
        return
    end
    inst:AddTag("cy_nogood")
    inst.components.cy_qzbs:SetHrate(TUNING.CHONGYUE.NOGOOD_spd)
end
local function ishealth(inst)
    if not inst:HasTag("cy_nogood") then
        return
    end
    inst:RemoveTag("cy_nogood")
    inst.components.cy_qzbs:SetHrate(1)
end

local function zhige(target)        --暂时用发光来当作标识
    if target.task_l_ispro ~= nil then  --刷新计时
        target.task_l_ispro:Cancel()
    end
    if target._lightzg == nil then   -- 没有光效生成光效
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

local function jlup(inst)
    SendModRPCToClient(CLIENT_MOD_RPC["i11"]["wxwb"], inst.userid, inst)
    --inst:PushEvent("wxwb_st")
    --inst.net_wxwb:set(not inst.net_wxwb:value())
    --inst.components.talker:Say("1")
    inst.components.cy_qzbs:S1DoDelta(3)
    inst.components.cy_qzbs:S2DoDelta(3)
    inst.components.cy_qzbs:S3DoDelta(3)
end

--监听
    --装备
    local function i11equip(inst, data)
        --手部-------------------------------
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item ~= nil then
            noks(inst)
        end
    end
    --卸下装备
    local function i11unequip(inst, data)
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item == nil then
            ks(inst)
        end
    end
    --揍人
    local function i11atko(inst, data)
        if inst.components.cy_jyh == nil or 
        inst.components.cy_qzbs == nil or 
        data == nil then
            return
        end
        local target = data.target
        local lv = inst.components.cy_jyh:GetJ()
        if inst:HasTag("cy_ksl") then   --是空手
            
            if target == nil then
                return
            end
            if lv >= 1 then --止戈
                if math.random() < TUNING.CHONGYUE.ZGran then
                    zhige(target)
                end
            end
        end
    end
    --饱食度变化
    local function i11hdelta(inst, data)
        if inst.components.cy_qzbs == nil or data == nil then
            return
        end
        if data.newpercent > TUNING.CHONGYUE.NOGOOD_max or data.newpercent < TUNING.CHONGYUE.NOGOOD_min then
            nohealth(inst)
        else
            ishealth(inst)
        end
    end
--

AddPrefabPostInit("chongyue", function(inst)

    inst:AddTag("cy_qzbs")  --加个tag方面以后判断

    --上面是主客都会运行
    if not TheWorld.ismastersim then
        return inst
    end
    if inst.components.talker then
        inst.components.talker.colour = {x = 197 / 255, y = 153 / 255, z = 81 / 255}
    end
    --下面是只有主机运行
    if inst.components.combat then  --修改空手攻击的方法，使其使用新增的数值，就不动玩家原本的攻击力了
        local oldatk1 = inst.components.combat.DoAttack
        inst.components.combat.DoAttack = function(self, targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
            --如果 是空手攻击!
            if weapon == nil and self:GetWeapon() == nil then  
                
                inst.components.cy_qzbs:DoAtk()         ----这里这里，看我看我，普攻加技力和百式值在这里触发，如果不想aoe每个单位触发一次，尽量用getattack而不是doattack

                if self.inst:HasTag("cy_atkcombo") then  --使用过5次我无，那么就是二连击
                    if targ ~= nil then
                        targ:DoTaskInTime(0.15, function()
                            if targ and targ:IsValid() and targ.components.combat 
                            and targ.components.health ~= nil and not targ.components.health:IsDead() then
                                targ.components.combat:GetAttacked(inst, inst.components.combat.defaultdamage, nil, stimuli)
                                inst.components.cy_qzbs:DoAtk() --二连击加点
                            end
                        end)
                    end
                end
                
            end
            --不是空手的话就正常流程
            return oldatk1(self, targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
        end
    end


    --监听
    inst:ListenForEvent("equip",  i11equip)
	inst:ListenForEvent("unequip", i11unequip)
    inst:ListenForEvent("onattackother", i11atko)
    inst:ListenForEvent("hungerdelta", i11hdelta)

    inst:ListenForEvent("killed",  function(inst,data)
        if inst.wxwbcd ~= nil then
            return
        end

        -- if data.victim and data.victim.wxwb ~= nil then
        --     jlup(inst)
        --     WNAPI.dotask1(inst, "wxwbcd", 0.1, function()
        --         inst.wxwbcd:Cancel()
        --         inst.wxwbcd = nil
        --     end)
        -- end

        if data.victim and data.victim.wxwb then
            jlup(inst)
            WNAPI.dotask1(inst, "wxwbcd", 0.1, function()
                inst.wxwbcd:Cancel()
                inst.wxwbcd = nil
            end)
        end
    end)

    --要单独保存光效
    inst._oldsav = inst.OnSave
    inst.OnSave = function(inst, data)
        if inst.mlzzlight ~= nil then   --
            data.mlzzlight = inst.mlzzlight:GetSaveRecord()
        end
        if inst._oldsav ~= nil then
            return inst._oldsav(inst, data)
        end
    end
    inst._oldloa = inst.OnLoad
    inst.OnLoad = function(inst, data)  
        if data ~= nil then
            if data.mlzzlight ~= nil and inst.mlzzlight == nil then --
                local mlzzlight = SpawnSaveRecord(data.mlzzlight)
                if mlzzlight ~= nil and mlzzlight.components.spell ~= nil then
                    mlzzlight.components.spell:SetTarget(inst)
                    if mlzzlight:IsValid() then
                        if mlzzlight.components.spell.target == nil then
                            mlzzlight:Remove()
                        else
                            mlzzlight.components.spell:ResumeSpell()
                        end
                    end
                end
            end
        end
        if inst._oldloa ~= nil then
            return inst._oldloa(inst, data)
        end
    end

end)

AddPrefabPostInit("world", function (inst)
    local function SpawnLootPrefab(inst, lootprefab)
        if lootprefab == nil then
            return
        end
    
        local loot = SpawnPrefab(lootprefab)
        if loot == nil then
            return
        end
    
        local x, y, z = inst.Transform:GetWorldPosition()
    
        if loot.Physics ~= nil then
            local angle = math.random() * 2 * PI
            loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))
    
            if inst.Physics ~= nil then
                local len = loot:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0)
                x = x + math.cos(angle) * len
                z = z + math.sin(angle) * len
            end
        end
        loot.Transform:SetPosition(x, y, z)
        loot:PushEvent("on_loot_dropped", {dropper = inst})
        return loot
    end

    inst:ListenForEvent("ms_playerdespawnanddelete", function (_inst, player)
        if player and player.components.cy_jyh then
            if player.components.cy_jyh.cur and player.components.cy_jyh.cur >= 1 then
                local recipe = AllRecipes["i11_jy1"]
                for i, v in ipairs(recipe.ingredients) do
                    local amt = v.amount == 0 and 0 or math.max(1, v.amount)
                    for n = 1, amt do
                        SpawnLootPrefab(player, v.type)
                    end
                end
            end
            if player.components.cy_jyh.cur and player.components.cy_jyh.cur >= 2 then
                local recipe = AllRecipes["i11_jy2"]
                for i, v in ipairs(recipe.ingredients) do
                    local amt = v.amount == 0 and 0 or math.max(1, v.amount)
                    for n = 1, amt do
                        SpawnLootPrefab(player, v.type)
                    end
                end
            end
        end
    end)
end)