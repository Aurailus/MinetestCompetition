local path = minetest.get_modpath('hud')

text.register_glyph('count_time', path .. '/textures/hud_glyph_time.png')
text.register_glyph('count_wave', path .. '/textures/hud_glyph_wave.png')
text.register_glyph('count_wave_active', path .. '/textures/hud_glyph_wave_active.png')
text.register_glyph('count_enemies', path .. '/textures/hud_glyph_enemies.png')

local BAR_FULL_WIDTH = 239

local hud_status = {}

local last_progress_pixel = 0
local last_status = nil
local status = {
	wave = 1,
	wave_max = 10,
	wait = 15,
	wait_max = 15,
	enemies = 10,
	enemies_max = 10
}

local function format_time(time)
	local minutes = math.floor(time / 60)
	local seconds = time - minutes * 60

	return string.format('%d:%02d', minutes, seconds)
end

local function refresh_hud(force)
	for name, hud in pairs(hud_status) do
		local player = minetest.get_player_by_name(name)

		local wave_active_changed =
			force or not last_status or
			(status.wait == 0 and last_status.wait > 0) or
			(status.wait > 0 and last_status.wait == 0)

		local wave_progress = math.min(math.max(status.wait == 0
			and status.enemies / math.max(status.enemies_max, 1)
			or status.wait / math.max(status.wait_max, 1), 0))

		local wave_progress_pixel = math.floor(wave_progress * BAR_FULL_WIDTH)

		if wave_active_changed or wave_progress_pixel ~= last_progress_pixel then
			local image = '[combine:' .. BAR_FULL_WIDTH .. 'x16:0,0=([combine\\:' .. wave_progress_pixel .. 'x16\\:0,0=' ..
			(status.wait == 0 and 'hud_progress_bar_fill_active.png' or 'hud_progress_bar_fill.png') .. ')'

			player:hud_change(hud.fill, 'text', image)
			last_progress_pixel = wave_progress_pixel
		end

		local wave_status_changed = wave_active_changed or
			force or not last_status or
			(status.wait == 0 and status.enemies ~= last_status.enemies) or
			(status.wait > 0 and math.floor(status.wait) ~= math.floor(last_status.wait))

		if wave_status_changed then
			player:hud_change(hud.wave_status, 'text', text.render_text(
				(status.wait == 0 and ('[!count_enemies] ' .. status.enemies)
				or ('[!count_time] ' .. format_time(math.floor(status.wait)))) .. ' Remaining...'))
		end

		local match_status_changed =
			force or not last_status or
			last_status.wave_max ~= status.wave_max or
			last_status.wave ~= status.wave

		if match_status_changed or wave_active_changed then
			player:hud_change(hud.match_status, 'text', text.render_text('[!count_wave' ..
				(status.wait == 0 and '_active' or '') .. '] Wave ' .. status.wave ..
				(status.wave_max and status.wave_max > 0 and ('/' .. status.wave_max) or '')))
		end

		last_status = table.copy(status)
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	hud_status[name] = {}
	local hud = hud_status[name]

	hud.background = player:hud_add({
		hud_elem_type = 'image',
		text = 'hud_progress_bar_background.png',
		position = { x = 0.5, y = 0 },
		scale = { x = 3, y = 3 },
		alignment = { x = 0, y = 1 },
		offset = { x = 0, y = 8 }
	})

	hud.fill = player:hud_add({
		hud_elem_type = 'image',
		text = 'hud_hidden.png',
		position = { x = 0.5, y = 0 },
		scale = { x = 3, y = 3 },
		alignment = { x = 0, y = 1 },
		offset = { x = 0, y = 8 }
	})

	hud.frame = player:hud_add({
		hud_elem_type = 'image',
		text = 'hud_progress_bar_frame.png',
		position = { x = 0.5, y = 0 },
		scale = { x = 3, y = 3 },
		alignment = { x = 0, y = 1 },
		offset = { x = 0, y = 8 }
	})

	hud.wave_status = player:hud_add({
		hud_elem_type = 'image',
		text = text.render_text('[!count_time]'),
		position = { x = 0.5, y = 0 },
		scale = { x = 2, y = 2 },
		alignment = { x = 1, y = 1 },
		offset = { x = -336, y = 22 }
	})

	hud.match_status = player:hud_add({
		hud_elem_type = 'image',
		text = text.render_text('[!count_wave]'),
		position = { x = 0.5, y = 0 },
		scale = { x = 2, y = 2 },
		alignment = { x = -1, y = 1 },
		offset = { x = 336, y = 22 }
	})

	refresh_hud(true)
end)

minetest.register_chatcommand('set_status', {
	params = '<key> <value>',
	func = function(name, param)
		local key, value = param:match('^(%S+)%s+(.+)$')
		status[key] = tonumber(value)
		refresh_hud()
	end
})

minetest.register_globalstep(function(delta)
	status.wait = math.max(0, status.wait - delta)
	-- if not last_status or math.ceil(status.wait) ~= math.ceil(last_status.wait) then  end
	refresh_hud()
end)
