-- The minimum max_forceloaded_blocks for the game to work
local REQUIRED_FORCELOADED_BLOCKS = 10000

-- If the max_forceloaded_blocks is less than what is required, prevent the game from being run.
local forceload_is_good = tonumber((minetest.settings:get('max_forceloaded_blocks') or 0)) >= REQUIRED_FORCELOADED_BLOCKS

if not forceload_is_good then
	minetest.register_on_joinplayer(function(player)
		minetest.kick_player(player:get_player_name(),
			'\n\nThe server is misconfigured, please set max_forceloaded_blocks = 10000 in minetest.conf.')
	end)
end

-- Positions to be considered 'adjacent' for graph generation and pathfinding.
local adjacent_list = {
	[{ x =  1, y = -1, z =  0 }] = 1,
	[{ x = -1, y = -1, z =  0 }] = 1,
	[{ x =  0, y = -1, z =  1 }] = 1,
	[{ x =  0, y = -1, z = -1 }] = 1,
	[{ x =  1, y =  0, z =  0 }] = 1,
	[{ x = -1, y =  0, z =  0 }] = 1,
	[{ x =  0, y =  0, z =  1 }] = 1,
	[{ x =  0, y =  0, z = -1 }] = 1,
	[{ x =  1, y =  0, z = -1 }] = 1.3,
	[{ x = -1, y =  0, z = -1 }] = 1.3,
	[{ x =  1, y =  0, z =  1 }] = 1.3,
	[{ x = -1, y =  0, z =  1 }] = 1.3,
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

local function build_graph(start)
	local start_time = minetest.get_us_time()
	local scanned = { minetest.pos_to_string(start) }
	local to_scan = { start }

	local graph = {

		-- The player's spawn point vector.
		player_spawn = start,

		-- An array of enemy spawn point vectors.
		enemy_spawns = {},

		-- A 3d array (x, z, y) of valid map nodes.
		nodes = {},

		-- The number of map nodes that were found.
		count = 0
	}

	while #to_scan > 0 do
		local pos = table.remove(to_scan, #to_scan)
		local pos_str = minetest.pos_to_string(pos)

		graph.count = graph.count + 1

		if not graph.nodes[pos.x] then graph.nodes[pos.x] = {} end
		if not graph.nodes[pos.x][pos.z] then graph.nodes[pos.x][pos.z] = {} end
		if not graph.nodes[pos.x][pos.z][pos.y] then graph.nodes[pos.x][pos.z][pos.y] = 1 end

		for adj, _ in pairs(adjacent_list) do
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

--
-- Emerges and forceloads the area between min_pos and max_pos (inclusive)
-- When the load is complete, calls the callback function with three parameters:
-- A function to unload the loaded area, the number of blocks loaded, and the time it took to emerge the area in ms.
--
-- @param min_pos - The minimum position of the area to emerge
-- @param max_pos - The maximum position of the area to emerge
-- @param callback - The callback to call when the area is emerged.
--

local function forceload_area(min_pos, max_pos, cb)
	local start_time = minetest.get_us_time()

	local function free()
		for x = math.floor(min_pos.x / 16), math.ceil(max_pos.x / 16) do
			for z = math.floor(min_pos.y / 16), math.ceil(max_pos.y / 16) do
				for y = math.floor(min_pos.z / 16), math.ceil(max_pos.z / 16) do
					minetest.forceload_free_block({ x = x, y = y, z = z }, true)
				end
			end
		end
	end

	local function forceload()
		local loaded = 0

		for x = math.floor(min_pos.x / 16), math.ceil(max_pos.x / 16) do
			for z = math.floor(min_pos.y / 16), math.ceil(max_pos.y / 16) do
				for y = math.floor(min_pos.z / 16), math.ceil(max_pos.z / 16) do
					local pos = { x = x, y = y, z = z }
					if not minetest.forceload_block(pos, true) then
						minetest.chat_send_all('[Error] Failed to forceload block at ' .. minetest.pos_to_string(pos) .. '.')
					end
					loaded = loaded + 1
				end
			end
		end

		local duration = math.floor((minetest.get_us_time() - start_time) / 1000)
		cb(free, loaded, duration)
	end

	minetest.emerge_area(min_pos, max_pos, function(_, _, remaining)
		if remaining == 0 then forceload() end
	end)
end

--
-- Returns the score for a node at the given position in the graph.
-- If the node does not exist in the graph, returns nil.
--
-- @param graph - The graph to search.
-- @param pos - The position of the node to search for.
--

local function get_node_score(graph, pos)
	if graph.nodes[pos.x] == nil then return nil end
	if graph.nodes[pos.x][pos.z] == nil then return nil end
	return graph.nodes[pos.x][pos.z][pos.y]
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

local function find_path(graph, from, to, random)
	local to_pos_str = minetest.pos_to_string(to)

	print('from: ' .. minetest.pos_to_string(from) .. ', to: ' .. to_pos_str)

	local closed = {}
	local open = {}

	local function add_node_to_open(pos, parent, cost)
		local g = parent and parent.g + (cost or 1) or 0
		local h = math.sqrt((pos.x - to.x)^2 + (pos.y - to.y)^2 + (pos.z - to.z)^2)
		--  + (((pos.x + pos.y + pos.z) % (random or 1)) / random * 3)
		local f = g + h

		local node = {
			pos = pos,
			parent = parent,
			f = f, g = g, h = h,
		}

		open[minetest.pos_to_string(pos)] = node
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
		-- print(minetest.pos_to_string(lowest.pos))

		if lowest_pos_str == to_pos_str then
			last_node = lowest
			break
		end

		-- print('scanning adj')

		for adj, cost in pairs(adjacent_list) do
			local adj_pos = { x = lowest.pos.x + adj.x, y = lowest.pos.y + adj.y,	z = lowest.pos.z + adj.z }
			local adj_pos_str = minetest.pos_to_string(adj_pos)

			local score = get_node_score(graph, adj_pos)
			-- print('adj: ' .. adj_pos_str .. ', score: ' .. tostring(score))
			if score ~= nil and closed[adj_pos_str] == nil then
				if open[adj_pos_str] == nil or lowest.g + cost <= open[adj_pos_str].g then
					add_node_to_open(adj_pos, lowest, cost)
				end
			end
		end
	end

	-- print(dump(open))
	-- print(dump(closed))
	-- for pos, _ in pairs(closed) do
	-- 	minetest.add_particle({
	-- 		pos = minetest.string_to_pos(pos),
	-- 		size = 16,
	-- 		expirationtime = 3,
	-- 		texture = 'pathfinding_indicator.png^[colorize:#FF0000'
	-- 	})
	-- end
	-- for pos, _ in pairs(open) do
	-- 	minetest.add_particle({
	-- 		pos = minetest.string_to_pos(pos),
	-- 		size = 16,
	-- 		expirationtime = 3,
	-- 		texture = 'pathfinding_indicator.png^[colorize:#00FF00'
	-- 	})
	-- end

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

minetest.register_chatcommand('init_graph', {
	params = '',
	description = 'Graphs pathfinding nodes',
	func = function(name)
		local spawn_pos = { x = 9, y = 2, z = -36 }
		local map_min = { x = -85, y = -38, z = -156 }
		local map_size = { x = 320, y = 160, z = 320 }

		forceload_area(map_min, vector.add(map_min, map_size), function(_, loaded, forceload_duration)
			minetest.chat_send_all('Force loaded ' .. loaded .. ' blocks in ' .. forceload_duration .. 'ms.')
			local graph, graph_duration = build_graph(spawn_pos)
			minetest.chat_send_all('Graphed ' .. graph.count .. ' nodes in ' .. graph_duration .. ' ms.')

			for i, spawn in ipairs(graph.enemy_spawns) do

				local start_time = minetest.get_us_time()
				local path = find_path(graph, spawn, graph.player_spawn, i + 4)
				local duration = math.floor((minetest.get_us_time() - start_time) / 1000)
				for _, node in ipairs(path) do
					minetest.add_particle({
						pos = node,
						size = 16,
						expirationtime = 3,
						texture = 'pathfinding_indicator.png'
					})
				end

				minetest.chat_send_all('Path from enemy spawn ' .. i .. ' is ' .. #path .. ' nodes long, found in ' .. duration .. ' ms.')
			end
		end)
	end
})
