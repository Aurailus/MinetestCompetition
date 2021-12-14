_G['hud'] = {}

local path = minetest.get_modpath('hud') .. '/'

dofile(path .. 'script/build_menu.lua')
dofile(path .. 'script/wave_status.lua')

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	for i = 1, 10 do
		minetest.chat_send_player(name, ' ')
	end

	player:hud_set_flags({
		hotbar = false,
		heathbar = false,
		crosshair = true,
		wielditem = false,
		minimap = false,
		minimap_radar = false
	})
end)
