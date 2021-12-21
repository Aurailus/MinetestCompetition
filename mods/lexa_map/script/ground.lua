terrain.register_node_variations('stone', { 'base', 'beach', 'black', 'mountain', 'shist' }, {
	tiles = { { name = 'lexa_map_stone', align_style = 'world', scale = 2 } },
	groups = { creative_dig = 1 }
})

terrain.register_node_variations('dirt', { 'beach' }, {
	tiles = { { name = 'lexa_map_dirt', align_style = 'world', scale = 2 } },
	groups = { creative_dig = 1 }
})

terrain.register_node_variations('sand', { 'beach' }, {
	tiles = { { name = 'lexa_map_sand', align_style = 'world', scale = 2 } },
	groups = { creative_dig = 1 }
})

terrain.register_node_variations('water', { 'deep', 'shallow' }, {
	tiles = { 'lexa_map_water' },
	groups = { creative_dig = 1 }
})

terrain.register_node_variations('grass', { 'green', 'teal' }, {
	tiles = {
		{ name = 'lexa_map_grass_top', align_style = 'world', scale = 4 },
		{ name = 'lexa_map_grass_top', align_style = 'world', scale = 4 },
		function(variant)
			local under = {
				green = 'lexa_map_dirt_beach.png',
				teal = 'lexa_map_stone_mountain.png'
			}
			return '([combine:16x16:0,0=' .. under[variant] .. ')^lexa_map_grass_side_' .. variant .. '.png'
		end
	},
	groups = { creative_dig = 1 }
})


minetest.register_node('lexa_map:light', {
	tiles = { 'lexa_map_light.png' },
	description = 'Light',
	light_source = minetest.LIGHT_MAX,
	groups = { creative_dig = 1 }
})

minetest.register_alias('terrain:ground', 'lexa_map:light')
