-- function pos_is_wall(pos)
-- 	local node = minetest.get_node(pos)
-- 	-- print('testing if wall', dump(pos))
-- 	return (((minetest.registered_nodes[node.name] or {}).groups or {}).wall or 0) > 0
-- end

-- function construct_wall(pos)
-- 	minetest.chat_send_all('wall:construct_wall')
-- 	minetest.set_node(vector.add(pos, { x = 0, y = 1, z = 0}), { name = 'wall:collision' })
-- 	minetest.set_node(vector.add(pos, { x = 0, y = 2, z = 0}), { name = 'wall:collision' })

-- 	update_wall(pos, true)

-- 	-- for _, offset in ipairs({ { x = 0, y = 0, z = 0 }, { x = 1, y = 0, z = 0 },
-- 	-- 	{ x = -1, y = 0, z = 0 }, { x = 1, y = 0, z = 0 }, { x = -1, y = 0, z = 0}}) do
-- 	-- 	update_wall(vector.add(pos, offset), true)
-- 	-- end
-- end

-- function destruct_wall(pos)
-- 	minetest.chat_send_all('wall:destruct_wall')

-- 	minetest.set_node(vector.add(pos, { x = 0, y = 1, z = 0}), { name = 'air' })
-- 	minetest.set_node(vector.add(pos, { x = 0, y = 2, z = 0}), { name = 'air' })

-- 	for _, offset in ipairs(default.cardinal_vectors) do
-- 		if pos_is_wall(vector.add(pos, offset)) then
-- 			update_wall(vector.add(pos, offset), true)
-- 		end
-- 	end
-- end

-- local vec_0 = { x = 0, y = 0, z = 0 }
-- local vec_b = { x = 0, y = 0, z = -1 }

-- -- Index = front: 1, back: 2, left: 4, right: 8
-- local wall_type_map = {
-- 	[0] =  { type = 'mono',   ref = vec_0, rotate = nil },
-- 	[1] =  { type = 'right',  ref = vec_0, rotate = -1  },
-- 	[2] =  { type = 'left',   ref = vec_b, rotate = 0,  },
-- 	[3] =  { type = 'line',   ref = vec_0, rotate = -1  },
-- 	[4] =  { type = 'left',   ref = vec_0, rotate = 0   },
-- 	[5] =  { type = 'corner', ref = vec_0, rotate = 2   },
-- 	[6] =  { type = 'corner', ref = vec_0, rotate = 1   },
-- 	[7] =  { type = 't',      ref = vec_0, rotate = 0   },
-- 	[8] =  { type = 'right',  ref = vec_0, rotate = 0   },
-- 	[9] =  { type = 'corner', ref = vec_0, rotate = -1  },
-- 	[10] = { type = 'corner', ref = vec_0, rotate = 0   },
-- 	[11] = { type = 't',      ref = vec_0, rotate = -1  },
-- 	[12] = { type = 'line',   ref = vec_0, rotate = 0   },
-- 	[13] = { type = 't',      ref = vec_0, rotate = 2   },
-- 	[14] = { type = 't',      ref = vec_0, rotate = 0   },
-- 	[15] = { type = 'cross',  ref = vec_0, rotate = 0   }
-- }

-- function update_wall(pos, update_neighbors)
-- 	local node = minetest.get_node(pos)
-- 	local dir = minetest.facedir_to_dir(node.param2)

-- 	local adj = {
-- 		front = pos_is_wall(vector.add(pos, dir)),
-- 		back = pos_is_wall(vector.subtract(pos, dir)),
-- 		left = pos_is_wall(vector.add(pos, vector.rotate(dir, vector.new(0, math.pi / 2, 0)))),
-- 		right = pos_is_wall(vector.subtract(pos, vector.rotate(dir, vector.new(0, math.pi / 2, 0))))
-- 	}

