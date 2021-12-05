minetest.register_node('terrain:fern', {
	drawtype = 'mesh',
	mesh = 'terrain_fern.b3d',
	tiles = { 'terrain_fern.png' },
	use_texture_alpha = 'clip',
	description = 'Fern',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = { -4/16, -8/16, -4/16, 4/16, -4/16, 4/16 }
	},
	groups = {
		oddly_breakable_by_hand = 3,
	}
})

minetest.register_node('terrain:tall_grass', {
	drawtype = 'plantlike',
	tiles = { 'terrain_tall_grass.png' },
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
	groups = {
		oddly_breakable_by_hand = 3,
	},
	on_construct = function(pos)
		minetest.swap_node(pos, { name = 'terrain:tall_grass', param2 = math.floor(math.random() * 24) * 20 })
		print(minetest.get_node(pos).param2)
	end
})
