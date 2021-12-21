lexa.text.glyphs = {}

function lexa.text.register_glyph(name, path)
	local _, file = string.match(path, '(.-)([^\\/]-([^%.]+))$')
	lexa.text.glyphs[name] = { file = file, width = lexa.text.get_file_width(path) }
end

lexa.text.register_glyph('ss', minetest.get_modpath('lexa_text') .. '/textures/text_ss.png')
