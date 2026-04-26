function mi(str)
    modimport("scripts/mains/" .. str)
end
--再分

mi("assets")      --加载资源
mi("api")           --可以全局调用的方法放到这里标注好
mi("tuning")      --可调整数值
mi("strings")     --描述
mi("actions")     --描述
mi("hook")          --我喜欢在这里给玩家添加能力
mi("hook2")         --其他修改放在这里
mi("skill")         --按键触发的技能在这里实现
mi("sg")            --这里创造状态
mi("ui")

mi("recipes")       --制作配方 配方要写在科技定义之后

table.insert(GLOBAL.CHARACTER_GENDERS.MALE, "chongyue")
AddModCharacter("chongyue", "MALE")--人物性别定义

