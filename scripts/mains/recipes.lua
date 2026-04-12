--     name = "log", --配方名，一般情况下和需要合成的道具同名
        --     ingredients = {
        --         Ingredient("pinecone", 10)
        --     },
        --     tab = CUSTOM_RECIPETABS.TAB_MY_ONE, --制作栏的分类，比如：生存栏、建造栏等
        --     -- tab = RECIPETABS.REFINE,
        --     level = TECH.NONE, --科技等级
        --     placer = {no_deconstruction = true}, --建筑类科技放置时显示的贴图、占位等/也可以配List用于添加更多额外参数，比如不可分解{no_deconstruction = true}
        --     min_spacing = nil, --最小间隔，不填默认为3.2
        --     nounlock = nil, --是否可以离开制作台制作，nil则可以离开制作台。
        --     numtogive = 10, --制作数量，若填nil则为制作1个。
        --     builder_tag = nil, --制作者需要拥有的Tag（标签），填nil则所有人都可以做
        --     atlas = nil, --需要用到的图集文件(.xml)，不填默认用images/name.xml
        --     image = nil --物品贴图(.tex)，不填默认用name.tex
        --     -- testfn = , --自定义检测函数，需要满足该函数才能制作物品，不常用。比如：尝试放下物品时的函数，可用于判断坐标点是否符合预期。
        --     -- product,--实际合成道具，不填默认取name
        --     -- needHidden,--简易模式隐藏
        --     -- noatlas,--不需要图集文件
        --     -- noimage,--不需要贴图
        -- },


local function ModAddRecipe2(name, ingredients, tech, config, filters, ...)
    if config then
        --    if config.atlas == nil and config.image == nil then
        --           config.image = name .. ".tex"
        --           config.atlas = "images/iii/" .. name .. ".xml"
        --    end
           if config.builder_tag == nil then
                  config.builder_tag = "i11_build"
           end
    end

    return AddRecipe2(name, ingredients, tech, config, filters, ...)
end

ModAddRecipe2(
"i11_jy1",
{
       Ingredient("goldnugget", 30),
       Ingredient("papyrus", 5),
       Ingredient("transistor", 3),
       Ingredient("nightmarefuel", 8),
},
TECH.MAGIC_TWO,
{
    canbuild = function(inst, builder)      --精英化0阶才可以做哦
        return (builder.components.cy_jyh and builder.components.cy_jyh:IsJ(0))
    end,
    atlas = "images/inventoryimages/mudrock_elite_book1.xml",
    image = "mudrock_elite_book1.tex",
    sg_state="book"
},
{ "CHARACTER" }
)

ModAddRecipe2(
"i11_jy2",
{
       Ingredient("goldnugget", 180),
       Ingredient("papyrus", 8),
       Ingredient("dreadstone", 5),
       Ingredient("opalpreciousgem", 4),
},
TECH.MAGIC_THREE,
{
    canbuild = function(inst, builder)      --精英化1阶才可以做哦
        return (builder.components.cy_jyh and builder.components.cy_jyh:IsJ(1))
    end,
    atlas = "images/inventoryimages/mudrock_elite_book2.xml",
    image = "mudrock_elite_book2.tex",
    sg_state="book"
},
{ "CHARACTER" }
)

ModAddRecipe2(
"cy_portablesupply_item",
{
       Ingredient("gears", 20),
       Ingredient("trinket_6", 10),
       Ingredient("torch", 1),
       Ingredient("transistor", 5),
},
TECH.MAGIC_TWO,
{
    atlas = "images/inventoryimages/portable_supply.xml",
    image = "portable_supply.tex",
},
{ "CHARACTER" }
)