-- 	local ind = (adj.front and 1 or 0) + (adj.back and 2 or 0) + (adj.left and 4 or 0) + (adj.right and 8 or 0)
-- 	local wall = wall_type_map[ind]

-- 	print(ind)

-- 	local param2 = node.param2 + (wall.rotate or 0)
-- 	if param2 < 0 then param2 = param2 + 4
-- 	elseif param2 > 3 then param2 = param2 - 4 end

-- 	minetest.swap_node(pos, { name = 'wall:copper_' .. wall.type, param2 = param2 })

-- 	if update_neighbors then
-- 		for _, offset in ipairs(default.cardinal_vectors) do
-- 			if pos_is_wall(vector.add(pos, offset)) then
-- 				update_wall(vector.add(pos, offset))
-- 			end
-- 		end
-- 	end
-- end

-- minetest.register_node('wall:collision', {
-- 	description = 'Don\'t touch this.',
-- 	drawtype = 'airlike',
-- 	paramtype = 'light',
-- 	sunlight_propagates = true,
-- 	selection_box = {
-- 		type = 'fixed',
-- 		fixed = { 0, 0, 0, 0, 0, 0 },
-- 	}
-- })

-- function register_wall(material, shape)
-- 	minetest.register_node('wall:' .. material .. '_' .. shape, {
-- 		drawtype = 'mesh',
-- 		mesh = 'wall_' .. shape .. '.b3d',
-- 		tiles = { 'wall_' .. material .. '.png' },
-- 		description = material .. ' ' .. shape .. ' wall',
-- 		selection_box = {
-- 			type = 'fixed',
-- 			fixed = {
-- 				{ -8/16, -8/16, -8/16, 8/16, 40/16, 8/16 }
-- 			}
-- 		},
-- 		paramtype = 'light',
-- 		sunlight_propagates = true,
-- 		paramtype2 = 'facedir',
-- 		groups = {
-- 			oddly_breakable_by_hand = 3,
-- 			wall = 1
-- 		},
-- 		on_construct = construct_wall,
-- 		after_destruct = destruct_wall,
-- 	})
-- end

-- minetest.register_node('wall:ladder', {
-- 	drawtype = 'mesh',
-- 	mesh = 'wall_ladder.b3d',
-- 	tiles = { 'wall_copper.png' },
-- 	description = 'Wall Ladder',
-- 	climbable = true,
-- 	selection_box = {
-- 		type = 'fixed',
-- 		fixed = {
-- 			{ -6/16, -8/16, 6/16, 6/16, 7.9/16, 9/16 }
-- 		}
-- 	},
-- 	collision_box = {
-- 		type = 'fixed',
-- 		fixed = {
-- 			{ -6/16, -8/16, 6/16, 6/16, 7.9/16, 9/16 }
-- 		}
-- 	},
-- 	paramtype = 'light',
-- 	sunlight_propagates = true,
-- 	paramtype2 = 'facedir',
-- 	groups = {
-- 		oddly_breakable_by_hand = 3
-- 	}
-- })

-- local wall_shapes = { 'mono', 'left', 'right', 'line', 'corner', 't', 'cross' }
-- local wall_materials = { 'copper', 'titanium', 'cobalt' }

-- for _, material in ipairs(wall_materials) do
-- 	for _, shape in ipairs(wall_shapes) do
-- 		register_wall(material, shape)
-- 	end
-- end

local node_box_wall_base = {
	type = 'connected',
	fixed = {
		{ -8/16, -8/16, -8/16, 8/16, 0/16, 8/16 },
		{ -6/16, 0/16, -6/16, 6/16, 8/16, 6/16 }
	},
	connect_front = { -6/16, 0/16, -8/16, 6/16, 8/16, -6/16 },
	connect_back = { -6/16, 0/16, 6/16, 6/16, 8/16, 8/16 },
	connect_left = { -8/16, 0/16, -6/16, -6/16, 8/16, 6/16 },
	connect_right = { 6/16, 0/16, -6/16, 8/16, 8/16, 6/16 }
}

