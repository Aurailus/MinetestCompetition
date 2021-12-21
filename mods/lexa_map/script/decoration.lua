lexa.map.register_node_variations('fern', { 'green', 'teal' }, {
	drawtype = 'mesh',
	mesh = 'lexa_map_fern.b3d',
	tiles = { 'lexa_map_fern' },
	use_texture_alpha = 'clip',
	description = 'Fern',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = { -4/16, -8/16, -4/16, 4/16, -4/16, 4/16 }
	}
})

lexa.map.register_node_variations('tall_grass', { 'green', 'teal' }, {
	drawtype = 'plantlike',
	tiles = { 'lexa_map_tall_grass' },
	use_texture_alpha = 'clip',
	description = 'Tall Grass',
	paramtype = 'light',
	paramtype2 = 'degrotate',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = { -7/16, -8/16, -7/16, 7/16, 0/16, 7/16 }
	},
	on_construct = function(pos)
		minetest.swap_node(pos, { name = minetest.get_node(pos).name, param2 = math.floor(math.random() * 24) * 20 })
		print(minetest.get_node(pos).param2)
	end
})
