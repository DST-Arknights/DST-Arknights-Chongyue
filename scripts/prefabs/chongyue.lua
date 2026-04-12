
local MakePlayerCharacter = require "prefabs/player_common"


local assets = {

        Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),

        Asset( "ANIM", "anim/chongyue.zip" ),

        Asset( "ANIM", "anim/ghost_chongyue_build.zip" ),
	Asset( "ANIM", "anim/ghost_chongyue.zip" ),	
}

local function onbecamehuman(inst,data)
        --复活后获得50点
        --不行，大部分复活莫得data
                if inst.components.cy_qzbs ~= nil then
                        inst.components.cy_qzbs:DoDelta(50)
                end

        
        --inst:Show()
end

local function onbecameghost(inst)
        --死亡后会失去所有百式
        if inst.components.cy_qzbs ~= nil then
                inst.components.cy_qzbs:Clear()
        end
        --inst:Hide()
end

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.CHONGYUE
end
local prefabs = FlattenTree(start_inv, true)
local function onload(inst)     
        inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
        inst:ListenForEvent("ms_becameghost", onbecameghost)

        if inst:HasTag("playerghost") then
                onbecameghost(inst)
        else
                onbecamehuman(inst)
        end
end
local function onnewspawn(inst)	--玩家初次降临时
	onload(inst)
        inst:AddTag("cy_ksl")   --自然是空手状态

        local startlv = TUNING.CHONGYUE.startlv
        if startlv and startlv > 0 then
                inst.components.cy_jyh:Jup()
                if startlv > 1 then
                        inst.components.cy_jyh:Jup()
                end
        end
end
----
local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "chongyue.tex" )
        inst:AddTag("chongyue")

        inst:AddTag("i11_build")        --制作专属物品的tag
	inst.net_qzbs = net_shortint(inst.GUID,"player.qzbs","i11dirty")--[-32767..32767]
	inst.net_qzbsmax = net_shortint(inst.GUID,"player.qzbsmax","i11maxdirty")

        inst.net_cys1 = net_shortint(inst.GUID,"player.qzbss1")
        inst.net_cys2 = net_shortint(inst.GUID,"player.qzbss2")
        inst.net_cys3 = net_shortint(inst.GUID,"player.qzbss3")
        inst.net_cysmax1 = net_shortint(inst.GUID,"player.qzbssmax1")
        inst.net_cysmax2 = net_shortint(inst.GUID,"player.qzbssmax2")
        inst.net_cysmax3 = net_shortint(inst.GUID,"player.qzbssmax3")
        --inst.net_wxwb = net_bool(inst.GUID,"player.wxwb","wxwbdirty")
        inst.net_cyjyh = net_tinybyte(inst.GUID,"player.cyjyh") --[0~7]
        inst.net_cyjyh:set(0)

        inst.net_cy_ptas = net_float(inst.GUID,"player.cy_ptas")
end
-- server only
local master_postinit = function(inst)

        inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
            
        inst.soundsname = "wilson"
            
        inst:AddTag("cy_ksl")

        inst.components.health:SetMaxHealth(TUNING.CHONGYUE_HEALTH)
        inst.components.hunger:SetMax(TUNING.CHONGYUE_HUNGER)
        inst.components.sanity:SetMax(TUNING.CHONGYUE_SANITY)
    
        inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "chongyue_speed", TUNING.CHONGYUE.SPEED)

        inst:AddComponent("cy_qzbs")
        inst.components.cy_qzbs.rate = TUNING.WILSON_HUNGER_RATE / 2    --饥饿速度的一半
        inst:AddComponent("cy_jyh")
            
        inst.OnLoad = onload
        inst.OnNewSpawn = onnewspawn
            
    end
return MakePlayerCharacter("chongyue", prefabs, assets, common_postinit, master_postinit, prefabs)