local node_box_wall_mid_solid = {
	type = 'connected',
	fixed = { -6/16, -8/16, -6/16, 6/16, 8/16, 6/16 },
	connect_front = { -6/16, -8/16, -8/16, 6/16, 8/16, -6/16 },
	connect_back = { -6/16, -8/16, 6/16, 6/16, 8/16, 8/16 },
	connect_left = { -8/16, -8/16, -6/16, -6/16, 8/16, 6/16 },
	connect_right = { 6/16, -8/16, -6/16, 8/16, 8/16, 6/16 }
}

local node_box_wall_mid_window_x = {
	type = 'connected',
	fixed = {
		{ -6/16, -8/16, -6/16, -5/16, 8/16, 6/16 },
		{ 5/16, -8/16, -6/16, 6/16, 8/16, 6/16 }
	},
	connect_front = { -6/16, -8/16, -8/16, 6/16, 8/16, -6/16 },
	connect_back = { -6/16, -8/16, 6/16, 6/16, 8/16, 8/16 },
	connect_left = { -8/16, -8/16, -6/16, -6/16, 8/16, 6/16 },
	connect_right = { 6/16, -8/16, -6/16, 8/16, 8/16, 6/16 }
}

local node_box_wall_mid_window_z = {
	type = 'connected',
	fixed = {
		{ -6/16, -8/16, -6/16, 6/16, 8/16, -5/16 },
		{ -6/16, -8/16, 5/16, 6/16, 8/16, 6/16 }
	},
	connect_front = { -6/16, -8/16, -8/16, 6/16, 8/16, -6/16 },
	connect_back = { -6/16, -8/16, 6/16, 6/16, 8/16, 8/16 },
	connect_left = { -8/16, -8/16, -6/16, -6/16, 8/16, 6/16 },
	connect_right = { 6/16, -8/16, -6/16, 8/16, 8/16, 6/16 }
}

local node_box_wall_top = {
	type = 'connected',
	fixed = {
		{ -6/16, -8/16, -6/16, 6/16, 0/16, 6/16 },
		{ -7/16, 0/16, -7/16, 7/16, 1/16, 7/16 },
		{ -8/16, 1/16, -8/16, 8/16, 8/16, 8/16 }
	},
	connect_front = {
		{ -6/16, -8/16, -8/16, 6/16, 0/16, -6/16 },
		{ -7/16, 0/16, -8/16, 7/16, 1/16, -6/16 }
	},
	connect_back = {
		{ -6/16, -8/16, 6/16, 6/16, 0/16, 8/16 },
		{ -7/16, 0/16, 6/16, 7/16, 1/16, 8/16 }
	},
	connect_left = {
		{ -8/16, -8/16, -6/16, -6/16, 0/16, 6/16 },
		{ -8/16, 0/16, -7/16, -6/16, 1/16, 7/16 }
	},
	connect_right = {
		{ 6/16, -8/16, -6/16, 8/16, 0/16, 6/16 },
		{ 6/16, 0/16, -7/16, 8/16, 1/16, 7/16 }
	}
}

function break_wall(pos)
	minetest.set_node(vector.add(pos, vector.new(0, 1, 0)), { name = 'air' })
	minetest.set_node(vector.add(pos, vector.new(0, 2, 0)), { name = 'air' })
end

minetest.register_craftitem('wall:place_wall_solid_copper', {
	short_description = 'Solid Copper Wall',
	inventory_image = 'wall_base_copper_side.png',
	on_place = function(stack, player, target)
		minetest.set_node(vector.add(target.above, vector.new(0, 0, 0)), { name = 'wall:base_copper' })
		minetest.set_node(vector.add(target.above, vector.new(0, 1, 0)), { name = 'wall:mid_solid_copper' })
		minetest.set_node(vector.add(target.above, vector.new(0, 2, 0)), { name = 'wall:top_copper' })

		stack:take_item()
		return stack
	end
})

