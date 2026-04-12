GLOBAL.WNAPI = env

--- func desc
---@param inst 发起者
---@param name 名字
---@param time 时间
---@param fn 做什么
function dotask1(inst, name, time, fn)
    if inst[name] ~= nil then
        inst[name]:Cancel()
        inst[name] = nil
    end
    inst[name] = inst:DoTaskInTime(time, fn)
end
--WNAPI.dotask_wxwb(target)
function dotask_wxwb(inst)
    -- if inst.wxwb ~= nil then
    --     inst.wxwb:Cancel()
    --     inst.wxwb = nil
    -- end

    -- inst.wxwb = inst:DoTaskInTime(.1, function()
    --     inst.wxwb:Cancel()
    --     inst.wxwb = nil
    -- end)
    inst.wxwb = true
end
--WNAPI.say_yy(inst)
function say_yy(inst) 
    local t = GetTime()
    if inst.sksdcd_cy == nil or not TUNING.CHONGYUE.SAcd then
        inst.sksdcd_cy = t
    elseif t - inst.sksdcd_cy < TUNING.CHONGYUE.SAcd then   --还在冷却
        return
    else
        inst.sksdcd_cy = t
    end
    inst.SoundEmitter:KillSound("cy_skillsn")
    local randomMin = (TUNING.CHONGYUE.SAtype - 1) * 4 + 1
    local n = math.random(randomMin, randomMin + 3)
    inst.SoundEmitter:PlaySound("cy_music/i11se/hitting"..n, "cy_skillsn") --第二个参数是给这个音效起个名字，用于中断
end



