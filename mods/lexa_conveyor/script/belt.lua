local collision_boxes = {
	vertical_bottom = {
		{ -7/16, -8/16, -8/16, 7/16, 0, 8/16 },
		{ -7/16, 0/16, 4/16, 7/16, 8/16, 8/16 },
		{ -7/16, 0/16, 0, 7/16, 4/16, 4/16 }
	},
	vertical_mid = {
		{ -7/16, -8/16, -4/16, 7/16, 0, 8/16 },
		{ -7/16, 0/16, 4/16, 7/16, 8/16, 8/16 },
		{ -7/16, 0/16, 0, 7/16, 4/16, 4/16 },
		{ -7/16, -8/16, -8/16, 7/16, -4/16, -4/16 }
	},
	vertical_top = {
		{ -7/16, -8/16, -4/16, 7/16, 0, 8/16 },
		{ -7/16, -8/16, -8/16, 7/16, -4/16, -4/16 }
	},
	horizontal = { -7/16, -8/16, -8/16, 7/16, 0, 8/16 }
}

local conveyor_functions = {
	horizontal = function(node_pos, item, delta)
		local node = minetest.get_node(node_pos)
		local dir = minetest.facedir_to_dir(node.param2)
		local obj_pos = item.object:get_pos()
		local obj_vel = item.object:get_velocity()
		local obj_pos_rel = vector.subtract(obj_pos, node_pos)

		if obj_pos_rel.y > 0.5 then
			-- Make the item fall if it's not on the surface of the block.
			obj_vel.y = obj_vel.y - 9.8 * delta
			item.object:set_velocity(obj_vel)
		elseif obj_pos_rel.y < 0.5 then
			-- Put it back on the block if it's below the surface, set vel.y to 0.
			obj_pos.y = node_pos.y + 0.5
			obj_vel.y = 0
			item.object:set_pos(obj_pos)
			item.object:set_velocity(obj_vel)
		else
			-- Move the item along the conveyor's normal towards the middle.
			local main_axis = dir.x ~= 0 and 'x' or 'z'
			local norm_axis = dir.x == 0 and 'x' or 'z'

			if obj_pos_rel[norm_axis] > 0.05 then
				obj_vel[norm_axis] = -1 * lexa.conveyor.speed
			elseif obj_pos_rel[norm_axis] < -0.05 then
				obj_vel[norm_axis] = lexa.conveyor.speed
			else
				obj_vel[norm_axis] = 0

				-- Move the item along the conveyor's direction.
				obj_vel[main_axis] = dir[main_axis] * lexa.conveyor.speed
			end

			item.object:set_velocity(obj_vel)
		end
	end
}

minetest.override_item('air', {
	_conveyor_function = function(pos, item, delta)
		local obj_vel = item.object:get_velocity()
		obj_vel.y = obj_vel.y - 9.8 * delta
		item.object:set_velocity(obj_vel)
	end
})

local selection_boxes = {
	vertical_mid = { -7/16, -8/16, -8/16, 7/16, 8/16, 8/16 },
	vertical_bottom = { -7/16, -8/16, -8/16, 7/16, 8/16, 8/16 },
	horizontal = { -7/16, -8/16, -8/16, 7/16, 0, 8/16 }
}

local merge_check_dirs = {
	{ x = -1, y = 0, z = 0 },
	{ x = 1, y = 0, z = 0 },
	{ x = 0, y = 0, z = -1 },
	{ x = 0, y = 0, z = 1 },
	{ x = -1, y = 1, z = 0 },
	{ x = 1, y = 1, z = 0 },
	{ x = 0, y = 1, z = -1 },
	{ x = 0, y = 1, z = 1 }
}

function pos_is_conveyor(pos, dir)
	local node = minetest.get_node(pos)
	if dir ~= nil and dir ~= node.param2 then return 0 end
	return ((minetest.registered_nodes[node.name] or {}).groups or {}).conveyor or 0
end

