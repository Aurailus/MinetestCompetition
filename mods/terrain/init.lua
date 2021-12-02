minetest.register_node('terrain:ground', {
	tiles = { 'terrain_ground.png' },
	description = 'Ground',
	groups = { oddly_breakable_by_hand = 2 }
})

minetest.override_item('', {
	range = 10.0,
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			oddly_breakable_by_hand = { times={ [1] = 0.5, [2] = 0.30, [3] = 0.15 }, uses = 0 }
		},
		damage_groups = { fleshy = 1 },
	}
})

local plat_y = -5
local plat_size = 20

minetest.register_on_generated(function(a, b)
	local min = vector.new(math.max(-plat_size, a.x), plat_y, math.max(-plat_size, a.z))
	local max = vector.new(math.min(plat_size, b.x), plat_y, math.min(plat_size, b.z))

	if (max.y < plat_y or min.y > plat_y) then return end

	for x = min.x, max.x do
		for z = min.z, max.z do
			minetest.set_node(vector.new(x, plat_y, z), { name = 'terrain:ground' })
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	if player.name == 'singleplayer' then
		minetest.set_player_privs('singleplayer', { fly = true, teleport = true, noclip = true, fast = true, give = true })
		player:override_day_night_ratio(1)
	end
end)
