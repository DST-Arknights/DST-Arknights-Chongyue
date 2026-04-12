
local function onmax(self)
    --self.inst.replica.cy_qzbs:SetMax(max)
    self.inst.net_qzbsmax:set(self.max)
end

local function oncurrent(self)
    --self.inst.replica.cy_qzbs:SetCurrent(current)
    self.inst.net_qzbs:set(self.current)
end

local function ons1(self)
    self.inst.net_cys1:set(self.s1)
end
local function ons2(self)
    self.inst.net_cys2:set(self.s2)
end
local function ons3(self)
    self.inst.net_cys3:set(self.s3)
end
local function ons1max(self)
    self.inst.net_cysmax1:set(self.s1max)
end
local function ons2max(self)
    self.inst.net_cysmax2:set(self.s2max)
end
local function ons3max(self)
    self.inst.net_cysmax3:set(self.s3max)
end


local cy_qzbs = Class(function(self, inst)
    self.inst = inst
    self.max = 80.0 --最大值
    self.current = 60.0 --当前值

    self.rate = 1   --每秒降低的数值
    self.ratemult = 1   --倍率

    self.s1 = 0     --冲盈
    self.s2 = 0     --拂尘
    self.s3 = 0     --我无
    self.s1max = 18     --3
    self.s2max = 26     --2
    self.s3max = 10

    self.s3num = 0

    self:TwoDan()
    self:StartUp()
    self.inst:StartUpdatingComponent(self)
end,
nil,
{
    max = onmax,
    current = oncurrent,
    s1 = ons1,
    s2 = ons2,
    s3 = ons3,
    s1max = ons1max,
    s2max = ons2max,
    s3max = ons3max,
})

function cy_qzbs:OnSave() --保存
    return  {           --只需要保存当前技力点，每次加载时都会加载精英等级设置技力上限
        max = self.max,
        current = self.current,
        s1 = self.s1,
        s2 = self.s2,
        s3 = self.s3,
        s3num = self.s3num,
    }  --保存当前值
end

function cy_qzbs:OnLoad(data) --加载
    if data ~= nil then
        self.max = data.max or TUNING.CHONGYUE.BS_start
        self.current = data.current or TUNING.CHONGYUE.BSMAX_start
        self.dealycur = data.current or TUNING.CHONGYUE.BSMAX_start
        self:DoDelta(0)

        self.s1 = data.s1 or 0
        self.s2 = data.s2 or 0
        self.s3 = data.s3 or 0
        self.s3num = data.s3num or 0 
        if self.s3num >= 5 then
            self:FinishUp()
        end
        self:SpLFx(self.s3num)
    end

end

function cy_qzbs:TwoDan()
    self.inst:DoTaskInTime(0.5, function()
        self.current = self.dealycur or self.current
        self.dealycur = nil
    end)
end

function cy_qzbs:StartUp()  --空手开始增长技力
    self:StopUp()
    
    self.task_qzbs = self.inst:DoPeriodicTask(1,function()
        self:S2DoDelta(1)
    end)
end

function cy_qzbs:StopUp()
    if self.task_qzbs ~= nil then
        self.task_qzbs:Cancel()
        self.task_qzbs = nil
    end
end

function cy_qzbs:SetHrate(amount) --设置下降速率
    self.ratemult = amount
end

function cy_qzbs:SetMax(amount) --设置最大值
    self.max = amount
    --self.current = amount
end

function cy_qzbs:DoDelta(delta, overtime) --改变的函数

    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)

    --其实改变的时候事件和需要传的参数都是随自己看需求写的
    self.inst:PushEvent("cy_qzbsdelta", { oldpercent = old / self.max, newpercent = self.current / self.max })

end

