--一键GLOBAL，其他地方就不用写了
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
--ww
--咱喜欢分成单独文件
modimport("scripts/init.lua")
