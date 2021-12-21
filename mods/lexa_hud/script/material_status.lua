local status = {
	copper = 16,
	titanium = 200,
	cobalt = 99,
	iridium = 34
}

local hud_status = {}

local last_status = nil

local function get_status_text()
	if not status.copper and not status.titanium and not status.cobalt and not status.iridium then
		return ''
	end

	local str = ''

	if status.copper then
		str = str .. '[!ore_copper][!ss][!ss]' .. status.copper
	end
	if status.titanium then
		if status.copper then str = str .. '   ' end
		str = str .. '[!ore_titanium][!ss][!ss]' .. status.titanium
	end
	if status.cobalt then
		if status.copper or status.titanium then str = str .. '   ' end
		str = str .. '[!ore_cobalt][!ss][!ss]' .. status.cobalt
	end
	if status.iridium then
		if status.copper or status.titanium or status.cobalt then str = str .. '   ' end
		str = str .. '[!ore_iridium][!ss][!ss]' .. status.iridium
	end

	return lexa.text.render_text(str)
end

local function refresh_hud(force)
	local changed = not last_status or
		last_status.copper ~= status.copper or
		last_status.titanium ~= status.titanium or
		last_status.cobalt ~= status.cobalt or
		last_status.iridium ~= status.iridium

	if not changed and not force then return end

	local text, width = get_status_text()
	local bar_width = width * 2/3 + 12

	for name, state in pairs(lexa.hud.state) do
		local elems = state.elements
		local player = minetest.get_player_by_name(name)

		player:hud_change(elems.material_background, 'text', '[combine:' .. bar_width ..
			'x12:0,0=lexa_hud_materials_left.png:4,0=lexa_hud_materials_middle.png\\^[resize\\:' ..
			(bar_width - 8) .. 'x12:' .. (bar_width - 4) .. ',0=lexa_hud_materials_right.png')

		player:hud_change(elems.material_text, 'text', text)

		last_status = table.copy(status)
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

	refresh_hud(true)
end)
