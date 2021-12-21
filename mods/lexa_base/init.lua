-- Global game table.
_G.lexa = {}

function lexa.get_script_path()
	return minetest.get_modpath(minetest.get_current_modname()) .. '/script/'
end

function lexa.require(path)
	return dofile(lexa.get_script_path() .. path .. '.lua')
end

local path = lexa.get_script_path()

dofile(path .. 'settings.lua')
dofile(path .. 'util.lua')
dofile(path .. 'hand.lua')