minetest.register_craftitem('wall:place_wall_window_copper', {
	short_description = 'Windowed Copper Wall',
	inventory_image = 'wall_base_copper_side.png',
	on_place = function(stack, player, target)
		local dir = vector.direction(target.above, player:get_pos())
		local axis = (math.abs(dir.x) > math.abs(dir.z)) and 0 or 1

		minetest.set_node(vector.add(target.above, vector.new(0, 0, 0)), { name = 'wall:base_copper' })
		minetest.set_node(vector.add(target.above, vector.new(0, 1, 0)),
			{ name = axis == 1 and 'wall:mid_window_copper_x' or 'wall:mid_window_copper_z' })
		minetest.set_node(vector.add(target.above, vector.new(0, 2, 0)), { name = 'wall:top_copper' })

		stack:take_item()
		return stack
	end
})

minetest.register_node('wall:base_copper', {
	description = 'Copper Wall',
	drawtype = 'nodebox',
	tiles = { 'wall_base_copper_top.png', 'wall_base_copper_bottom.png', 'wall_base_copper_side.png' },
	selection_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 40/16, 8/16 } },
	collision_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 8/16, 8/16 } },
	paramtype = 'light',
	sunlight_propagates = true,
	node_box = node_box_wall_base,
	connects_to = { 'group:wall_base' },
	groups = {
		oddly_breakable_by_hand = 3,
		wall_base = 1,
		wall = 1
	},
	after_destruct = break_wall
})

minetest.register_node('wall:mid_solid_copper', {
	description = 'Copper Wall (mid)',
	drawtype = 'nodebox',
	tiles = { 'wall_mid_solid_copper.png' },
	collision_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 8/16, 8/16 } },
	pointable = false,
	paramtype = 'light',
	sunlight_propagates = true,
	node_box = node_box_wall_mid_solid,
	connects_to = { 'group:wall_mid' },
	groups = {
		oddly_breakable_by_hand = 3,
		wall_mid = 1,
		wall = 1
	}
})

minetest.register_node('wall:mid_window_copper_x', {
	description = 'Copper Wall (mid, window x)',
	drawtype = 'nodebox',
	tiles = { 'wall_mid_window_copper_top.png', 'wall_mid_window_copper_bottom.png', 'wall_mid_window_copper_side.png' },
	collision_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 8/16, 8/16 } },
	pointable = false,
	paramtype = 'light',
	sunlight_propagates = true,
	node_box = node_box_wall_mid_window_x,
	connects_to = { 'group:wall_mid' },
	groups = {
		oddly_breakable_by_hand = 3,
		wall_mid = 1,
		wall = 1
	}
})

minetest.register_node('wall:mid_window_copper_z', {
	description = 'Copper Wall (mid, window z)',
	drawtype = 'nodebox',
	tiles = { 'wall_mid_window_copper_top.png', 'wall_mid_window_copper_bottom.png', 'wall_mid_window_copper_side.png' },
	collision_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 8/16, 8/16 } },
	pointable = false,
	paramtype = 'light',
	sunlight_propagates = true,
	node_box = node_box_wall_mid_window_z,
	connects_to = { 'group:wall_mid' },
	groups = {
		oddly_breakable_by_hand = 3,
		wall_mid = 1,
		wall = 1
	}
})

minetest.register_node('wall:top_copper', {
	description = 'Copper Wall (top)',
	drawtype = 'nodebox',
	tiles = { 'wall_top_copper_top.png', 'wall_top_copper_bottom.png', 'wall_top_copper_side.png' },
	collision_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 8/16, 8/16 } },
	pointable = false,
	paramtype = 'light',
	sunlight_propagates = true,
	node_box = node_box_wall_top,
	connects_to = { 'group:wall_top' },
	groups = {
		oddly_breakable_by_hand = 3,
		wall_top = 1,
		wall = 1
	}
})
