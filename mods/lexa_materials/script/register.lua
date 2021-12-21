local glyph_path = minetest.get_modpath(minetest.get_current_modname()) .. '/textures/'

lexa.materials.register = function(name)
	lexa.materials.register_ore(name)
	lexa.text.register_glyph('ore_' .. name, glyph_path .. 'lexa_materials_glyph_ore_' .. name .. '.png')
end

lexa.materials.material_list = { 'coal', 'copper', 'titanium', 'cobalt', 'iridium' }

for _, material in ipairs(lexa.materials.material_list) do
	lexa.materials.register(material)
end

minetest.register_chatcommand('give_material', {
	params = '<type> <amount>',
	description = 'Gives materials to the player.',
	privs = { cheats = true },
	func = function(name, params)
		local type, amount = params:match('^(%S+) (-?%d+)$')
		if not type or not amount then
			minetest.chat_send_player(name, 'Invalid params.')
			return false
		end

		local materials = table.copy(lexa.match.state.materials)
		materials[type] = (materials[type] or 0) + tonumber(amount)
		lexa.match.set_materials(materials)
	end
})
