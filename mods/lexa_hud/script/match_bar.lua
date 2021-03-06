-- Register some glyphs used in the bar.
local glyph_path = minetest.get_modpath(minetest.get_current_modname()) .. '/textures/'
lexa.text.register_glyph('count_time', glyph_path .. 'lexa_hud_glyph_time.png')
lexa.text.register_glyph('count_wave', glyph_path .. 'lexa_hud_glyph_wave.png')
lexa.text.register_glyph('count_enemies', glyph_path .. 'lexa_hud_glyph_enemies.png')
lexa.text.register_glyph('count_wave_active', glyph_path .. 'lexa_hud_glyph_wave_active.png')

-- The width of the bar in pixels
local BAR_FULL_WIDTH = 239

-- The current wave status
-- local last_progress_pixel = 0
-- local last_status = nil
-- local status = {
-- 	wave = 1,
-- 	wave_max = 10,
-- 	wait = 180,
-- 	wait_max = 180,
-- 	enemies = 10,
-- 	enemies_max = 10
-- }

-- Formats a time in seconds into a 0:00 format.
local function format_time(time)
	local minutes = math.floor(time / 60)
	local seconds = time - minutes * 60

	return string.format('%d:%02d', minutes, seconds)
end

-- Updates the necessary hud elements to keep the match status accurate.
function lexa.hud.refresh_bar(force)
	if not lexa.match.state then return end
	local status = lexa.match.state.status

	for name, state in pairs(lexa.hud.state) do
		local elems = state.elements
		local player = minetest.get_player_by_name(name)

		-- local wave_active_changed =
		-- 	force or not last_status or
		-- 	(status.wait == 0 and last_status.wait > 0) or
		-- 	(status.wait > 0 and last_status.wait == 0)

		local wave_progress = math.min(math.max(status.wait == 0
			and status.enemies / math.max(status.enemies_max, 1)
			or status.wait / math.max(status.wait_max, 1), 0))

		local wave_progress_pixel = math.floor(wave_progress * BAR_FULL_WIDTH)

		-- if wave_active_changed or wave_progress_pixel ~= last_progress_pixel then
			local image = '[combine:' .. wave_progress_pixel .. 'x16:0,0=' ..
			(status.wait == 0 and 'lexa_hud_progress_bar_fill_active.png' or 'lexa_hud_progress_bar_fill.png')

			player:hud_change(elems.match_bar_fill, 'text', image)
			last_progress_pixel = wave_progress_pixel
		-- end
--
		-- local wave_status_changed = wave_active_changed or
			-- force or not last_status or
			-- (status.wait == 0 and status.enemies ~= last_status.enemies) or
			-- (status.wait > 0 and math.floor(status.wait) ~= math.floor(last_status.wait))

		-- if wave_status_changed then
			player:hud_change(elems.match_wave_status, 'text', lexa.text.render_text(
				(status.wait == 0 and ('[!count_enemies] ' .. status.enemies)
				or ('[!count_time] ' .. format_time(math.floor(status.wait)))) .. ' Remaining...'))
		-- end

		-- local match_status_changed =
		-- 	force or not last_status or
		-- 	last_status.wave_max ~= status.wave_max or
		-- 	last_status.wave ~= status.wave

		-- if match_status_changed or wave_active_changed then
			player:hud_change(elems.match_match_status, 'text', lexa.text.render_text('[!count_wave' ..
				(status.wait == 0 and '_active' or '') .. '] Wave ' .. status.wave ..
				(status.wave_max and status.wave_max > 0 and ('/' .. status.wave_max) or '')))
		-- end

		last_status = table.copy(status)
	end
end

-- Add the elements to the hud for the player specified.
table.insert(lexa.hud.callbacks.register, function(player)
	local elems = lexa.hud.state[player:get_player_name()].elements

	elems.match_bar_background = player:hud_add({
		hud_elem_type = 'image',
		text = 'lexa_hud_progress_bar_background.png',
		position = { x = 0.5, y = 0 },
		scale = { x = 3, y = 3 },
		alignment = { x = 1, y = 1 },
		offset = { x = -BAR_FULL_WIDTH / 2 * 3, y = 8 }
	})

	elems.match_bar_fill = player:hud_add({
		hud_elem_type = 'image',
		text = 'lexa_hud_hidden.png',
		position = { x = 0.5, y = 0 },
		scale = { x = 3, y = 3 },
		alignment = { x = 1, y = 1 },
		offset = { x = -BAR_FULL_WIDTH / 2 * 3, y = 8 }
	})

	elems.match_bar_frame = player:hud_add({
		hud_elem_type = 'image',
		text = 'lexa_hud_progress_bar_frame.png',
		position = { x = 0.5, y = 0 },
		scale = { x = 3, y = 3 },
		alignment = { x = 1, y = 1 },
		offset = { x = -BAR_FULL_WIDTH / 2 * 3, y = 8 }
	})

	elems.match_wave_status = player:hud_add({
		hud_elem_type = 'image',
		text = lexa.text.render_text('[!count_time]'),
		position = { x = 0.5, y = 0 },
		scale = { x = 2, y = 2 },
		alignment = { x = 1, y = 1 },
		offset = { x = -336, y = 22 }
	})

	elems.match_match_status = player:hud_add({
		hud_elem_type = 'image',
		text = lexa.text.render_text('[!count_wave]'),
		position = { x = 0.5, y = 0 },
		scale = { x = 2, y = 2 },
		alignment = { x = -1, y = 1 },
		offset = { x = 336, y = 22 }
	})

	lexa.hud.refresh_bar(true)
end)
