local lexa.text.char_aliases = {
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

function lexa.text.get_file_width(path)
	local f = io.open(path, 'rb')
	f:seek('set', 16)
	return tonumber(string.format('0x%x%x%x%x', f:read(4):byte(1, 4)))
end
