local log_shared = {
	description = 'Log',
	drawtype = 'mesh',
	mesh = 'terrain_log.b3d',
	drop = ''
}

terrain.register_node_variations('log_' .. 1, { 'birch', 'palm' }, table.merge(log_shared, {
	tiles = {
		'[combine:26x16:0,' .. (-(4 - 1) * 16) .. '=terrain_log_side',
		'terrain_log_top'
	},
	groups = { creative_dig = 1 },
	on_construct = function(pos)
		local i = pos.y % 4 + 1
		minetest.swap_node(pos, { name = minetest.get_node(pos).name:gsub('_1', '_' .. i) })
	end
}))

for i = 2, 4 do
	terrain.register_node_variations('log_' .. i, { 'birch', 'palm' }, table.merge(log_shared, {
		tiles = {
			'[combine:26x16:0,' .. (-(4 - i) * 16) .. '=terrain_log_side',
			'terrain_log_top'
		},
		groups = { creative_dig = 1, not_in_creative_inventory = 1 },
		on_construct = function(pos)
			local i = pos.y % 4 + 1
			minetest.swap_node(pos, { name = minetest.get_node(pos).name:gsub('_1', '_' .. i) })
		end
	}))
end

terrain.register_node_variations('leaves', { 'birch', 'palm' }, {
	description = 'Leaves',
	drawtype = 'allfaces',
	paramtype = 'light',
	tiles = { 'terrain_leaves' },
	groups = { creative_dig = 1 }
})

minetest.register_alias('terrain:log_birch_1', 'terrain:log_1_birch')
minetest.register_alias('terrain:log_birch_2', 'terrain:log_2_birch')
minetest.register_alias('terrain:log_birch_3', 'terrain:log_3_birch')
minetest.register_alias('terrain:log_birch_4', 'terrain:log_4_birch')

minetest.register_alias('terrain:leaves_teal', 'terrain:leaves_birch')
