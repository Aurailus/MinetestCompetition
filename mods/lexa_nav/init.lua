lexa.nav = {}

lexa.require('rpq')
lexa.require('load')
lexa.require('astar')
lexa.require('nodes')
lexa.require('graph')

lexa.nav.graph = nil
local spawn_pos = { x = 9, y = 2, z = -36 }
local map_min = { x = -85, y = -38, z = -156 }
local map_size = { x = 320, y = 160, z = 320 }

function init_graph()
	local res, graph_duration = lexa.nav.build_graph(spawn_pos)
	lexa.nav.graph = res
	-- minetest.chat_send_all('Graphed ' .. navigation.graph.count .. ' nodes in ' .. graph_duration .. ' ms.')
end

minetest.register_chatcommand('refresh_graph', {
	params = '',
	description = 'Graphs navigation nodes',
	func = function(name)
		init_graph()
	end
})

minetest.register_chatcommand('test_paths', {
	params = '',
	description = 'Graphs paths from enemy spawns to player spawn',
	func = function(name)
		if lexa.nav.graph == nil then
			minetest.chat_send_all('Graph not initialized')
			return
		end

		minetest.chat_send_all('Graphing paths.')

		for i, spawn in ipairs(lexa.nav.graph.enemy_spawns) do
			local start_time = minetest.get_us_time()
			local path = lexa.nav.find_path(lexa.nav.graph, spawn, lexa.nav.graph.player_spawn, i + 4)
			local duration = math.floor((minetest.get_us_time() - start_time) / 1000)

			if path then
				for _, node in ipairs(path) do
					minetest.add_particle({
						pos = node,
						size = 16,
						expirationtime = 3,
						texture = 'navigation_indicator.png'
					})
				end

				minetest.chat_send_all('Path from enemy spawn ' .. i .. ' is ' .. #path .. ' nodes long, found in ' .. duration .. ' ms.')
			else
				minetest.chat_send_all('Path from enemy spawn ' .. i .. ' not found.')
			end
		end
	end
})

minetest.after(1, function()
	navigation.load_area(map_min, vector.add(map_min, map_size), function(_, loaded, forceload_duration)
		-- minetest.chat_send_all('Force loaded ' .. loaded .. ' blocks in ' .. forceload_duration .. 'ms.')
		init_graph()
	end)
end)
