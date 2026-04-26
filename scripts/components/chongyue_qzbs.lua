local function oncurrentdirty(self, value)
  self.inst.replica.chongyue_qzbs:SetCurrent(math.floor(value))
end

local function onmaxdirty(self, value)
  self.inst.replica.chongyue_qzbs:SetMax(math.floor(value))
end

local ChongyueQzbs = Class(function(self, inst)
  self.inst = inst
  self.current = 0
  self.max = 60
  self.base_rate = TUNING.WILSON_HUNGER_RATE
  self.loss_rate = 1
  self.increase_rate = 0
  self._oncurrent = nil
  self.recently_attack_time = 0
  self:ApplyCurrent()
  local task_frame = 0.3
  self.loss_task = inst:DoPeriodicTask(task_frame, function ()
    local loss = 0
    if GetTime() - self.recently_attack_time >= 5 then
      loss = self.base_rate * self.loss_rate * task_frame
    end
    local increase = self.base_rate * self.increase_rate * task_frame
    self:DoDelta(-loss + increase)
  end)
end, nil, {
  current = oncurrentdirty,
  max = onmaxdirty,
})

function ChongyueQzbs:SetLossRate(rate)
  self.loss_rate = rate
end

function ChongyueQzbs:SetIncreaseRate(rate)
  self.increase_rate = rate
end

function ChongyueQzbs:ApplyCurrent()
  if self._applyTask then
    return
  end
  self._applyTask = self.inst:DoTaskInTime(0, function()
    self._applyTask = nil
    if self._oncurrent then
      self._oncurrent(self.inst, self.current)
    end
  end)
end

function ChongyueQzbs:SetCurrent(current)
  self.current = math.clamp(current, 0, self.max)
  self:ApplyCurrent()
end

function ChongyueQzbs:SetMax(max)
  self.max = math.max(max, 1)
  if self.current > self.max then
    self.current = self.max
    self:ApplyCurrent()
  end
end

function ChongyueQzbs:SetOnCurrent(fn)
  self._oncurrent = fn
end

function ChongyueQzbs:DoDelta(delta)
  local old = self.current
  local new = math.clamp(old + delta, 0, self.max)
  if new == old then
    return
  end
  self:SetCurrent(new)
  self:ApplyCurrent()
end

function ChongyueQzbs:OnSave()
  local data = {
    current = self.current,
    max = self.max,
  }
  return data
end

function ChongyueQzbs:OnLoad(data)
  if data then
    if data.current then
      self.current = data.current
    end
    if data.max then
      self.max = data.max
      if self.current > self.max then
        self.current = self.max
      end
    end
  end
  self:ApplyCurrent()
end

function ChongyueQzbs:OnRemoveFromEntity()
  if self.loss_task then
    self.loss_task:Cancel()
    self.loss_task = nil
  end
end

return ChongyueQzbs
