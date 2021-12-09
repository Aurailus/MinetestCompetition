-- Positions to be considered 'adjacent' for graph generation and pathfinding.
pathfinding.adjacent_list = {
	[{ x =  1, y = -1, z =  0 }] = 1,
	[{ x = -1, y = -1, z =  0 }] = 1,
	[{ x =  0, y = -1, z =  1 }] = 1,
	[{ x =  0, y = -1, z = -1 }] = 1,
	[{ x =  1, y =  0, z =  0 }] = 1,
	[{ x = -1, y =  0, z =  0 }] = 1,
	[{ x =  0, y =  0, z =  1 }] = 1,
	[{ x =  0, y =  0, z = -1 }] = 1,
	[{ x =  1, y =  0, z = -1 }] = 2^0.5,
	[{ x = -1, y =  0, z = -1 }] = 2^0.5,
	[{ x =  1, y =  0, z =  1 }] = 2^0.5,
	[{ x = -1, y =  0, z =  1 }] = 2^0.5,
	[{ x =  1, y =  1, z =  0 }] = 1,
	[{ x = -1, y =  1, z =  0 }] = 1,
	[{ x =  0, y =  1, z =  1 }] = 1,
	[{ x =  0, y =  1, z = -1 }] = 1
}

-- Nodes to be considered valid map nodes.
local map_nodes = {
	['pathfinding:navigation'] = true,
	['pathfinding:navigation_hidden'] = true,
	['pathfinding:player_spawn'] = true,
	['pathfinding:player_spawn_hidden'] = true,
	['pathfinding:enemy_spawn'] = true,
	['pathfinding:enemy_spawn_hidden'] = true
}

-- Nodes to be considered enemy spawn points
local enemy_spawn_nodes = {
	['pathfinding:enemy_spawn'] = true,
	['pathfinding:enemy_spawn_hidden'] = true
}

--
-- Builds the map graph by recursively scanning the map for map nodes.
-- Requires the player spawn point as a start position, which must be a part of the map.
--
-- @param start - The player's spawn point.
-- @returns the graph of the map, and the time to generate it.
--

function pathfinding.build_graph(start)
	local start_time = minetest.get_us_time()
	local scanned = { minetest.pos_to_string(start) }
	local to_scan = { start }

	local graph = {

		-- The player's spawn point vector.
		player_spawn = start,

		-- An array of enemy spawn point vectors.
		enemy_spawns = {},

		-- A 3d array (y, x, z) of valid map nodes.
		nodes = {},

		-- The number of map nodes that were found.
		count = 0
	}

	while #to_scan > 0 do
		local pos = table.remove(to_scan, #to_scan)
		local pos_str = minetest.pos_to_string(pos)

		graph.count = graph.count + 1

		if not graph.nodes[pos.y] then graph.nodes[pos.y] = {} end
		if not graph.nodes[pos.y][pos.x] then graph.nodes[pos.y][pos.x] = {} end
		if not graph.nodes[pos.y][pos.x][pos.z] then graph.nodes[pos.y][pos.x][pos.z] = 1 end

		for adj, _ in pairs(pathfinding.adjacent_list) do
			local adj_pos = { x = pos.x + adj.x, y = pos.y + adj.y,	z = pos.z + adj.z }
			local adj_pos_str = minetest.pos_to_string(adj_pos)

			if not scanned[adj_pos_str] then
				local node = minetest.get_node(adj_pos)

				if map_nodes[node.name] then
					table.insert(to_scan, adj_pos)
					scanned[adj_pos_str] = true

					if enemy_spawn_nodes[node.name] then
						table.insert(graph.enemy_spawns, adj_pos)
					end
				end
			end
		end
	end

	local duration = math.floor((minetest.get_us_time() - start_time) / 1000)
	return graph, duration
end