function cy_qzbs:SpLFx(num)     --设置光效
    local eater = self.inst 
    for i = 1, 5 do
        if num >= i then
            if self["bfx"..i] == nil then
                self["bfx"..i] = SpawnPrefab("skill_3_fx")
                
                self["bfx"..i].AnimState:PlayAnimation(tostring(i-1),true)
                --self["bfx"..i].Transform:SetRotation(self.inst.Transform:GetRotation())
                
                --local x,y,z = self.inst.Transform:GetWorldPosition()
                
                -- local rot = self.inst.Transform:GetRotation()* DEGREES
                -- x = x + math.cos(rot) * 1
                -- z = z - math.sin(rot) * 1

                --self["bfx"..i].Transform:SetPosition(x,y+2,z)
                self["bfx"..i].entity:SetParent(self.inst.entity)
            end
        else
            if self["bfx"..i] ~= nil then
                self["bfx"..i]:Remove()
                self["bfx"..i] = nil
            end
        end
    end

    if num == 0 then
        if eater.mlzzlight ~= nil then
            eater.mlzzlight:Remove()
            eater.mlzzlight = nil
        end
        if self.light ~= nil then
            self.light:Remove()
            self.light = nil
        end

        return
    end
    local lightname = "chongyue_light" .. num
    if eater.mlzzlight ~= nil then
        if eater.mlzzlight.prefab == lightname then
            eater.mlzzlight.components.spell.lifetime = 0
            eater.mlzzlight.components.spell:ResumeSpell()
            return
        else
            eater.mlzzlight.components.spell:OnFinish()
        end
    end

    local light = SpawnPrefab(lightname)
    light.components.spell:SetTarget(eater)
    if light:IsValid() then
        if light.components.spell.target == nil then
            light:Remove()
        else
            self.light = light
            light.components.spell:StartSpell()
        end
    end

    
end

--技力变动
function cy_qzbs:S1DoDelta(val)
    self.s1 = math.clamp(self.s1+val,0, self.s1max)
end
function cy_qzbs:S2DoDelta(val)     --这个参数留空的话就是使用一次技能的消耗
    if val == nil then  
        val = -self.s2max / 2
    end
    self.s2 = math.clamp(self.s2+val,0, self.s2max)
end
function cy_qzbs:S3DoDelta(val)
    self.s3 = math.clamp(self.s3+val,0, self.s3max)

    if self.inst:HasTag("cy_atkcombo") and self.s3 >= self.s3max then
        self.inst:DoTaskInTime(0.1, function()
            self.inst:AddTag("skill_ww")
        end)
        --WNAPI.say_yy(self.inst)
    end
end
--技能是否就绪
function cy_qzbs:S1Ready()
    return self.s1 >= (self.s1max/3)
end
function cy_qzbs:S2Ready()
    return self.s2 >= (self.s2max/2)
end
function cy_qzbs:S3Ready()
    return self.s3 >= self.s3max
end 

function cy_qzbs:ActS1(damage, target, stimuli)
    local dam = damage
    if self.inst.components.cy_jyh == nil then
        return dam
    end
    local lv = self.inst.components.cy_jyh:GetJ()
    if self:S1Ready() then  --如果就绪就返回加成后的伤害
        dam = dam * (2+lv)
        if self.s1 >= self.s1max then   
            self:S1DoDelta(-self.s1max)     --达到最大充能，额外造成两次伤害
            target.components.combat:GetAttacked(self.inst, dam, nil, stimuli, nil, true)
            target.components.combat:GetAttacked(self.inst, dam, nil, stimuli, nil, true)
            self:SpawnFx1(3, target)
        else
            self:S1DoDelta(-self.s1max/3)
            self:SpawnFx1(1, target)
        end
        --声音
        --self.inst.SoundEmitter:PlaySound("cy_music/i11se/skill1",nil,TUNING.CHONGYUE.SEval)
        self.inst.SoundEmitter:PlaySound("cy_music/se2/skill1",nil,TUNING.CHONGYUE.SEval)   --se2是加速后的音效
    end

    return dam
end
function cy_qzbs:ActS3(target)    
    self:SpawnFx3(target)
    self:S3DoDelta(-self.s3max)
    if self.s3num >= 4 then
        self.s3num = 5
        self:FinishUp()
    else
        self.s3num = self.s3num + 1
    end
    self:SpLFx(self.s3num)
    --self.inst.SoundEmitter:PlaySound("cy_music/i11se/skill3",nil,TUNING.CHONGYUE.SEval)
    self.inst.SoundEmitter:PlaySound("cy_music/se2/skill3",nil,TUNING.CHONGYUE.SEval)
