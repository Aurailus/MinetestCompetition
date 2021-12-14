_G['hud'] = {}

local path = minetest.get_modpath('hud') .. '/'

dofile(path .. 'script/state.lua')
dofile(path .. 'script/match_bar.lua')
dofile(path .. 'script/build_menu.lua')
dofile(path .. 'script/material_status.lua')
