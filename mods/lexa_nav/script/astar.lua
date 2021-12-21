local function serialize_pos(pos)
	return (pos.x % 360) + (pos.y % 360) * 360 + (pos.z % 360) * 360 * 360
	-- return pos.x .. ' ' .. pos.y .. ' ' .. pos.z
end

--
-- Returns a path between the two positions provided using modified A* pathfinding.
-- Requires a graph generated with build_graph() to base the pathfinding on.
--
-- @param graph - The graph of the map nodes.
-- @param from - The start position of the path.
-- @param to - The end position of the path.
-- @returns the path from the start to the end, or nil if no path was found.
--

function lexa.nav.find_path(graph, from, to)
	local to_pos_str = serialize_pos(to)
	local closed = {}
	local open = RPQ.new(
		function(v) return v.f end,
		function(v) return (v.pos.x % 360) + (v.pos.y % 360) * 360 + (v.pos.z % 360) * 360 * 360 end
	)

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

	local from_h = math.sqrt((from.x - to.x)^2 + (from.y - to.y)^2 + (from.z - to.z)^2)

	open:insert({
		pos = from,
		f = from_h, g = 0, h = from_h
	}, serialize_pos(from))

	local last_node = nil
	while not open:is_empty() do
		local lowest = open:remove()
		local lowest_pos_str = serialize_pos(lowest.pos)
		closed[lowest_pos_str] = true

		if lowest_pos_str == to_pos_str then
			last_node = lowest
			break
		end

		for adj, cost in pairs(navigation.adjacent_list) do
			local adj_pos = { x = lowest.pos.x + adj.x, y = lowest.pos.y + adj.y,	z = lowest.pos.z + adj.z }
			local adj_pos_str = serialize_pos(adj_pos)

			local score = get_node_score(adj_pos)
			if score ~= nil and closed[adj_pos_str] == nil then
				local existing = open:get(adj_pos_str)
				if existing == nil or lowest.g + cost + score <= existing.g then
					if existing ~= nil then open:remove(existing) end

					local g = lowest.g + cost + score
					local h = math.sqrt((adj_pos.x - to.x)^2 + (adj_pos.y - to.y)^2 + (adj_pos.z - to.z)^2)
					local f = g + h

					open:insert({
						pos = adj_pos,
						parent = lowest,
						f = f, g = g, h = h
					}, adj_pos_str)
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
