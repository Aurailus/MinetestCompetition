-- Global game table.
_G.lexa = {}

--
-- Shorthand dofile that will load a file from the mod's script directory.
-- .lua file extension not needed.
--

function lexa.require(path)
	return dofile(minetest.get_modpath(minetest.get_current_modname()) .. '/script/'.. path .. '.lua')
end

-- Load base functionality.
lexa.require('settings')
lexa.require('util')
lexa.require('hand')