end
function cy_qzbs:FinishUp()
    self.inst:AddTag("cy_atkcombo")
    if self.inst.components.combat ~= nil then
        self.inst.components.combat:SetRange(TUNING.CHONGYUE.AsR2, TUNING.CHONGYUE.AsR2+1)
        SendModRPCToClient(CLIENT_MOD_RPC["cy_client"]["private_circle"], self.inst.userid, true)
    end
end
function cy_qzbs:FinishDown()
    self.inst:RemoveTag("cy_atkcombo")
    if self.inst.components.combat ~= nil then
        self.inst.components.combat:SetRange(2, 2)
        SendModRPCToClient(CLIENT_MOD_RPC["cy_client"]["private_circle"], self.inst.userid, false)
    end
end


function cy_qzbs:DoAtk(num)
    self.tempdt = 0 --刷新战斗状态
    --回复百式值
        local m = num or 1.0
        --local c = math.max(10,self.current)
        local c = self.current
        local t = (-(c * c)/1000) + (c/10)
        t = math.max(t, 1)  --最小值为1
        self:DoDelta(t * m)
        --self:DoDelta(1)
    --攻击回复技力
    self:S1DoDelta(m)
    self:S3DoDelta(m)
    
end

function cy_qzbs:SpawnFx1(num, target)
    --local fx  =  SpawnPrefab("electricchargedfx")
    
    local fx  =  SpawnPrefab("attack_skill_1_fx")
    local x,y,z = target.Transform:GetWorldPosition()
    x = x + math.random() - .5
    y = y + math.random() + .5
    z = z + math.random() - .5
    fx.Transform:SetPosition(x,y,z)
    if num > 1 then
        self.inst:DoTaskInTime(0.1, function()
            self:SpawnFx1(num-1, target)
        end)
    end
end

function cy_qzbs:SpawnFx3(target)
    local x,y,z = target.Transform:GetWorldPosition()
    local fx  =  SpawnPrefab("attack_skill_3_fx")
    fx.Transform:SetPosition(x,y+1,z)
end

function cy_qzbs:GetPercent() --获取百分比
    return self.current / self.max
end

function cy_qzbs:SetPercent(p) --设置百分比
    local old = self.current
    self.current  = p * self.max
    self.inst:PushEvent("cy_qzbsdelta", { oldpercent = old / self.max, newpercent = p})
end

function cy_qzbs:Clear() --清空
    self:SetPercent(0)
    self:SpLFx(0)
    self.s3num = 0
    self:FinishDown()
end

function cy_qzbs:OnUpdate(dt)           --每帧更新
    if not self.ignore  then
        self:Recalc(dt)
    end
    if self.s3num > 0 then
        self.tempdt = self.tempdt or 0
        if self.tempdt > TUNING.CHONGYUE.WWCT then
            self.tempdt = 0
            self.s3num = self.s3num - 1
            self:SpLFx(self.s3num)
            if self.s3num < 5 then
                self:FinishDown()
            end
        else
            self.tempdt = self.tempdt + dt
        end
    end
    
end

function cy_qzbs:Recalc(dt)    --变化
    local x, y, z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, TUNING.CHONGYUE.SUPPLY_RANGE, {"qzbsaura"})
    local aura_val = 0
	for i, v in ipairs(ents) do
	    if v.components.cy_qzbsaura ~= nil and v ~= self.inst and v.components.cy_machine and v.components.cy_machine.ison then
			aura_val = v.components.cy_qzbsaura:GetAura(self.inst)
            if self.inst.sptask == nil and v._fuellevel and v._fuellevel > 0 then
                self:S1DoDelta(1)
                self:S2DoDelta(1)
                self:S3DoDelta(1)
                self.inst.sptask = self.inst:DoTaskInTime(4 - v._fuellevel, function (_inst)
                    if _inst and _inst:IsValid() then
                        _inst.sptask = nil
                    end
                end)
            end
            break --只受一个影响
        end
    end
    if aura_val > 0 then
        dt = - aura_val * dt
    end
    local t = self.ratemult * self.rate
    self:DoDelta(-t * dt,true)
end

cy_qzbs.LongUpdate = cy_qzbs.OnUpdate



--[[
    如果需要别的变量 和方法 看自己需求自己加吧

    ThePlayer.components.cy_qzbs:SetPercent(0.8)

]]

return cy_qzbs
