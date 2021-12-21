-- The player hud state.
lexa.hud.state = {}

-- Internal hud callbacks for registration and unregistration.
lexa.hud.callbacks = { register = {}, unregister = {} }

-- Calls the unregister callbacks for the hud.
function unregister_hud(player)
	local elems = lexa.hud.state[player:get_player_name()].elements
	for _, elem in pairs(elems) do player:hud_remove(elem) end
	for _, fn in ipairs(lexa.hud.callbacks.unregister) do fn(player) end
end

-- Calls the register callbacks for the hud.
function register_hud(player)
	for _, fn in ipairs(lexa.hud.callbacks.register) do fn(player) end
end

--
-- Sets the hud state for the given player by name
--

function lexa.hud.set_active(name, active)
	if active and not lexa.hud.state[name] then
		lexa.hud.state[name] = {
			elements = {}
		}
		register_hud(minetest.get_player_by_name(name))
	elseif not active and lexa.hud.state[name] then
		unregister_hud(minetest.get_player_by_name(name))
		lexa.hud.state[name] = nil
	end
end

--
-- Register a command to allow manually switching modes
--

minetest.register_chatcommand('mode_toggle', {
	description = 'Toggle mode between build and game',
	func = function(name)
		lexa.hud.set_active(name, not lexa.hud.state[name])
		local inv = minetest.get_player_by_name(name):get_inventory()
		inv:set_list('hand', { 'lexa_base:hand_' .. (lexa.hud.state[name] and 'game' or 'build') })
	end
})

--
-- Put joined players in game mode by default
--

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	for i = 1, 10 do minetest.chat_send_player(name, ' ') end
	player:hud_set_flags({ heathbar = false, minimap = false })

	lexa.hud.set_active(name, true)
end)

--
-- Deactivate hud when players are leaving the server
--

minetest.register_on_leaveplayer(function(player)
	lexa.hud.set_active(player:get_player_name(), false)
end)
