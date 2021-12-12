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

local node_box_ladder = {
	type = 'fixed',
	fixed = {
		{ -6/16, -7/16, 6/16, -4/16, -5/16, 10/16 },
		{ 4/16, -7/16, 6/16, 6/16, -5/16, 10/16 },
		{ -4/16, -7/16, 6/16, 4/16, -5/16, 8/16 },

		{ -6/16, -3/16, 6/16, -4/16, -1/16, 10/16 },
		{ 4/16, -3/16, 6/16, 6/16, -1/16, 10/16 },
		{ -4/16, -3/16, 6/16, 4/16, -1/16, 8/16 },

		{ -6/16, 1.01/16, 6/16, -4/16, 3/16, 10/16 },
		{ 4/16, 1.01/16, 6/16, 6/16, 3/16, 10/16 },
		{ -4/16, 1.01/16, 6/16, 4/16, 3/16, 8/16 },

		{ -6/16, 5/16, 6/16, -4/16, 7/16, 10/16 },
		{ 4/16, 5/16, 6/16, 6/16, 7/16, 10/16 },
		{ -4/16, 5/16, 6/16, 4/16, 7/16, 8/16 }
	}
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
	minetest.register_craftitem('wall:place_wall_' .. type, {
		short_description = util.title_case(type) .. ' Wall',
		inventory_image = 'wall_' .. type .. '_bottom_side.png',
		on_place = function(stack, player, target)
			minetest.set_node(vector.add(target.above, vector.new(0, 0, 0)), { name = 'wall:bottom_' .. type })
			minetest.set_node(vector.add(target.above, vector.new(0, 1, 0)), { name = 'wall:top_' .. type })

			stack:take_item()
			return stack
		end
	})

	local shared_props = {
		description = util.title_case(type) .. ' Wall',
		drawtype = 'nodebox',
		paramtype = 'light',
		pointable = false,
		sunlight_propagates = true,
		connect_sides = { 'front', 'left', 'back', 'right' }
	}

	minetest.register_node('wall:bottom_' .. type, table.merge(shared_props, {
		tiles = {
			'wall_' .. type .. '_bottom_top.png',
			'wall_' .. type .. '_top_bottom.png',
			'wall_' .. type .. '_bottom_side.png'
		},
		selection_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 24/16, 8/16 } },
		collision_box = { type = 'fixed', fixed = { -8/16, -8/16, -8/16, 8/16, 8/16, 8/16 } },
		pointable = true,
		node_box = node_box_wall_bottom,
		connects_to = { 'group:wall_bottom' },
		drop = '',
		groups = {
			not_in_creative_inventory = 1,
			oddly_breakable_by_hand = 3,
			wall_bottom = 1,
			wall = 1
		},
		after_destruct = break_wall
	}))

	minetest.register_node('wall:top_' .. type, table.merge(shared_props, {
		tiles = {
			'wall_' .. type .. '_top_top.png',
			'wall_' .. type .. '_top_bottom.png',
			'wall_' .. type .. '_top_side.png'
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

minetest.register_node('wall:ladder', {
	description = 'Ladder',
	drawtype = 'nodebox',
	tiles = { 'wall_ladder.png' },
	collision_box = { type = 'fixed', fixed = { -8/16, -8/16, 6/16, 8/16, 8/16, 10/16 } },
	selection_box = { type = 'fixed', fixed = { -6/16, -7/16, 6/16, 6/16, 7/16, 10/16 } },
	paramtype = 'light',
	paramtype2 = 'facedir',
	sunlight_propagates = true,
	node_box = node_box_ladder,
	climbable = true,
	groups = {
		oddly_breakable_by_hand = 3,
	}
})
