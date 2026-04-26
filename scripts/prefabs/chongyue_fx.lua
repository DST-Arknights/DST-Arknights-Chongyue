local fxs = { {
  name = "chongyue_skill1_hit_fx",
  bank = "chongyue_skill1_hit_fx",
  build = "chongyue_skill1_hit_fx",
  anim = "0",
  fn = function(inst)
    local n = math.ceil(math.random(2))
    inst.AnimState:PlayAnimation(tostring(n))
    local scale = 2
    inst.AnimState:SetScale(scale, scale)
  end,
}, {
  name = "chongyue_skill2_fx_up",
  bank = "chongyue_skill2_fx",
  build = "chongyue_skill2_fx",
  anim = "up",
  fn = function(inst)
    local scale = 2
    inst.AnimState:SetScale(scale, scale)
  end,
}, {
  name = "chongyue_skill2_fx_down",
  bank = "chongyue_skill2_fx",
  build = "chongyue_skill2_fx",
  anim = "down",
  fn = function(inst)
    local scale = 2
    inst.AnimState:SetScale(scale, scale)
  end,
}, {
  name = "chongyue_skill3_hit_fx",
  bank = "chongyue_skill3_hit_fx",
  build = "chongyue_skill3_hit_fx",
  anim = "anim",
  fn = function(inst)
    local scale = 3
    inst.AnimState:SetScale(scale, scale)
  end,

}, {
  name = "chongyue_talent1_fx",
  bank = "chongyue_talent1_fx",
  build = "chongyue_talent1_fx",
  anim = "anim",
  fn = function(inst)
    local scale = 2
    inst.AnimState:SetScale(scale, scale)
    inst.AnimState:PlayAnimation("anim", true)
    inst.Transform:SetPosition(0, 1, 0)
  end,
  loop = true,

}
}

-- 叠层特效
for i = 1, 5 do
  table.insert(fxs, {
    name = "chongyue_skill3_stacks_fx_" .. i,
    bank = "chongyue_skill3_stacks",
    build = "chongyue_skill3_stacks",
    anim = tostring(i),
    fn = function(inst)
      inst.AnimState:SetSortOrder(-1)
      inst.Transform:SetPosition(0, 2, 0)
    end,
    loop = true,
  })
end
local fxPrefabs = {}
for i, v in pairs(fxs) do
  table.insert(fxPrefabs, ArkMakeFx(v))
end

return unpack(fxPrefabs)
