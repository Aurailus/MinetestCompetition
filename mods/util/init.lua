--
-- If the user has a user-level time_speed then we will create a loop to set the time to noon every 5 seconds.
-- This is stupid, but so is minetest so what are you going to do?
--

local manually_update_time = tonumber((minetest.settings:get('time_speed') or 72)) > 0

function update_time()
	minetest.set_timeofday(0.5)
	if manually_update_time then
		minetest.after(5, update_time)
	end
end

update_time()

--
-- Update hand capabalities
--

minetest.override_item('', {
	range = 10.0,
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			oddly_breakable_by_hand = { times={ [1] = 0.5, [2] = 0.30, [3] = 0.15 }, uses = 0 },
			creative_dig = { times = { [1] = 0.1 }, uses = 0 },
		},
		damage_groups = { fleshy = 1 },
	}
})

--
-- Temporary development code.
--

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
	end
end)

_G['util'] = {}

util.cardinal_vectors = {
	{ x =  1, y = 0, z =  0 },
	{ x = -1, y = 0, z =  0 },
	{ x =  0, y = 0, z = -1 },
	{ x =  0, y = 0, z =  1 },
}

function table.copy(table)
	local copy = {}
	for k, v in pairs(table) do copy[k] = v end
	return copy
end

function table.merge(t1, t2)
	local t_res = table.copy(t1)
	if t2 then
		for k, v in pairs(t2) do t_res[k] = v end
	end
	return t_res
end
