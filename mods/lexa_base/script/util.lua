--
-- Utility functions for use by the game.
--

-- Utility functions table.
lexa.util = {}

-- Horizontal cardinal directions.
lexa.util.dir_horizontal = {
	{ x =  0, y = 0, z =  1 },
	{ x =  1, y = 0, z =  0 },
	{ x =  0, y = 0, z = -1 },
	{ x = -1, y = 0, z =  0 },
}

-- Creates a new table by shallow-merging the values
function table.merge(t1, t2)
	local t_res = table.copy(t1)
	if t2 then
		for k, v in pairs(t2) do t_res[k] = v end
	end
	return t_res
end

-- Title-cases a string by replacing underscores with spaces and then capitalizing each word.
function lexa.util.title_case(str)
	return str:gsub('_', ' '):gsub('(%l)(%w*)', function(a,b) return string.upper(a) .. b end)
end

-- Returns the sign of a number as 1, -1, or 0.
function lexa.util.sign(num)
	if num < 0 then return -1
	elseif num > 0 then return 1
	else return 0 end
end
