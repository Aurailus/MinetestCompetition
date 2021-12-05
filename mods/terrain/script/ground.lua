minetest.register_node('terrain:ground', {
	tiles = { 'terrain_ground.png' },
	description = 'Ground',
	groups = { oddly_breakable_by_hand = 2 }
})

minetest.register_node('terrain:stone_green', {
	tiles = { { name = 'terrain_stone_green.png', align_style = 'world', scale = 2 } },
	description = 'Green Stone',
	groups = { oddly_breakable_by_hand = 2 }
})

minetest.register_node('terrain:grass_teal_on_stone_green', {
	tiles = {
		{ name = 'terrain_grass_teal_top.png', align_style = 'world', scale = 4 },
		{ name = 'terrain_stone_green.png', align_style = 'world', scale = 2 },
		'([combine:16x16:0,0=terrain_stone_green.png)^terrain_grass_teal_side.png'
	},
	description = 'Teal Grass on Green Stone',
	groups = { oddly_breakable_by_hand = 2 }
})
