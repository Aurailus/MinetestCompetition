local materials = {}

local function get_status_text()
	if not materials.copper and not materials.titanium and not materials.cobalt and not materials.iridium then
		return lexa.text.render_text('')
	end

	local str = ''

	if materials.copper then
		str = str .. '[!ore_copper][!ss][!ss]' .. materials.copper
	end
	if materials.titanium then
		if materials.copper then str = str .. '   ' end
		str = str .. '[!ore_titanium][!ss][!ss]' .. materials.titanium
	end
	if materials.cobalt then
		if materials.copper or materials.titanium then str = str .. '   ' end
		str = str .. '[!ore_cobalt][!ss][!ss]' .. materials.cobalt
	end
	if materials.iridium then
		if materials.copper or materials.titanium or status.cobalt then str = str .. '   ' end
		str = str .. '[!ore_iridium][!ss][!ss]' .. materials.iridium
	end

	return lexa.text.render_text(str)
end

function lexa.hud.update_materials(new)
	materials = new

	local text, width = get_status_text()
	local bar_width = width * 2/3 + 12

	for name, state in pairs(lexa.hud.state) do
		local elems = state.elements
		local player = minetest.get_player_by_name(name)

		if width == 0 then
			player:hud_change(elems.material_background, 'text', 'lexa_hud_hidden.png')
		else
			player:hud_change(elems.material_background, 'text', '[combine:' .. bar_width ..
				'x12:0,0=lexa_hud_materials_left.png:4,0=lexa_hud_materials_middle.png\\^[resize\\:' ..
				(bar_width - 8) .. 'x12:' .. (bar_width - 4) .. ',0=lexa_hud_materials_right.png')
		end

		player:hud_change(elems.material_text, 'text', text)
	end
end

table.insert(lexa.hud.callbacks.register, function(player)
	local name = player:get_player_name()
	local elems = lexa.hud.state[name].elements

	elems.material_background = player:hud_add({
		hud_elem_type = 'image',
		text = 'lexa_hud_hidden.png',
		position = { x = 0.5, y = 1 },
		scale = { x = 3, y = 3 },
		alignment = { x = 0, y = -1 },
		offset = { x = 0, y = -8 }
	})

	elems.material_text = player:hud_add({
		hud_elem_type = 'image',
		text = 'lexa_hud_hidden.png',
		position = { x = 0.5, y = 1 },
		scale = { x = 2, y = 2 },
		alignment = { x = 0, y = -1 },
		offset = { x = 0, y = -13 }
	})

	lexa.hud.update_materials(materials)
end)
