local Widget = require "widgets/widget"
local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local P1_TINT = { 248 / 255, 248 / 255, 255 / 255, 1 }      --幽灵白
local P2_TINT = { 0 / 255, 0 / 255, 0 / 255, 0.4 } 

local CY_SkillBadge = Class(Badge, function(self, owner, scale, nid)

    -- 更改anim后必须重启游戏才可以正常显示，更新模组只会加载资源，还会有些问题
    -- 不同文件夹的图片名字如果一样，会出现识别不出来的问题


    Badge._ctor(self, nil, owner, P2_TINT, "cy_skill_b", nil, nil, true)

    self.owner = owner
    
    
    self.dont_animate_circleframe = true    --让官方方法不更新这个
    --self["skill"..nid] = self:AddChild(UIAnim())
    --self["skill"..nid]:GetAnimState():SetFinalOffset(0)
    --self.anim:GetAnimState():SetFinalOffset(1)
    self.backing:GetAnimState():SetBank("skill_"..nid)
    self.backing:GetAnimState():SetBuild("cy_skill_b")
    --self.backing:GetAnimState():PlayAnimation("anim")
    self.backing:GetAnimState():AnimateWhilePaused(false)
    self.backing:SetScale(scale, scale, 1)
    --self["skill"..nid]:GetAnimState():OverrideSymbol("n1", "cy_skill_b", "n"..nid)
    --self[skill_icon]:SetClickable(true)    
    --self["skill"..nid]:SetPosition(0, 0, 0)  
    --self.num:SetPosition(-17, 17, 0) 
    --self[skill_icon]:SetPercent("anim", 0)
    --self.backing:GetAnimState():OverrideSymbol("bg", "cy_skill_b", "n2")
    --self.backing:GetAnimState():OverrideSymbol("icon", "cy_skill_b", "icon")
    self.skillnum = self:AddChild(UIAnim())
    self.skillnum:GetAnimState():SetBank("num")
    self.skillnum:GetAnimState():SetBuild("cy_skill_b")
    self.skillnum:GetAnimState():PlayAnimation("a1")
    self.skillnum:SetScale(scale, scale, 1)
    self.skillnum:SetPosition(0, 32, 0)  
    self.skillnum:Hide()

    self.nid = nid
    self.elite_state = 0
    self.val = -1
    self.max = 1

    self:StartUpdating()
end)


-- function CY_SkillBadge:SetPercent(percent)
--     self["skill"..self.nid]:GetAnimState():SetPercent("anim", percent)
-- end

--初始化
function CY_SkillBadge:SetInit()

end

local oname = "num"
local function numsetanim(self, num)
    self.skillnum:Show()
    self.skillnum:GetAnimState():PlayAnimation("a"..num)
end

function CY_SkillBadge:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end    --暂停时
    if self.owner.net_cyjyh == nil then
        return
    end
    self.jyh = self.owner.net_cyjyh:value()
    if self.jyh == 0 then
        if self.nid == 2 then
            self.backing:GetAnimState():SetBank("skill_"..self.nid)
            self.backing:GetAnimState():PlayAnimation("lock")
            self:SetPercent(0, 1)
            self.num:SetString("Lock")
            self.percent = 0
            return
        elseif self.nid == 3 then
            self.backing:GetAnimState():SetBank("skill_"..self.nid)
            self.backing:GetAnimState():PlayAnimation("lock")
            self:SetPercent(0, 1)
            self.num:SetString("Lock")
            self.percent = 0
            return
        end
    elseif self.jyh == 1 then
        if self.nid == 3 then
            self.backing:GetAnimState():PlayAnimation("lock")
            self:SetPercent(0, 1)
            self.num:SetString("Lock")
            self.percent = 0
            return
        end
    end

    self.backing:GetAnimState():PlayAnimation("anim")

    local c = self.owner["net_cys"..self.nid]:value() or 0
    local m = self.owner["net_cysmax"..self.nid]:value() or 1
    
    local cn 
    local full = c == m
    local ready
    if self.nid == 1 then   --可充能三次
        cn = 3          --总次数
        m = m / cn      --单次所需
        ready = c >= m  --是否可以使用
        if full then
            --self.skillnum:GetAnimState():OverrideSymbol("skill1", "cy_skill_b", "n3")
            numsetanim(self, 3)
        elseif c >= 2*m then
            --self.skillnum:GetAnimState():OverrideSymbol("skill1", "cy_skill_b", "n2")
            numsetanim(self, 2)
        elseif ready then
            --self.skillnum:GetAnimState():OverrideSymbol("skill1", "cy_skill_b", "n1")
            numsetanim(self, 1)
        else
            self.skillnum:Hide()
        end
        c = c % m       --当前充能量
    elseif self.nid == 2 then       --可充能2次
        cn = 2
        m = m / cn
        ready = c >= m
        if full then
            --self.skillnum:GetAnimState():OverrideSymbol("skill1", "cy_skill_b", "n2")
            numsetanim(self, 2)
        elseif ready then
            --self.skillnum:GetAnimState():OverrideSymbol("skill1", "cy_skill_b", "n1")
            numsetanim(self, 1)
        else
            self.skillnum:Hide()
        end
        c = c % m
    else
        self.skillnum:Hide()
    end
    if full then    --补丁
        c = m
        ready = true
    end
    self.val = c
    self.max = m
    --动画反向设置
    self:SetPercent(1 - (c/m), m)

    self.percent = c/m
    if ready then
        self.num:SetString("Ready")
    else
        self.num:SetString(tostring(math.ceil(c)))
    end
    
    
end


return CY_SkillBadge