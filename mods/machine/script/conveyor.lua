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
	_default = { -7/16, -8/16, -8/16, 7/16, 0, 8/16 }
}

local selection_boxes = {
	vertical_mid = { -7/16, -8/16, -8/16, 7/16, 8/16, 8/16 },
	vertical_bottom = { -7/16, -8/16, -8/16, 7/16, 8/16, 8/16 },
	_default = { -7/16, -8/16, -8/16, 7/16, 0, 8/16 }
}

local merge_check_dirs = {
	{ x = -1, y = 0, z = 0 },
	{ x = 1, y = 0, z = 0 },
	{ x = 0, y = 0, z = -1 },
	{ x = 0, y = 0, z = 1 },
	{ x = -1, y = 1, z = 0},
	{ x = 1, y = 1, z = 0},
	{ x = 0, y = 1, z = -1},
	{ x = 0, y = 1, z = 1}
}

function pos_is_conveyor(pos, dir)
	local node = minetest.get_node(pos)
	if dir ~= node.param2 then return 0 end
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
			minetest.swap_node(pos, { name = 'machine:conveyor_vertical_mid', param2 = node.param2 })
		elseif adj.above ~= 0 then
			minetest.swap_node(pos, { name = 'machine:conveyor_vertical_bottom', param2 = node.param2 })
		elseif adj.below ~= 0 then
			minetest.swap_node(pos, { name = 'machine:conveyor_vertical_top', param2 = node.param2 })
		end

		if type == 1 then type_changed = true end
	else
		if adj.front == 1 and adj.back == 1 then
			minetest.swap_node(pos, { name = 'machine:conveyor_horizontal_mid', param2 = node.param2 })
		elseif adj.front == 1 then
			minetest.swap_node(pos, { name = 'machine:conveyor_horizontal_start', param2 = node.param2 })
		elseif adj.back == 1 then
			minetest.swap_node(pos, { name = 'machine:conveyor_horizontal_end', param2 = node.param2 })
		else
			minetest.swap_node(pos, { name = 'machine:conveyor_mono', param2 = node.param2 })
		end

		if type == 2 then type_changed = true end
	end

	if update_neighbors or type_changed then
		if adj.front ~= 0 then
			handle_update_conveyors(vector.add(pos, dir), false)
		end
		if adj.back ~= 0 then
			handle_update_conveyors(vector.subtract(pos, dir), false)
		end
		if adj.above ~= 0 then
			handle_update_conveyors(vector.add(vector.add(pos, dir), { x = 0, y = 1, z = 0 }), false)
		end
		if adj.below ~= 0 then
			handle_update_conveyors(vector.add(vector.subtract(pos, dir), { x = 0, y = -1, z = 0 }), false)
		end
	end
end

for _, type in ipairs({ 'horizontal_start', 'horizontal_mid', 'horizontal_end',
	'mono', 'vertical_bottom', 'vertical_mid', 'vertical_top' }) do

	local collision_box = collision_boxes[type] or collision_boxes._default
	local selection_box = selection_boxes[type] or selection_boxes._default

	minetest.register_node('machine:conveyor_' .. type, {
		drawtype = 'mesh',
		mesh = 'machine_conveyor_' .. type .. '.b3d',
		tiles = { { name = 'machine_conveyor_belt_strip.png', animation = {
			type = 'vertical_frames',
			aspect_w = 14,
			aspect_h = 8,
			length = 0.25
		} }, 'machine_conveyor_frame.png' },
		description = type == 'mono' and 'Conveyor Belt' or nil,
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
			conveyor = type:match('vertical') and 2 or 1,
			oddly_breakable_by_hand = 3,
			not_in_creative_inventory = type ~= 'mono' and 1 or 0
		},
		after_place_node = function(pos) handle_update_conveyors(pos, true) end
	})
end

