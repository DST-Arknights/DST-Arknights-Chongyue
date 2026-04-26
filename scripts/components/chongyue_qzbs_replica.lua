local SafeCallQzbsBadge = GenSafeCall(function(player)
  return player.HUD and player.HUD.controls and player.HUD.controls.status and player.HUD.controls.status.chongyue_qzbs
end)

local ChongyueQzbsReplica = Class(function(self, inst)
  self.inst = inst
  self.state = NetState(self.inst, 'chongyue_qzbs')
  self.state:Watch("max", function()
    SafeCallQzbsBadge(self.inst):SetMax(self.state.max)
  end)
  self.state:Watch("current", function()
    SafeCallQzbsBadge(self.inst):SetCurrent(self.state.current)
  end)
end)

function ChongyueQzbsReplica:SetMax(max)
  self.state.max = max
end

function ChongyueQzbsReplica:SetCurrent(current)
  self.state.current = current
end

return ChongyueQzbsReplica
