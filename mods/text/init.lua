local char_widths = {}

local glyphs = {}

local char_aliases = {
	[' '] = 'space',
	['!'] = 'exc',
	['"'] = 'quote',
	['#'] = 'hash',
	['%'] = 'per',
	['&'] = 'amp',
	["'"] = 'apos',
	['('] = 'lparen',
	[')'] = 'rparen',
	['*'] = 'mul',
	['+'] = 'plus',
	[','] = 'comma',
	['-'] = 'hyphen',
	['.'] = 'period',
	['/'] = 'slash',
	[':'] = 'colon',
	[';'] = 'semi',
	['<'] = 'lcarat',
	['='] = 'eq',
	['>'] = 'rcarat',
	['?'] = 'que',
	['@'] = 'at',
	['['] = 'lsquare',
	['\\'] = 'bslash',
	[']'] = 'rsquare',
	['^'] = 'caret',
	['_'] = 'under',
	['`'] = 'grave',
	['{'] = 'lcurly',
	['|'] = 'pipe',
	['}'] = 'rcurly',
	['~'] = 'tilde'
}

_G['text'] = {}

local modpath = minetest.get_modpath('text')

local function get_file_width(path)
	local f = io.open(path, 'rb')
	f:seek('set', 16)
	return tonumber(string.format('0x%x%x%x%x', f:read(4):byte(1, 4)))
end

for _, path in ipairs(minetest.get_dir_list(modpath .. '/textures/', false)) do
	local name = path:match('text_([^%.]+)%.png')
	if name then char_widths[name] = get_file_width(modpath .. '/textures/text_' .. name .. '.png') end
end

function text.register_glyph(name, path)
	local _, file = string.match(path, "(.-)([^\\/]-([^%.]+))$")
	glyphs[name] = { file = file, width = get_file_width(path) }
end

text.register_glyph('ss', modpath .. '/textures/text_ss.png')

function text.render_text(text)
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
			local glyph_tbl = glyphs[glyph]

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
			local alias = char_aliases[char] or char
			width = (char_widths[alias] or 1) - 1
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
