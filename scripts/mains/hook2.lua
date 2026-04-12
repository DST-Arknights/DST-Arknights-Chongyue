--我无的范围攻击
local AOE_MUST_TAGS = { "_combat" }
local AOE_CANT_TAGS = { "INLIMBO", "wall", "companion", "DECOR", "invisible", "notarget", "noattack", "playerghost", "player" }
local function aoeatk(target, attacker, damage, stimuli)
    local x,y,z = target.Transform:GetWorldPosition()
    
    -- local fx1 = SpawnPrefab("firering_fx")
    -- fx1.Transform:SetPosition(x, y+4, z)
    for i, v in ipairs(TheSim:FindEntities(x, y, z, TUNING.CHONGYUE.WWAOEr, AOE_MUST_TAGS, AOE_CANT_TAGS)) do
        if v:IsValid() and not v:IsInLimbo() and 
        not (v.components.health ~= nil and v.components.health:IsDead()) and
        v ~= target then
            v.components.combat:GetAttacked(attacker, damage, nil, stimuli, nil, true) 
        end
    end
end

--修改战斗组件
AddComponentPostInit("combat", function(self)
    

    if not TheWorld.ismastersim then return end

    local old1 = self.GetAttacked   --中的受到攻击方法
    self.GetAttacked = function(self, attacker, damage, weapon, stimuli, spdamage, isskill)
        local twx = false   --判断是否为技能攻击
        if attacker and not isskill then --二技能 的范围攻击不会触发其他技能
            
            if attacker:HasTag("cy_ksl") then
                if attacker:HasTag("skill_cy") then
                    attacker:RemoveTag("skill_cy")
                    damage = attacker.components.cy_qzbs:ActS1(damage, self.inst, stimuli)    --冲盈判定     --要在前面，传递的伤害会用作额外攻击
                    WNAPI.dotask_wxwb(self.inst)
                    twx = true
                    WNAPI.say_yy(attacker)
                end
                

                if self.inst:HasTag("cy_zhige") then --被止戈
                    if attacker.zgmult ~= nil then
                        damage = damage  *  attacker.zgmult 
                    end
                end

                if attacker:HasTag("skill_ww") then
                    attacker:RemoveTag("skill_ww")
                    damage = damage  *  4
                    aoeatk(self.inst, attacker, damage, stimuli) --对目标周围进行aoe!

                    attacker.components.cy_qzbs:ActS3(self.inst)
                    WNAPI.dotask_wxwb(self.inst)
                    twx = true
                    WNAPI.say_yy(attacker)
                end
                
            end

        end
        if isskill then     
            self.inst.wxwb = true
        else
            self.inst.wxwb = twx
        end

        return old1(self, attacker, damage, weapon, stimuli, spdamage)
    end
end)

local olddeploystrfn = ACTIONS.DEPLOY.strfn
ACTIONS.DEPLOY.strfn = function(act)
    if act.invobject and act.invobject.prefab == "cy_portablesupply_item" then
        return "PORTABLE"
    else
        return olddeploystrfn(act)
    end
end

