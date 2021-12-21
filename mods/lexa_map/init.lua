lexa.map = {}

lexa.require('util')
lexa.require('ground')
lexa.require('ore')
lexa.require('decoration')
lexa.require('tree')

local glyph_path = minetest.get_modpath(minetest.get_current_modname()) .. '/textures/'

lexa.text.register_glyph('ore_copper', glyph_path .. 'lexa_map_glyph_ore_copper.png')
lexa.text.register_glyph('ore_titanium', glyph_path .. 'lexa_map_glyph_ore_titanium.png')
lexa.text.register_glyph('ore_cobalt', glyph_path .. 'lexa_map_glyph_ore_cobalt.png')
lexa.text.register_glyph('ore_iridium', glyph_path .. 'lexa_map_glyph_ore_iridium.png')
