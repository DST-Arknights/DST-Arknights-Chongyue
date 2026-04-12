local assets =
{
	Asset( "ANIM", "anim/chongyue.zip" ),
	Asset( "ANIM", "anim/ghost_chongyue_build.zip" ),
	Asset( "ANIM", "anim/ghost_chongyue.zip" ),
}

local skins =
{
	normal_skin = "chongyue",
	ghost_skin = "ghost_chongyue_build",
	--ghost_skin = "ghost_chongyue",
}

local base_prefab = "chongyue"

local tags = {"CHONGYUE", "CHARACTER"}

return CreatePrefabSkin("chongyue_none",
{
	base_prefab = base_prefab, 
	skins = skins, 
	assets = assets,
	tags = tags,
	
	skip_item_gen = true,
	skip_giftable_gen = true,
})