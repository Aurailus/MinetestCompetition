local glyph_path = minetest.get_modpath(minetest.get_current_modname()) .. '/textures/'

lexa.materials.register = function(name)
	lexa.materials.register_ore(name)
	lexa.text.register_glyph('ore_' .. name, glyph_path .. 'lexa_materials_glyph_ore_' .. name .. '.png')
end

lexa.materials.material_list = { 'coal', 'copper', 'titanium', 'cobalt', 'iridium' }

for _, material in ipairs(lexa.materials.material_list) do
	lexa.materials.register(material)
end
