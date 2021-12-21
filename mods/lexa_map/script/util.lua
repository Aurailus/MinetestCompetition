function lexa.map.register_node_variations(name, variations, def)
	for _, variant in ipairs(variations) do
		local identifier = 'lexa_map:' .. name .. '_' .. variant
		local name = util.title_case(variant) .. ' ' .. util.title_case(name)

		local tiles = table.copy(def.tiles)
		for i, tile in ipairs(tiles) do
			if type(tile) == 'string' then
				tiles[i] = tile .. '_' .. variant .. '.png'
			elseif type(tile) == 'function' then
				tiles[i] = tile(variant)
			else
				tile.name = tile.name .. '_' .. variant .. '.png'
			end
		end

		minetest.register_node(identifier, table.merge(def, {
			description = name,
			tiles = tiles,
			drop = ''
		}))

		minetest.register_alias('terrain:' .. name .. '_' .. variant, identifier)
	end
end
