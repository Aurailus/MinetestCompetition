function register_log(type)
	local name = type:gsub('(%l)(%w*)', function(a,b) return string.upper(a) .. b end) .. ' Log'

	for i = 1, 4 do
		minetest.register_node('terrain:log_' .. type .. '_' .. i, {
			description = name,
			drawtype = 'mesh',
			mesh = 'terrain_log.b3d',
			tiles = {
				'[combine:26x16:0,' .. (-(4 - i) * 16) .. '=terrain_log_' .. type .. '_side.png',
				'terrain_log_' .. type .. '_top.png'
			},
			groups = { creative_dig = 1 },
			drop = 'terrain:log_' .. type .. '_1',
			on_place = function(stack, player, target)
				local pos = target.above
				local i = pos.y % 4 + 1
				minetest.set_node(pos, { name = 'terrain:log_' .. type .. '_' .. i })
				stack:take_item()
				return stack
			end,
		})
	end
end

function register_leaves(type)
	local name = type:gsub('(%l)(%w*)', function(a,b) return string.upper(a) .. b end) .. ' Leaves'

	minetest.register_node('terrain:leaves_' .. type, {
		description = name,
		drawtype = 'allfaces',
		paramtype = 'light',
		tiles = { 'terrain_leaves_' .. type .. '.png' },
		groups = { creative_dig = 1 }
	})
end

register_log('birch')
register_leaves('teal')
