local conveyor_belt = "conveyor_belts:conveyor_belt_off"
local conveyor_belt_on = "conveyor_belts:conveyor_belt_on"
local belt = "conveyor_belt_top.png"
local belt_on = "conveyor_belt_top_on.png"
local panel = "conveyor_belt_side.png"
local panel_on = "conveyor_belt_side_on.png"

local movement_rules = {}
for facedir = 0,23 do
    movement_rules[facedir] = movement_rules[facedir] or {}
    local back = minetest.facedir_to_dir(facedir)
    local front = vector.multiply(back, -1)
    local up = ({[0]={x=0, y=1, z=0},
        {x=0, y=0, z=1},
        {x=0, y=0, z=-1},
        {x=1, y=0, z=0},
        {x=-1, y=0, z=0},
        {x=0, y=-1, z=0}})[math.floor(facedir/4)]
    local right = {x=up.y*back.z - back.y*up.z,
        y=up.z*back.x - back.z*up.x,
        z=up.x*back.y - back.x*up.y}
    local down = vector.multiply(up, -1)
    local left = vector.multiply(right, -1)
    local cw = {
        {up, right},
        {right, down},
        {down, left},
        {left, up}
    }
    local ccw = {
        {up, left},
        {right, up},
        {down, right},
        {left, down}
    }

    local front_above = vector.add(front, up)
    local front_below = vector.add(front, down)
    local front_above2 = vector.add(front_above, up)
    local front_below2 = vector.add(front_below, down)

    local back_above = vector.add(back, up)
    local back_below = vector.add(back, down)
    local back_above2 = vector.add(back_above, up)
    local back_below2 = vector.add(back_below, down)

    movement_rules[facedir][front] = cw
    movement_rules[facedir][front_above] = cw
    movement_rules[facedir][front_below] = cw

    movement_rules[facedir][back] = ccw
    movement_rules[facedir][back_above] = ccw
    movement_rules[facedir][back_below] = ccw

end

local unconveyable = {
    "mesecons_pistons:piston_normal_off",
    "mesecons_pistons:piston_normal_on",
    "mesecons_pistons:piston_pusher_normal",
    "mesecons_pistons:piston_sticky_off",
    "mesecons_pistons:piston_sticky_on",
    "mesecons_pistons:piston_pusher_sticky"
}
local function is_conveyable(nodename)
    if unconveyable[nodename] == nil then
        return minetest.get_item_group(nodename, "not_conveyable") <= 0
    end
    return not unconveyable[nodename]
end

local maxpush = mesecon.setting("conveyor_max_push", 1)
local function conveyor_step(pos, node)
    for wire_pos, rules in pairs(movement_rules[node.param2]) do
        if mesecon.is_power_on(vector.add(pos, wire_pos)) then
            for i, move_vector in pairs(rules) do
                local origin = vector.add(pos, move_vector[1])
                local origin_node = minetest.get_node(origin)
                if is_conveyable(origin_node.name) then
                    local direction = move_vector[2]
                    local success, stack, oldstack = mesecon.mvps_push(origin, direction, maxpush)
                    if success then
                        mesecon.mvps_process_stack(stack)
                        mesecon.mvps_move_objects(origin, direction, oldstack)
                        -- Make an additional check for players whose upper body is in range.
                        local p_below = vector.add(origin, {x=0, y=-1, z=0})
                        local objects = minetest.get_objects_inside_radius(p_below, 1)
                        for _, obj in ipairs(objects) do
                            local entity = obj:get_luaentity()
                            if not entity or not mesecon.is_mvps_unmov(entity.name) then
                                local cp = vector.add(origin, direction)
                                local np = vector.add(obj:getpos(), direction)
                                --move only if destination is not solid
                                local nn = minetest.get_node(cp)
                                if not ((not minetest.registered_nodes[nn.name])
                                or minetest.registered_nodes[nn.name].walkable) then
                                    obj:setpos(np)
                                end
                            end
                        end
                    end
                end
            end
            --return
        end
    end
end

local function conveyor_on(pos, node)
    node.name = conveyor_belt_on
    minetest.set_node(pos, node)
    conveyor_step(pos, node)
end

local function conveyor_off(pos, node)
    node.name = conveyor_belt
    minetest.set_node(pos, node)
end

local conveyor_mesecons = {effector = {
    action_on = conveyor_on,
    action_off = conveyor_off
}}

local function belt_textures(belt, panel)
    return {
        belt.."^[transformR180", 
        belt, 
        belt.."^[transformR90", 
        belt.."^[transformR270", 
        panel, 
        panel
    }
end

minetest.register_node(conveyor_belt, {
    description = "Conveyor Belt",
    tiles = belt_textures(belt, panel),
    paramtype2 = "facedir",
    groups = {conveyor_belt=1, snappy=2, choppy=2, oddly_breakable_by_hand=2, not_conveyable=1},
    sounds = default.node_sound_wood_defaults(),
    drawtype = "normal",
    paramtype = "light",
    mesecons = conveyor_mesecons
})

minetest.register_node(conveyor_belt_on, {
    description = "Conveyor Belt (Active)",
    tiles = belt_textures(belt_on, panel_on),
    paramtype2 = "facedir",
    drop = conveyor_belt,
    groups = {conveyor_belt=1, snappy=2, choppy=2, oddly_breakable_by_hand=2, not_conveyable=1, not_in_creative_inventory=1},
    sounds = default.node_sound_wood_defaults(),
    drawtype = "normal",
    paramtype = "light",
    mesecons = conveyor_mesecons
})

local iron = "default:steel_ingot"
if minetest.get_modpath("technic") then
    local rubber = "technic:rubber"
    local motor = "technic:motor"
    
    minetest.register_craft({
        output = conveyor_belt.." 10",
        recipe = {
            {rubber,rubber,rubber},
            {iron, motor, iron},
            {rubber,rubber,rubber},
        }
    }) 
end

local fiber = 'mesecons_materials:fiber'
local movestone = 'mesecons_movestones:movestone'
minetest.register_craft({
    output = conveyor_belt.." 3",
    recipe = {
        {fiber,fiber,fiber},
        {iron, movestone, iron},
        {fiber,fiber,fiber},
    }
}) 
