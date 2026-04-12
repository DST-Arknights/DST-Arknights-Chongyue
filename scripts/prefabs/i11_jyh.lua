
local function fn1(inst, builder)
    if builder.components.cy_jyh == nil then
        inst:Remove()
        return
    end

    builder.components.cy_jyh:Jup()

    inst:Remove()
end


local function MakeBuilder(prefab)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst:AddTag("CLASSIFIED")

        --[[Non-networked entity]]
        inst.persists = false

        --Auto-remove if not spawned by builder
        inst:DoTaskInTime(0, inst.Remove)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.OnBuiltFn = fn1

        return inst
    end

    return Prefab(prefab, fn, nil, { prefab })
end

return MakeBuilder("i11_jy1"),MakeBuilder("i11_jy2")