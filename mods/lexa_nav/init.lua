lexa.nav = {}

lexa.require('rpq')
lexa.require('astar')
lexa.require('nodes')
lexa.require('graph')

minetest.register_chatcommand('test_paths', {
	params = '',
	privs = { cheats = true },
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
						texture = 'lexa_nav_indicator.png'
					})
				end

				minetest.chat_send_all('Path from enemy spawn ' .. i .. ' is ' .. #path .. ' nodes long, found in ' .. duration .. ' ms.')
			else
				minetest.chat_send_all('Path from enemy spawn ' .. i .. ' not found.')
			end
		end
	end
})
