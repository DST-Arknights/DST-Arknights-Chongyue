local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local P1_TINT = { 248 / 255, 248 / 255, 255 / 255, 1 }      --幽灵白
local P2_TINT = { 255 / 255, 140 / 255, 0 / 255, 1 }        --橙色

local Qzbs_Badge = Class(Badge, function(self, owner, art)
    --Badge._ctor(self, "qzbs", owner)
    Badge._ctor(self, nil, owner, P2_TINT, "cyhud", nil, nil, true)

    self.circleframe:GetAnimState():OverrideSymbol("icon", "cyhud", "brain")

    self.val = 60
    self.max = 80

    self.owner:ListenForEvent("i11dirty", function()
        self.val = self.owner.net_qzbs:value()
        self:SetPercent(self.val/self.max,self.max)
    end)
    self.owner:ListenForEvent("i11maxdirty", function()
        self.max = self.owner.net_qzbsmax:value()
        self:SetPercent(self.val/self.max,self.max)
    end)
end)

return Qzbs_Badge
