local assets=
{
	Asset("ANIM", "anim/private_anim.zip"),
	Asset("ANIM", "anim/firefighter_range.zip")
}

local function SetScale(inst,n)
	inst.Transform:SetScale(n,n,n)
end

local function PlayAnim(inst,anim,bool)
	inst.AnimState:PlayAnimation(anim,bool)
end

local function pos(inst,add_x,add_y)
	local x,y,z = inst.Transform:GetWorldPosition()
	inst.Transform:SetPosition(x+add_x,y,z+add_y)
end

local SCALE_RAD = {1.3, 1.8, 2.2, 2.55, 2.84, 3.11, 3.34, 3.6, 3.81, 4, 4.2, 4.39, 4.56, 4.75, 4.9} -- 1-15
local function ScaleRanFn(r)
	local Scale = SCALE_RAD[r]
	return Scale or (r*1.6)^.5
end

local function SetRadius(inst,r)
	r = r or 0
	local scale = ScaleRanFn(r) or 1
	local xishu = .16
	if r > 10 then
		local anim = inst.entity:AddAnimState()
		anim:SetBank("firefighter_placement")
		anim:SetBuild("firefighter_range")
		anim:PlayAnimation("idle")
		scale = (r*xishu)^.5
	end
	inst.Transform:SetScale(scale,scale,scale)
end

local function fn_private_circle(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.SetScale = SetScale
	inst.SetRadius = SetRadius
	--inst.Transform:SetRotation(45)
	inst.pos = pos
	inst.colours={1,1,1,1} --default inst.AnimState:OverrideMultColour
	
	anim:SetBank("firefighter_placement")
	anim:SetBuild("firefighter_range")
	anim:PlayAnimation("idle") --red/green/blue, circle, left/right, up
	inst.PlayAnim = PlayAnim
	
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	
	inst.persists = false
	inst:AddTag("fx")
	inst:AddTag("notarget")
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	--inst:AddTag("DECOR")

	return inst
end

return Prefab("cy_private_circle", fn_private_circle, assets)