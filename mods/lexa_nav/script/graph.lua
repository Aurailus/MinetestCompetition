-- Positions to be considered 'adjacent' for graph generation and navigation.
lexa.nav.adjacent_list = {
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

local BASE_COST = 10
local MAGNET_STRENGTH = 10

--
-- Builds the map graph by recursively scanning the map for map nodes.
-- Requires the player spawn point as a start position, which must be a part of the map.
--
-- @param start - The player's spawn point.
-- @returns the graph of the map, and the time to generate it.
--

function lexa.nav.build_graph(start)
	local scan_nodes = {}
	local magnet_nodes = {}
	local enemy_spawn_nodes = {}

	for name, def in pairs(minetest.registered_nodes) do
		if def.groups['nav_traversable'] then
			scan_nodes[name] = true

			if def._navigation.magnet ~= 0 then
				magnet_nodes[name] = def._navigation.magnet
			end

			if def._navigation.spawn == 'enemy' then
				enemy_spawn_nodes[name] = true
			end
		end
	end

	local start_time = minetest.get_us_time()
	local scanned = { minetest.pos_to_string(start) }
	local to_scan = { start }

	local magnet_positions = {}

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
		if not graph.nodes[pos.y][pos.x][pos.z] then graph.nodes[pos.y][pos.x][pos.z] = BASE_COST end

		for adj, _ in pairs(lexa.nav.adjacent_list) do
			local adj_pos = { x = pos.x + adj.x, y = pos.y + adj.y,	z = pos.z + adj.z }
			local adj_pos_str = minetest.pos_to_string(adj_pos)

			if not scanned[adj_pos_str] then
				local node = minetest.get_node(adj_pos)

				if scan_nodes[node.name] then
					table.insert(to_scan, adj_pos)
					scanned[adj_pos_str] = true

					if enemy_spawn_nodes[node.name] then
						table.insert(graph.enemy_spawns, adj_pos)
					end

					if magnet_nodes[node.name] then
						table.insert(magnet_positions, adj_pos)
					end
				end
			end
		end
	end

	for _, pos in ipairs(magnet_positions) do
		local val = magnet_nodes[minetest.get_node(pos).name]
		local radius = math.abs(val)

		for x = pos.x - radius, pos.x + radius do
			for y = pos.y - radius, pos.y + radius do
				for z = pos.z - radius, pos.z + radius do
					local strength = math.max(1 - (vector.distance(pos, { x = x, y = y, z = z }) / radius), 0) *
						(val < 0 and -1 or 1)
					if strength ~= 0 then
						local res_cost = BASE_COST - strength * MAGNET_STRENGTH
						if graph.nodes[y] and graph.nodes[y][x] then
							local cur_value = graph.nodes[y][x][z]
							if cur_value and ((strength > 0 and cur_value > res_cost) or (strength < 0 and cur_value < res_cost)) then
								graph.nodes[y][x][z] = res_cost
							end
						end
					end
				end
			end
		end
	end

	local duration = math.floor((minetest.get_us_time() - start_time) / 1000)
	return graph, duration
end
