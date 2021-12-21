lexa.materials.register_ore = function(type)
	for _, stone in ipairs({ 'base', 'beach', 'black', 'mountain', 'shist' }) do
		minetest.register_node('lexa_materials:ore_' .. type .. '_' .. stone, {
			description = lexa.util.title_case(stone) .. ' ' .. lexa.util.title_case(type) .. ' Ore',
			drawtype = 'mesh',
			mesh = 'lexa_materials_ore.b3d',
			tiles = {
				{ name = 'lexa_map_stone_' .. stone .. '.png', align_style = 'world', scale = 2 },
				'lexa_materials_ore_' .. type .. '.png'
			},
			paramtype2 = 'facedir',
			groups = {
				build_dig = 1,
				ore = 1
			},
			_ore_type = type
		})
	end
end
