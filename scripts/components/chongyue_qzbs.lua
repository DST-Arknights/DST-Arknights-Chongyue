local function oncurrentdirty(self, value)
  self.inst.replica.chongyue_qzbs:SetCurrent(math.floor(value))
end

local function onmaxdirty(self, value)
  self.inst.replica.chongyue_qzbs:SetMax(math.floor(value))
end

local LOSS_TASK_FRAME = 0.3
local LOSS_PAUSE_TIME = 3

local ChongyueQzbs = Class(function(self, inst)
  self.inst = inst
  self.current = 0
  self.max = 60
  self.base_rate = TUNING.WILSON_HUNGER_RATE
  self.loss_rate = 1
  self.increase_rate = 0
  self._oncurrent = nil
  self.recently_attack_time = 0
  self.loss_paused_until = 0
  self:ApplyCurrent()
  self.loss_task = inst:DoPeriodicTask(LOSS_TASK_FRAME, function ()
    local loss = 0
    if not self:IsLossPaused() and GetTime() - self.recently_attack_time >= 5 then
      loss = self.base_rate * self.loss_rate * LOSS_TASK_FRAME
    end
    local increase = self.base_rate * self.increase_rate * LOSS_TASK_FRAME
    local delta = increase - loss
    if delta ~= 0 then
      self:DoDelta(delta, { skip_pause = true })
    end
  end)
end, nil, {
  current = oncurrentdirty,
  max = onmaxdirty,
})

function ChongyueQzbs:PauseLoss(duration)
  local pause_until = GetTime() + (duration or LOSS_PAUSE_TIME)
  if pause_until > self.loss_paused_until then
    self.loss_paused_until = pause_until
  end
end

function ChongyueQzbs:IsLossPaused()
  return GetTime() < self.loss_paused_until
end

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

function ChongyueQzbs:SetCurrent(current, opts)
  local new = math.clamp(current, 0, self.max)
  if new == self.current then
    return 0
  end
  local delta = new - self.current
  self.current = new
  if not (opts and opts.skip_pause) then
    self:PauseLoss()
  end
  self:ApplyCurrent()
  return delta
end

function ChongyueQzbs:SetMax(max)
  self.max = math.max(max, 1)
  if self.current > self.max then
    self.current = self.max
    self:PauseLoss()
    self:ApplyCurrent()
  end
end

function ChongyueQzbs:SetOnCurrent(fn)
  self._oncurrent = fn
end

function ChongyueQzbs:DoDelta(delta, opts)
  if delta == 0 then
    return 0
  end
  local old = self.current
  local new = math.clamp(old + delta, 0, self.max)
  if new == old then
    return 0
  end
  return self:SetCurrent(new, opts)
end

function ChongyueQzbs:GetRechargeAmount()
  self:PauseLoss()
  return math.max(self.max - self.current, 0) / 3
end

function ChongyueQzbs:Recharge(amount)
  self:PauseLoss()
  local energyDelta = self:DoDelta((amount or 0) * 3, { skip_pause = true })
  return energyDelta / 3
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
