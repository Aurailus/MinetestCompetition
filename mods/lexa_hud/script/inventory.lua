local default_formspec = nil

table.insert(lexa.hud.callbacks.register, function(player)
	local function update_formspec()
		player:set_inventory_formspec([[
			formspec_version[3]
			size[4,2]
			button_exit[1,0.5;2,1;lexa_respawn;Respawn]
			label[1.3, 1.75;Lexa v 0.0.1]
		]])
	end

	if not default_formspec then
		minetest.after(0.01, function()
			default_formspec = player:get_inventory_formspec()
			update_formspec()
		end)
	else
		update_formspec()
	end
end)

table.insert(lexa.hud.callbacks.unregister, function(player)
	player:set_inventory_formspec(default_formspec)
end)

minetest.register_on_player_receive_fields(function(player, name, fields)
	if name ~= '' or not fields.lexa_respawn then return end
	lexa.match.respawn(player:get_player_name())
end)
