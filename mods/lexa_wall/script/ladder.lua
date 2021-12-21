local node_box_ladder = {
	type = 'fixed',
	fixed = {
		{ -6/16, -6/16, -7/16, -4/16, -10/16, -5/16 },
		{ 4/16, -6/16, -7/16, 6/16, -10/16, -5/16 },
		{ -4/16, -6/16, -7/16, 4/16, -8/16, -5/16 },

		{ -6/16, -6/16, -3/16, -4/16, -10/16, -1/16 },
		{ 4/16, -6/16, -3/16, 6/16, -10/16, -1/16 },
		{ -4/16, -6/16, -3/16, 4/16, -8/16, -1/16 },

		{ -6/16, -6/16, 1.01/16, -4/16, -10/16, 3/16 },
		{ 4/16, -6/16, 1.01/16, 6/16, -10/16, 3/16 },
		{ -4/16, -6/16, 1.01/16, 4/16, -8/16, 3/16 },

		{ -6/16, -6/16, 5/16, -4/16, -10/16, 7/16 },
		{ 4/16, -6/16, 5/16, 6/16, -10/16, 7/16 },
		{ -4/16, -6/16, 5/16, 4/16, -8/16, 7/16 }
	}
}

minetest.register_node('lexa_wall:ladder', {
	description = 'Ladder',
	_cost = { copper = 5 },
	drawtype = 'nodebox',
	tiles = { 'lexa_wall_ladder.png' },
	inventory_image = 'lexa_wall_ladder_inventory.png',
	collision_box = { type = 'fixed', fixed = { -8/16, -6/16, -8/16, 8/16, -10/16, 7.9/16 } },
	selection_box = { type = 'fixed', fixed = { -6/16, -6/16, -8/16, 6/16, -10/16, 7.9/16 } },
	paramtype = 'light',
	paramtype2 = 'wallmounted',
	sunlight_propagates = true,
	node_box = node_box_ladder,
	climbable = true,
	groups = {
		dig_game = 1,
		attached_node = 1
	},
	drop = '',
	on_place = function(_, player, target)
		local node = minetest.get_node(target.under).name
		if not (minetest.registered_nodes[node].groups or {}).wall then return end

		local pos = target.above
		local param2 = minetest.dir_to_wallmounted(vector.direction(pos, target.under))
		minetest.set_node(pos, { name = 'lexa_wall:ladder', param2 = param2 })

		minetest.set_node(vector.add(pos, vector.new(0, pos.y == target.under.y and 1 or -1, 0)),
			{ name = 'lexa_wall:ladder', param2 = param2 })
	end,
	on_dig = function(pos)
		minetest.set_node(pos, { name = 'air' })
		if minetest.get_node(vector.add(pos, vector.new(0, 1, 0))).name == 'lexa_wall:ladder' then
			minetest.set_node(vector.add(pos, vector.new(0, 1, 0)), { name = 'air' })
		end
		if minetest.get_node(vector.add(pos, vector.new(0, -1, 0))).name == 'lexa_wall:ladder' then
			minetest.set_node(vector.add(pos, vector.new(0, -1, 0)), { name = 'air' })
		end
	end
})
