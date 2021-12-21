local node_box_wall_bottom = {
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

for _, type in ipairs({ 'copper', 'titanium', 'cobalt' }) do

	local shared_props = {
		description = lexa.util.title_case(type) .. ' Wall',
		drawtype = 'nodebox',
		paramtype = 'light',
		pointable = false,
		sunlight_propagates = true,
		connect_sides = { 'front', 'left', 'back', 'right' }
	}

	minetest.register_node('lexa_wall:bottom_' .. type, table.merge(shared_props, {
		description = lexa.util.title_case(type) .. ' Wall',
		_cost = { [type] = 20 },
		inventory_image = 'lexa_wall_' .. type .. '_inventory.png',
		tiles = {
			'lexa_wall_' .. type .. '_bottom_top.png',
			'lexa_wall_' .. type .. '_top_bottom.png',
			'lexa_wall_' .. type .. '_bottom_side.png'
		},
		selection_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 24/16, 8/16 } },
		collision_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 8/16, 8/16 } },
		pointable = true,
		node_box = node_box_wall_bottom,
		connects_to = { 'group:wall_bottom' },
		drop = '',
		groups = {
			creative_dig = 1,
			wall_bottom = 1,
			wall = 1
		},
		on_construct = function(pos)
			minetest.set_node(vector.add(pos, vector.new(0, 1, 0)), { name = 'lexa_wall:top_' .. type })
		end,
		after_destruct = break_wall
	}))

	minetest.register_node('lexa_wall:top_' .. type, table.merge(shared_props, {
		tiles = {
			'lexa_wall_' .. type .. '_top_top.png',
			'lexa_wall_' .. type .. '_top_bottom.png',
			'lexa_wall_' .. type .. '_top_side.png'
		},
		collision_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 8/16, 8/16 } },
		node_box = node_box_wall_top,
		connects_to = { 'group:wall_top' },
		connect_sides = { 'front', 'left', 'back', 'right' },
		drop = '',
		groups = {
			not_in_creative_inventory = 1,
			creative_dig = 1,
			wall_top = 1,
			wall = 1
		}
	}))
end
