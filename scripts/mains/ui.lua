--界面部分
local QzbsBadge = require("widgets/qzbsbadge")
local function Add_Qzbs(self) 
    if not self.owner or not self.owner:HasTag("cy_qzbs") then     --如果没有组件的话
        return
    end

	self.qzbs = self:AddChild(QzbsBadge(self.owner))
    --self.qzbs:SetPosition(-240, 20, 0)
	
	self.owner:DoTaskInTime(0.5, function()
		local x1 ,y1,z1 = self.stomach:GetPosition():Get()
		local x2 ,y2,z2 = self.brain:GetPosition():Get()		
		local x3 ,y3,z3 = self.heart:GetPosition():Get()		
		if y2 == y1 or  y2 == y3 then --开了三维mod     --再次见到了！很酷的判断方式！--但是好像少一些
			self.qzbs:SetPosition(self.stomach:GetPosition() + Vector3(x1-x2, 0, 0))
            self.boatmeter:SetPosition(self.moisturemeter:GetPosition() + Vector3(x1-x2, 0, 0))
		else
			self.qzbs:SetPosition(self.stomach:GetPosition() + Vector3(x1-x3, 0, 0))
		end
        
        local s1 = self.stomach:GetScale().x
        local s2 = self.boatmeter:GetScale().x
        local s3 = self.qzbs:GetScale().x
        if s1 ~= s2 then
            self.boatmeter:SetScale(s1/s2,s1/s2,s1/s2)
        end
        if s1 ~= s3 then
            self.qzbs:SetScale(s1/s3,s1/s3,s1/s3)
        end
	end)


	--监听事件 刷新数据     --牡蛎鸭
	-- self.inst:ListenForEvent("qzbsdelta", function(inst,data)
	-- 	self.qzbs:SetPercent(data, self.owner.replica.qzbs:Max())
	-- end,self.owner)
	--self.qzbs:SetPercent(self.owner.replica.qzbs:GetPercent(), self.owner.replica.qzbs:Max())

	--死亡时候的隐藏
	local old_SetGhostMode = self.SetGhostMode
	function self:SetGhostMode(ghostmode,...)
		old_SetGhostMode(self,ghostmode,...)
		if ghostmode then		
			if self.qzbs ~= nil then 
				self.qzbs:Hide()
			end	
		else
			if self.qzbs ~= nil then
				self.qzbs:Show()
			end
		end
	end
end
AddClassPostConstruct("widgets/statusdisplays", Add_Qzbs)

local wxwb = require("widgets/sptext")			--sp 3
local function SPtext(self)
	if not self.owner or not self.owner:HasTag("cy_qzbs") then     --如果没有组件的话
        return
    end
	self.sptext = self:AddChild(wxwb(self.owner))
end

AddClassPostConstruct("widgets/controls", SPtext)

local CY_SkillBadge = require "widgets/i11_skill_badge"
local scale = 1
local HAnchor = TUNING.CHONGYUE.skill_badge_position[1]
local VAnchor = TUNING.CHONGYUE.skill_badge_position[2]
local position = TUNING.CHONGYUE.skill_badge_position[3]
local function AddCY_SkillBadge(self)
    if not self.owner or not self.owner:HasTag("cy_qzbs") then
		return
	end
	local x,y,z = unpack(position)
	for i=1,3 do
		self["cy_skill"..i] = self:AddChild(CY_SkillBadge(self.owner, scale, i))
		self["cy_skill"..i]:SetHAnchor(HAnchor)
		self["cy_skill"..i]:SetVAnchor(VAnchor)
		self["cy_skill"..i]:SetPosition(x +(75 * i * scale) , y, z)

		self.owner:DoTaskInTime(0, function()
			self["cy_skill"..i]:SetInit()
		end)
	end
	

end
AddClassPostConstruct("widgets/controls", AddCY_SkillBadge)
