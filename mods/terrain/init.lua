_G['terrain'] = {}

local path = minetest.get_modpath(minetest.get_current_modname()) .. '/'

dofile(path .. 'script/util.lua')
dofile(path .. 'script/ore.lua')
dofile(path .. 'script/tree.lua')
dofile(path .. 'script/ground.lua')
dofile(path .. 'script/decoration.lua')

text.register_glyph('ore_copper', path .. 'textures/terrain_glyph_ore_copper.png')
text.register_glyph('ore_titanium', path .. 'textures/terrain_glyph_ore_titanium.png')
text.register_glyph('ore_cobalt', path .. 'textures/terrain_glyph_ore_cobalt.png')
