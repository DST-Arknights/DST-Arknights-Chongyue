local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local P1_TINT = { 248 / 255, 248 / 255, 255 / 255, 1 } --幽灵白
local P2_TINT = { 255 / 255, 140 / 255, 0 / 255, 1 }   --橙色

local Qzbs_Badge = Class(Badge, function(self, owner, art)
    --Badge._ctor(self, "qzbs", owner)
    Badge._ctor(self, nil, owner, P2_TINT, "cyhud", nil, nil, true)

    self.circleframe:GetAnimState():OverrideSymbol("icon", "cyhud", "brain")

    self.current = 0
    self.max = 80
    self:SetPercent(0, self.max)
end)

function Qzbs_Badge:SetMax(max)
    if max == 0 then
        max = 1
    end
    self.max = max
    self:SetPercent(self.current / self.max, self.max)
end

function Qzbs_Badge:SetCurrent(current)
    self.current = current
    self:SetPercent(self.current / self.max, self.max)
end

return Qzbs_Badge
