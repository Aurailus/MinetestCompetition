lexa.map.register_node_variations('stone', { 'base', 'beach', 'black', 'mountain', 'shist' }, {
	tiles = { { name = 'lexa_map_stone', align_style = 'world', scale = 2 } }
})

lexa.map.register_node_variations('dirt', { 'beach' }, {
	tiles = { { name = 'lexa_map_dirt', align_style = 'world', scale = 2 } }
})

lexa.map.register_node_variations('sand', { 'beach' }, {
	tiles = { { name = 'lexa_map_sand', align_style = 'world', scale = 2 } }
})

lexa.map.register_node_variations('water', { 'deep', 'shallow' }, {
	tiles = { 'lexa_map_water' }
})

local grass_under = {
	green = 'lexa_map_dirt_beach.png',
	teal = 'lexa_map_stone_mountain.png'
}

lexa.map.register_node_variations('grass', { 'green', 'teal' }, {
	tiles = {
		{ name = 'lexa_map_grass_top', align_style = 'world', scale = 4 },
		function(variant)
			return { name = grass_under[variant], scale = 2 }
		end,
		function(variant)
			return '([combine:16x16:0,0=' .. grass_under[variant] .. ')^lexa_map_grass_side_' .. variant .. '.png'
		end
	}
})

minetest.register_node('lexa_map:light', {
	tiles = { 'lexa_map_light.png' },
	description = 'Light',
	groups = { dig_build = 1 },
	light_source = minetest.LIGHT_MAX
})
