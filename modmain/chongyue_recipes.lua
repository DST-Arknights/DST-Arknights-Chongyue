-- ModAddRecipe2(
-- "cy_portablesupply_item",
-- {
--        Ingredient("gears", 20),
--        Ingredient("trinket_6", 10),
--        Ingredient("torch", 1),
--        Ingredient("transistor", 5),
-- },
-- TECH.MAGIC_TWO,
-- {
--     atlas = "images/inventoryimages/portable_supply.xml",
--     image = "portable_supply.tex",
-- },
-- { "CHARACTER" }
-- )


local Elite1Ingredients = {
  Ingredient("ark_gold", 30000),
  Ingredient("ark_item_mtl_sl_rush2", 8),
  Ingredient("ark_item_mtl_sl_boss2", 3),
}

local Elite2Ingredients = {
  Ingredient("ark_gold", 180000),
  Ingredient("ark_item_mtl_sl_pp", 4),
  Ingredient("ark_item_mtl_sl_iam4", 5),
}

if not TUNING.ARK_CONFIG.enable_all_materials_drop then
  Elite1Ingredients = {
    Ingredient("goldnugget", 30),
    Ingredient("papyrus", 5),
    Ingredient("transistor", 3),
    Ingredient("nightmarefuel", 8),
  }
  Elite2Ingredients = {
    Ingredient("goldnugget", 180),
    Ingredient("papyrus", 8),
    Ingredient("dreadstone", 5),
    Ingredient("opalpreciousgem", 4),
  }
end

AddEliteLevelUpRecipes("chongyue", {{
  ingredients = Elite1Ingredients,
  atlas = "images/ark_elite.xml",
  image = "elite1.tex",
}, {
  ingredients = Elite2Ingredients,
  atlas = "images/ark_elite.xml",
  image = "elite2.tex",
}})
