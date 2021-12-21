local log_shared = {
	description = 'Log',
	drawtype = 'mesh',
	mesh = 'lexa_map_log.b3d',
	drop = ''
}

lexa.map.register_node_variations('log_' .. 1, { 'birch', 'palm' }, table.merge(log_shared, {
	tiles = {
		'[combine:26x16:0,' .. (-(4 - 1) * 16) .. '=lexa_map_log_side',
		'lexa_map_log_top'
	},
	on_construct = function(pos)
		local i = pos.y % 4 + 1
		minetest.swap_node(pos, { name = minetest.get_node(pos).name:gsub('_1', '_' .. i) })
	end
}))

for i = 2, 4 do
	lexa.map.register_node_variations('log_' .. i, { 'birch', 'palm' }, table.merge(log_shared, {
		tiles = {
			'[combine:26x16:0,' .. (-(4 - i) * 16) .. '=lexa_map_log_side',
			'lexa_map_log_top'
		},
		groups = { build_dig = 1, not_in_creative_inventory = 1 },
		on_construct = function(pos)
			local i = pos.y % 4 + 1
			minetest.swap_node(pos, { name = minetest.get_node(pos).name:gsub('_1', '_' .. i) })
		end
	}))
end

lexa.map.register_node_variations('leaves', { 'birch', 'palm' }, {
	description = 'Leaves',
	drawtype = 'allfaces',
	paramtype = 'light',
	tiles = { 'lexa_map_leaves' }
})
