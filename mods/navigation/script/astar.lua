-- local function serialize_pos(pos)
-- 	return pos.x .. ' ' .. pos.y .. ' ' .. pos.z
-- end

-- --
-- -- Returns a path between the two positions provided using modified A* pathfinding.
-- -- Requires a graph generated with build_graph() to base the pathfinding on.
-- --
-- -- @param graph - The graph of the map nodes.
-- -- @param from - The start position of the path.
-- -- @param to - The end position of the path.
-- -- @returns the path from the start to the end, or nil if no path was found.
-- --

-- function navigation.find_path(graph, from, to)
-- 	local to_pos_str = serialize_pos(to)
-- 	local closed = {}
-- 	local open = RPQ.new(
-- 		function(v) return v.f end,
-- 		function(v) return serialize_pos(v.pos) end
-- 	)

-- 	--
-- 	-- Returns the score for a node at the given position in the graph.
-- 	-- If the node does not exist in the graph, returns nil.
-- 	--
-- 	-- @param graph - The graph to search.
-- 	-- @param pos - The position of the node to search for.
-- 	--

-- 	local function get_node_score(pos)
-- 		if graph.nodes[pos.y] == nil then return nil end
-- 		if graph.nodes[pos.y][pos.x] == nil then return nil end
-- 		return graph.nodes[pos.y][pos.x][pos.z]
-- 	end

-- 	--
-- 	-- Adds a node to the open list with the position, parent, and move pos provided.
-- 	-- If supplied, key_hint is used instead of recalculating the key for the node.
-- 	--

-- 	local function add_node_to_open(pos, parent, cost, key_hint)
-- 		local g = parent and parent.g + (cost or 1) or 0
-- 		local h = math.sqrt((pos.x - to.x)^2 + (pos.y - to.y)^2 + (pos.z - to.z)^2)
-- 		local f = g + h

-- 		open:insert({
-- 			pos = pos,
-- 			parent = parent,
-- 			f = f, g = g, h = h
-- 		}, key_hint or serialize_pos(pos))
-- 	end

-- 	add_node_to_open(from, nil)

-- 	local last_node = nil
-- 	while not open:is_empty() do
-- 		local lowest = open:remove()
-- 		local lowest_pos_str = serialize_pos(lowest.pos)

-- 		-- local lowest = nil

-- 		-- for open_pos_str, open in pairs(open) do
-- 		-- 	if lowest == nil or open.f < lowest.f then
-- 		-- 		lowest = open
-- 		-- 		lowest_pos_str = open_pos_str
-- 		-- 	end
-- 		-- end

-- 		-- if lowest == nil then break end

-- 		-- open[lowest_pos_str] = nil
-- 		closed[lowest_pos_str] = true

-- 		if lowest_pos_str == to_pos_str then
-- 			last_node = lowest
-- 			break
-- 		end

-- 		for adj, cost in pairs(navigation.adjacent_list) do
-- 			local adj_pos = { x = lowest.pos.x + adj.x, y = lowest.pos.y + adj.y,	z = lowest.pos.z + adj.z }
-- 			local adj_pos_str = serialize_pos(adj_pos)

-- 			local score = get_node_score(adj_pos)
-- 			if score ~= nil and closed[adj_pos_str] == nil then
-- 				local existing = open:get(adj_pos_str)
-- 				if existing == nil or lowest.g + cost + score <= existing.g then
-- 					if existing ~= nil then open:remove(existing) end
-- 					add_node_to_open(adj_pos, lowest, cost + score, adj_pos_str)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	if last_node then
-- 		local path = {}
-- 		local node = last_node
-- 		while node do
-- 			table.insert(path, node.pos)
-- 			node = node.parent
-- 		end
-- 		return path
-- 	end
-- end

--
-- Returns a path between the two positions provided using modified A* pathfinding.
-- Requires a graph generated with build_graph() to base the pathfinding on.
--
-- @param graph - The graph of the map nodes.
-- @param from - The start position of the path.
-- @param to - The end position of the path.
-- @returns the path from the start to the end, or nil if no path was found.
--

function navigation.find_path(graph, from, to)
	local to_pos_str = minetest.pos_to_string(to)
	local closed = {}
	local open = {}

	--
	-- Returns the score for a node at the given position in the graph.
	-- If the node does not exist in the graph, returns nil.
	--
	-- @param graph - The graph to search.
	-- @param pos - The position of the node to search for.
	--

	local function get_node_score(pos)
		if graph.nodes[pos.y] == nil then return nil end
		if graph.nodes[pos.y][pos.x] == nil then return nil end
		return graph.nodes[pos.y][pos.x][pos.z]
	end

	--
	-- Adds a node to the open list with the position, parent, and move pos provided.
	-- If supplied, key_hint is used instead of recalculating the key for the node.
	--

	local function add_node_to_open(pos, parent, cost, key_hint)
		local g = parent and parent.g + (cost or 1) or 0
		local h = math.sqrt((pos.x - to.x)^2 + (pos.y - to.y)^2 + (pos.z - to.z)^2)
		--  + (((pos.x + pos.y + pos.z) % (random or 1)) / random * 3)
		local f = g + h

		open[key_hint or minetest.pos_to_string(pos)] = {
			pos = pos,
			parent = parent,
			f = f, g = g, h = h,
		}
	end

	add_node_to_open(from, nil)

	local last_node = nil
	while true do
		local lowest = nil
		local lowest_pos_str = nil

		for open_pos_str, open in pairs(open) do
			if lowest == nil or open.f < lowest.f then
				lowest = open
				lowest_pos_str = open_pos_str
			end
		end

		if lowest == nil then break end

		open[lowest_pos_str] = nil
		closed[lowest_pos_str] = true

		if lowest_pos_str == to_pos_str then
			last_node = lowest
			break
		end

		for adj, cost in pairs(navigation.adjacent_list) do
			local adj_pos = { x = lowest.pos.x + adj.x, y = lowest.pos.y + adj.y,	z = lowest.pos.z + adj.z }
			local adj_pos_str = minetest.pos_to_string(adj_pos)

			local score = get_node_score(adj_pos)
			if score ~= nil and closed[adj_pos_str] == nil then
				local existing = open[adj_pos_str]
				if existing == nil or lowest.g + cost + score <= existing.g then
					add_node_to_open(adj_pos, lowest, cost + score, adj_pos_str)
				end
			end
		end
	end

	if last_node then
		local path = {}
		local node = last_node
		while node do
			table.insert(path, node.pos)
			node = node.parent
		end
		return path
	end
end
