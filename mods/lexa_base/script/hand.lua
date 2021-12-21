--
-- Registers hand behaviour for game and build modes.
--

-- Hand for use in game mode.
minetest.register_tool('lexa_base:hand_game', {
	range = 10.0,
	inventory_image = 'lexa_base_hand_game.png',
	tool_capabilities = {
		full_punch_interval = 0,
		groupcaps = {
			dig_game = { times = { [1] = 0.1 }, uses = 0 }
		}
	},
	groups = {
		-- not_in_creative_inventory = 1
	}
})

-- Hand for use in build mode.
minetest.register_tool('lexa_base:hand_build', {
	range = 10.0,
	inventory_image = 'lexa_base_hand_build.png',
	tool_capabilities = {
		full_punch_interval = 0,
		groupcaps = {
			dig_game = { times = { [1] = 0.1 }, uses = 0 },
			dig_build = { times = { [1] = 0.1 }, uses = 0 }
		}
	},
	groups = {
		-- not_in_creative_inventory = 1
	}
})

-- Update the player's hand on join.
minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	inv:set_size('hand', 1)
	inv:set_list('hand', { 'lexa_base:hand_game' })
end)

-- Don't consume items on place.
minetest.register_on_placenode(function(_, _, placer)
	if placer and placer:is_player() then
		return true
	end
end)
