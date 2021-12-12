terrain.register_node_variations('stone', { 'base', 'beach', 'black', 'mountain', 'shist' }, {
	tiles = { { name = 'terrain_stone', align_style = 'world', scale = 2 } },
	groups = { creative_dig = 1 }
})

terrain.register_node_variations('dirt', { 'beach' }, {
	tiles = { { name = 'terrain_dirt', align_style = 'world', scale = 2 } },
	groups = { creative_dig = 1 }
})

terrain.register_node_variations('sand', { 'beach' }, {
	tiles = { 'terrain_sand' },
	groups = { creative_dig = 1 }
})

terrain.register_node_variations('water', { 'deep', 'shallow' }, {
	tiles = { 'terrain_water' },
	groups = { creative_dig = 1 }
})

terrain.register_node_variations('grass', { 'green', 'teal' }, {
	tiles = {
		{ name = 'terrain_grass_top', align_style = 'world', scale = 4 },
		{ name = 'terrain_grass_top', align_style = 'world', scale = 4 },
		function(variant)
			local under = {
				green = 'terrain_dirt_beach.png',
				teal = 'terrain_stone_mountain.png'
			}
			return '([combine:16x16:0,0=' .. under[variant] .. ')^terrain_grass_side_' .. variant .. '.png'
		end
	},
	groups = { creative_dig = 1 }
})

minetest.register_node('terrain:ground', {
	tiles = { 'terrain_light.png' },
	description = 'Lightbulb',
	light_source = minetest.LIGHT_MAX,
	groups = { creative_dig = 1 }
})

minetest.register_alias('terrain:stone_green', 'terrain:stone_mountain')
minetest.register_alias('terrain:grass_teal_on_stone_green', 'terrain:grass_teal')