function handle_update_conveyors(pos, update_neighbors)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local type = node.name:match('vertical') and 2 or 1

	local adj = {
		front = pos_is_conveyor(vector.add(pos, dir), node.param2),
		back = pos_is_conveyor(vector.subtract(pos, dir), node.param2),
		above = pos_is_conveyor(vector.add(vector.add(pos, dir), { x = 0, y = 1, z = 0 }), node.param2),
		below = pos_is_conveyor(vector.add(vector.subtract(pos, dir), { x = 0, y = -1, z = 0 }), node.param2),
	}

	local type_changed = false

	if adj.above ~= 0 or adj.below ~= 0 then
		if adj.above ~= 0 and adj.below ~= 0 then
			minetest.swap_node(pos, { name = 'lexa_conveyor:belt_vertical_mid', param2 = node.param2 })
		elseif adj.above ~= 0 then
			minetest.swap_node(pos, { name = 'lexa_conveyor:belt_vertical_bottom', param2 = node.param2 })
		elseif adj.below ~= 0 then
			minetest.swap_node(pos, { name = 'lexa_conveyor:belt_vertical_top', param2 = node.param2 })
		end

		if type == 1 then type_changed = true end
	else
		if adj.front == 1 and adj.back == 1 then
			minetest.swap_node(pos, { name = 'lexa_conveyor:belt_horizontal_mid', param2 = node.param2 })
		elseif adj.front == 1 then
			minetest.swap_node(pos, { name = 'lexa_conveyor:belt_horizontal_start', param2 = node.param2 })
		elseif adj.back == 1 then
			minetest.swap_node(pos, { name = 'lexa_conveyor:belt_horizontal_end', param2 = node.param2 })
		else
			minetest.swap_node(pos, { name = 'lexa_conveyor:belt_mono', param2 = node.param2 })
		end

		if type == 2 then type_changed = true end
	end

	if update_neighbors or type_changed then
		if adj.front ~= 0 then
			handle_update_conveyors(vector.add(pos, dir))
		end
		if adj.back ~= 0 then
			handle_update_conveyors(vector.subtract(pos, dir))
		end
		if adj.above ~= 0 then
			handle_update_conveyors(vector.add(vector.add(pos, dir), { x = 0, y = 1, z = 0 }))
		end
		if adj.below ~= 0 then
			handle_update_conveyors(vector.add(vector.subtract(pos, dir), { x = 0, y = -1, z = 0 }))
		end
	end
end

function handle_construct_conveyor(pos)
	handle_update_conveyors(pos, true)
end

function handle_destruct_conveyor(pos, node)
	local dir = minetest.facedir_to_dir(node.param2)

	local adj = {
		front = pos_is_conveyor(vector.add(pos, dir)),
		back = pos_is_conveyor(vector.subtract(pos, dir)),
		above = pos_is_conveyor(vector.add(vector.add(pos, dir), { x = 0, y = 1, z = 0 })),
		below = pos_is_conveyor(vector.add(vector.subtract(pos, dir), { x = 0, y = -1, z = 0 })),
	}

	if adj.front ~= 0 then
		handle_update_conveyors(vector.add(pos, dir))
	end
	if adj.back ~= 0 then
		handle_update_conveyors(vector.subtract(pos, dir))
	end
	if adj.above ~= 0 then
		handle_update_conveyors(vector.add(vector.add(pos, dir), { x = 0, y = 1, z = 0 }))
	end
	if adj.below ~= 0 then
		handle_update_conveyors(vector.add(vector.subtract(pos, dir), { x = 0, y = -1, z = 0 }))
	end
end

local build_cost = { copper = 2 }

for _, type in ipairs({ 'horizontal_start', 'horizontal_mid', 'horizontal_end',
	'mono', 'vertical_bottom', 'vertical_mid', 'vertical_top' }) do

	local collision_box = collision_boxes[type] or collision_boxes.horizontal
	local selection_box = selection_boxes[type] or selection_boxes.horizontal

	minetest.register_node('lexa_conveyor:belt_' .. type, {
		drawtype = 'mesh',
		mesh = 'lexa_conveyor_belt_' .. type .. '.b3d',
		tiles = { { name = 'lexa_conveyor_belt_strip.png', animation = {
			type = 'vertical_frames',
			aspect_w = 14,
			aspect_h = 8,
			length = 0.25
		} }, 'lexa_conveyor_belt_frame.png' },
		description = 'Belt',
		_cost = build_cost,
		selection_box = {
			type = 'fixed',
			fixed = selection_box
		},
		collision_box = {
			type = 'fixed',
			fixed = collision_box
		},
		paramtype = 'light',
		paramtype2 = 'facedir',
		sunlight_propagates = true,
		groups = {
			dig_game = 1,
			conveyor = type:match('vertical') and 2 or 1,
			not_in_creative_inventory = type ~= 'mono' and 1 or 0,
			enemy_target = 70
		},
		_conveyor_function = conveyor_functions[type] or conveyor_functions.horizontal,
		drop = '',
		on_place = lexa.materials.place(build_cost),
		on_dig = lexa.materials.dig(build_cost),
		on_construct = handle_construct_conveyor,
		after_destruct = handle_destruct_conveyor
	})
end

