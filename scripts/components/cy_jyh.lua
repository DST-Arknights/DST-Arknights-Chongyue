local function oncur(self)
    self.inst.net_cyjyh:set(self.cur)
end

local cy_jyh = Class(function(self, inst)
    self.inst = inst

    self.cur = 0
    self.dam = 11

    self.task = self.inst:DoPeriodicTask(1,function()   --每帧更新状态有些浪费算力，这里先每秒运行一次
        if inst.components.cy_qzbs == nil or inst.components.combat == nil then
            return
        end
        local tp = inst.components.cy_qzbs.current
        --最安全的方法
        if tp == nil then
            return
        end
        
        self:SetWork(tp)
        self:SetDef(tp)
        self:SetDam(tp)
        if self.cur == 0 then
            self:SetHp(TUNING.CHONGYUE_HEALTH)
            self:SetSan(TUNING.CHONGYUE_SANITY, tp)
            self:SetAs(TUNING.CHONGYUE.AS, tp)
        elseif self.cur == 1 then
            self:SetSan(TUNING.CHONGYUE.J1_sanity, tp)
            self:SetAs(TUNING.CHONGYUE.AS, tp)
        elseif self.cur == 2 then
            self:SetHp(TUNING.CHONGYUE.J2_hp)
            self:SetSan(TUNING.CHONGYUE.J2_sanity, tp)
            self:SetAs(TUNING.CHONGYUE.J2_AS, tp)
        end
    end)
end,
nil,
{
    cur = oncur
})

function cy_jyh:OnSave() --保存
    return  { 
        cur = self.cur,
    }  --保存当前值
end

function cy_jyh:OnLoad(data) --加载
    if data ~= nil then
        if data.cur == nil then
            return
        end
        self.cur = data.cur
        if self.cur == 1 then
            self:J1() 
        elseif self.cur == 2 then
            self:J2() 
        end
    end

end

function cy_jyh:IsJ(num)
    if num == nil then
        return false
    end
    return self.cur == num
end

function cy_jyh:GetJ()
    return self.cur 
end

function cy_jyh:Jup()   --进阶
    if self.cur == 0 then
        if self:J1() then   
            self.cur = 1
        end
    elseif self.cur == 1 then
        if self:J2() then
            self.cur = 2
        end
    end
end

function cy_jyh:J1() 
    local inst = self.inst
    if inst.components.sanity == nil or inst.components.cy_qzbs == nil then   --万一
        return false
    end
    self:SetSan(TUNING.CHONGYUE.J1_sanity, inst.components.cy_qzbs.current)

    inst.components.cy_qzbs.s1max = 5 * 3
    inst.components.cy_qzbs.s2max = 12 * 2

    inst.zgmult = 1.55
    return true
end
function cy_jyh:J2()
    local inst = self.inst
    if inst.components.hunger then
        inst.components.hunger.hungerrate = 0.8 * TUNING.WILSON_HUNGER_RATE
    end
    

    if inst.components.sanity == nil or 
    inst.components.health == nil or 
    inst.components.cy_qzbs == nil then 
        return false
    end
    inst.components.cy_qzbs:SetMax(TUNING.CHONGYUE.BSMAX_J2)
    
    self:SetSan(TUNING.CHONGYUE.J2_sanity, inst.components.cy_qzbs.current)
    self:SetHp(TUNING.CHONGYUE.J2_hp)

    inst.components.cy_qzbs.s1max = 3 * 3
    inst.components.cy_qzbs.s2max = 11 * 2
    inst.components.cy_qzbs.s3max = 10

    inst.zgmult = 1.65
    return true
end

function cy_jyh:SetSan(base, tp)
    local inst = self.inst
    if inst.components.sanity == nil then
        return
    end

    local oldpercent = inst.components.sanity:GetRealPercent()
    inst.components.sanity.max = base + tp - 60
    inst.components.sanity:SetPercent(oldpercent,true)
end
function cy_jyh:SetHp(base)
    local inst = self.inst
    if inst.components.health == nil or inst:HasTag("playerghost") then
        return
    end
    local oldpercent = inst.components.health:GetPercent()
    inst.components.health.maxhealth = base
    inst.components.health:SetPercent(oldpercent,true)
end

function cy_jyh:SetDam(tp)
    local inst = self.inst
    if inst.components.combat == nil then
        return
    end
    self.dam = 11 + tp
    inst.components.combat:SetDefaultDamage(self.dam)
    if inst:HasTag("cy_ksl") then
        inst.components.combat.externaldamagemultipliers:SetModifier("cywyjt", 1)
    else
        inst.wqdmult = (tp/100) + .6
        inst.components.combat.externaldamagemultipliers:SetModifier("cywyjt", inst.wqdmult)
    end
end
function cy_jyh:SetDef(tp)
    local inst = self.inst
    if  inst.components.health == nil then
        return
    end
    local def = math.floor( ( tp - 60 ) / 2 ) 
    inst.components.health.externalabsorbmodifiers:SetModifier("i11qzbs", def/100)
end
function cy_jyh:SetWork(tp)
    local inst = self.inst

    local t = (25 + tp)/50

    inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   t, inst)
	inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE,   t, inst)
	inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, t, inst)
end

function cy_jyh:SetAs(base, tp)
    local inst = self.inst
    if base ~= nil and tp ~= nil then
        local as = base - 0.6 + (tp * 0.01)
        inst.net_cy_ptas:set(as)
    end
    
end

return cy_jyh