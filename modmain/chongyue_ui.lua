--界面部分
local QzbsBadge = require("widgets/qzbsbadge")
local function Add_Qzbs(self)
	if not self.owner or not self.owner:HasTag("chongyue_qzbs") then
		return
	end

	self.chongyue_qzbs = self:AddChild(QzbsBadge(self.owner))
	--self.chongyue_qzbs:SetPosition(-240, 20, 0)

	self.owner:DoTaskInTime(0.5, function()
		local x1, y1, z1 = self.stomach:GetPosition():Get()
		local x2, y2, z2 = self.brain:GetPosition():Get()
		local x3, y3, z3 = self.heart:GetPosition():Get()
		if y2 == y1 or y2 == y3 then --开了三维mod     --再次见到了！很酷的判断方式！--但是好像少一些
			self.chongyue_qzbs:SetPosition(self.stomach:GetPosition() + Vector3(x1 - x2, 0, 0))
			self.boatmeter:SetPosition(self.moisturemeter:GetPosition() + Vector3(x1 - x2, 0, 0))
		else
			self.chongyue_qzbs:SetPosition(self.stomach:GetPosition() + Vector3(x1 - x3, 0, 0))
		end

		local s1 = self.stomach:GetScale().x
		local s2 = self.boatmeter:GetScale().x
		local s3 = self.chongyue_qzbs:GetScale().x
		if s1 ~= s2 then
			self.boatmeter:SetScale(s1 / s2, s1 / s2, s1 / s2)
		end
		if s1 ~= s3 then
			self.chongyue_qzbs:SetScale(s1 / s3, s1 / s3, s1 / s3)
		end
	end)
	--死亡时候的隐藏
	local old_SetGhostMode = self.SetGhostMode
	function self:SetGhostMode(ghostmode, ...)
		old_SetGhostMode(self, ghostmode, ...)
		if ghostmode then
			if self.chongyue_qzbs ~= nil then
				self.chongyue_qzbs:Hide()
			end
		else
			if self.chongyue_qzbs ~= nil then
				self.chongyue_qzbs:Show()
			end
		end
	end
end
AddClassPostConstruct("widgets/statusdisplays", Add_Qzbs)

local wxwb = require("widgets/sptext")                      --sp 3
local function SPtext(self)
	if not self.owner or not self.owner:HasTag("chongyue_qzbs") then --如果没有组件的话
		return
	end
	self.sptext = self:AddChild(wxwb(self.owner))
end

AddClassPostConstruct("widgets/controls", SPtext)