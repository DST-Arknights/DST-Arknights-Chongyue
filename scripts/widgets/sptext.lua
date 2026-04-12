local  Widget = require "widgets/widget"
local  Image = require "widgets/image"
local Text = require "widgets/text"

local time = 30

AddClientModRPCHandler("i11", "wxwb", function(inst)
	inst:PushEvent("wxwb_st")
end)

local ui = Class(Widget, function(self, owner)
    Widget._ctor(self, nil)
    --self:StartUpdating()

    self.desc = self:AddChild(Text(BODYTEXTFONT, 48))
    self.desc:SetPosition(0, 0, 0)
    
    self.desc:SetString("SP 3")
    --self.desc:SetString(owner.prefab)
    self.desc:SetColour(50/255, 205/255, 50/255,1)
    self.desc:Hide()

    owner:ListenForEvent("wxwb_st",function()
        self:StartUp()
    end)
end)


function ui:StartUp()
    self.desc:SetVAnchor(ANCHOR_MIDDLE)
    self.desc:SetHAnchor(ANCHOR_MIDDLE)
    self.desc:SetPosition(0, 0, 0)
    self.desc:Show()
    self.inst:StartThread(function()

        for i = 1, time  do
            self.desc:SetPosition(0, i * 3, 0)
            Sleep(FRAMES)
        end
        --循环完成后
        self.desc:Hide()
        
    end,self.inst.GUID)

    
end

return ui

