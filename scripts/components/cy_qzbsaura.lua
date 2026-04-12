local qzbsaura = Class(function(self, inst) --回复千招百式的光环组件
    self.inst = inst
    self.aura = 0

	self.inst:AddTag("qzbsaura")
end)

function qzbsaura:OnRemoveFromEntity()
	self.inst:RemoveTag("qzbsaura")
end

function qzbsaura:GetAura(observer)
	local aura_val = 0
	local distsq = observer:GetDistanceSqToInst(self.inst)
	if distsq then
		print("距离是："..distsq)
	end
	distsq = math.sqrt(distsq)
	if distsq <= TUNING.CHONGYUE.SUPPLY_RANGE then
		-- 基础倍率
	    aura_val = (TUNING.CHONGYUE.SUPPLY_RANGE - math.max(1, distsq)) * TUNING.CHONGYUE.QZBSAURA / math.max(1, TUNING.CHONGYUE.SUPPLY_RANGE - 1)
		-- 燃料附赠
		aura_val = self.inst._fuellevel and aura_val * (1 + math.clamp((self.inst._fuellevel - 1), 0, 2) * TUNING.CHONGYUE.QZBSAURA_FULED)
	end
    return aura_val
end

return qzbsaura