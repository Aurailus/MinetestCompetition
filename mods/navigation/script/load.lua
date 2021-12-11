-- The minimum max_forceloaded_blocks for the game to work
local REQUIRED_FORCELOADED_BLOCKS = 10000

-- If the max_forceloaded_blocks is less than what is required, prevent the game from being run.
local forceload_is_good = tonumber((minetest.settings:get('max_forceloaded_blocks') or 0)) >= REQUIRED_FORCELOADED_BLOCKS

if not forceload_is_good then
	minetest.register_on_joinplayer(function(player)
		minetest.kick_player(player:get_player_name(),
			'\n\nThe server is misconfigured, please set max_forceloaded_blocks = 10000 in minetest.conf.')
	end)
end

--
-- Emerges and forceloads the area between min_pos and max_pos (inclusive)
-- When the load is complete, calls the callback function with three parameters:
-- A function to unload the loaded area, the number of blocks loaded, and the time it took to emerge the area in ms.
--
-- @param min_pos - The minimum position of the area to emerge
-- @param max_pos - The maximum position of the area to emerge
-- @param callback - The callback to call when the area is emerged.
--

function navigation.load_area(min_pos, max_pos, cb)
	local start_time = minetest.get_us_time()

	local function free()
		for x = math.floor(min_pos.x / 16), math.ceil(max_pos.x / 16) do
			for z = math.floor(min_pos.y / 16), math.ceil(max_pos.y / 16) do
				for y = math.floor(min_pos.z / 16), math.ceil(max_pos.z / 16) do
					minetest.forceload_free_block({ x = x, y = y, z = z }, true)
				end
			end
		end
	end

	local function forceload()
		local loaded = 0

		for x = math.floor(min_pos.x / 16), math.ceil(max_pos.x / 16) do
			for z = math.floor(min_pos.y / 16), math.ceil(max_pos.y / 16) do
				for y = math.floor(min_pos.z / 16), math.ceil(max_pos.z / 16) do
					local pos = { x = x, y = y, z = z }
					if not minetest.forceload_block(pos, true) then
						minetest.chat_send_all('[Error] Failed to forceload block at ' .. minetest.pos_to_string(pos) .. '.')
					end
					loaded = loaded + 1
				end
			end
		end

		local duration = math.floor((minetest.get_us_time() - start_time) / 1000)
		cb(free, loaded, duration)
	end

	minetest.emerge_area(min_pos, max_pos, function(_, _, remaining)
		if remaining == 0 then forceload() end
	end)
end
