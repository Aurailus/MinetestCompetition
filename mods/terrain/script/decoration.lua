terrain.register_node_variations('fern', { 'green', 'teal' }, {
	drawtype = 'mesh',
	mesh = 'terrain_fern.b3d',
	tiles = { 'terrain_fern' },
	use_texture_alpha = 'clip',
	description = 'Fern',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = { -4/16, -8/16, -4/16, 4/16, -4/16, 4/16 }
	},
	groups = { creative_dig = 1 }
})

terrain.register_node_variations('tall_grass', { 'green', 'teal' }, {
	drawtype = 'plantlike',
	tiles = { 'terrain_tall_grass' },
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
	groups = { creative_dig = 1 },
	on_construct = function(pos)
		minetest.swap_node(pos, { name = minetest.get_node(pos).name, param2 = math.floor(math.random() * 24) * 20 })
		print(minetest.get_node(pos).param2)
	end
})

minetest.register_alias('terrain:fern', 'terrain:fern_teal')
minetest.register_alias('terrain:fern_mountain', 'terrain:fern_teal')
minetest.register_alias('terrain:tall_grass', 'terrain:tall_grass_teal')
minetest.register_alias('terrain:tall_grass_mountain', 'terrain:tall_grass_teal')
