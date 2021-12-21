lexa.text.char_widths = {}

local modpath = minetest.get_modpath('lexa_text') .. '/textures/'
for _, path in ipairs(minetest.get_dir_list(modpath, false)) do
	local name = path:match('ch_([^%.]+)%.png')
	if name then lexa.text.char_widths[name] = lexa.text.get_file_width(modpath .. 'text_' .. name .. '.png') end
end

function lexa.text.render_text(text)
	local total_width = 0
	local tbl = { 'placeholder' }

	local i = 1
	while i <= #text do
		local char = text:sub(i, i)

		local name = nil
		local width = nil

		if char == '[' and i < #text and text:sub(i + 1, i + 1) == '!' then
			local glyph_end = text:find(']', i)
			local glyph = text:sub(i + 2, glyph_end - 1)
			local glyph_tbl = lexa.text.glyphs[glyph]

			if not glyph_tbl then
				print('Glyph not found: ' .. glyph)
				name = 'text_unknown.png'
				width = 5
			else
				name = glyph_tbl.file
				width = glyph_tbl.width - 1
			end
			i = glyph_end + 1
		else
			local alias = lexa.text.char_aliases[char] or char
			width = (lexa.text.char_widths[alias] or 1) - 1
			name = 'text_' .. alias .. '.png'
			i = i + 1
		end

		table.insert(tbl, ':')
		table.insert(tbl, total_width)
		table.insert(tbl, ',0=')
		table.insert(tbl, name)

		total_width = total_width + width
	end

	tbl[1] = '[combine:' .. (total_width + 1) .. 'x12'
	return table.concat(tbl), total_width
end
