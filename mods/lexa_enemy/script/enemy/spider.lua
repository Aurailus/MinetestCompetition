minetest.register_entity('lexa_enemy:spider', {
	visual = 'mesh',
	visual_size = vector.new(14, 14, 14),
	textures = { 'lexa_enemy_spider.png' },
	mesh = 'lexa_enemy_spider.b3d',
	physical = true,
	collisionbox = { -0.25, -0.5, -0.25, 0.25, 0.25, 0.25 },
	on_activate = function(self, static_data)
		self.object:set_acceleration({x = 0, y = -10, z = 0})
		self.object:set_animation({ x = 0, y = 15 }, 30, 0, true)
	end,
	on_punch = function(self)
		self.object:remove()
	end,
	on_step = function(self, dtime, collision)
		if not self.path then
			self.object:remove()
			return
		end
			-- if not lexa.match.state.graph then return end

			-- local start = minetest.get_us_time()
			-- self.path = lexa.nav.find_path(
			-- 	lexa.match.state.graph, vector.round(self.object:get_pos()), lexa.match.state.graph.player_spawn)
			-- minetest.chat_send_all('Pathfinding took ' .. (minetest.get_us_time() - start) / 1000)

			-- if not self.path then return end
			-- self.path_index = #self.path - 1

			-- for _, node in ipairs(self.path) do
			-- 	minetest.add_particle({
			-- 		pos = node,
			-- 		size = 16,
			-- 		expirationtime = 3,
			-- 		texture = 'navigation_indicator.png'
			-- 	})
			-- end
		-- end

		local pos_2d = self.object:get_pos()
		pos_2d.y = 0

		local target = self.path[self.path_index]
		if target == nil then return end

		local target_2d = { x = target.x, y = 0, z = target.z }

		local target_dist = vector.distance(pos_2d, target_2d)

		if target_dist < 0.2 then
			self.path_index = self.path_index - 1
			if self.path_index < 1 then
				self.path = nil
				self.path_index = nil
				return
			end
		else
			local current_dir = self.object:get_rotation().y + math.pi / 2
			local target_dir_vec = vector.direction(pos_2d, target_2d)
			local target_dir = math.atan2(target_dir_vec.z, target_dir_vec.x)

			local to_dir = current_dir + (target_dir - current_dir) * 0.1
			local to_dir_vec = { x = math.cos(to_dir), y = 0, z = math.sin(to_dir) }

			self.object:set_rotation({ x = 0, y = to_dir - math.pi / 2, z = 0 })
			self.object:set_velocity({x = target_dir_vec.x * 3, y = self.object:get_velocity().y, z = target_dir_vec.z * 3})

			if collision.touching_ground and target.y > self.object:get_pos().y then
				self.object:set_velocity({x = self.object:get_velocity().x, y = 5, z = self.object:get_velocity().z })
			end
		end
	end
})


minetest.register_chatcommand('spawn_enemy', {
	params = '',
	privs = { cheats = true },
	description = 'Spawns an enemy at the player\'s position.',
	func = function(name, type)
		local player = minetest.get_player_by_name(name)
		minetest.add_entity(vector.round(player:get_pos()), 'lexa_enemy:spider', type)
	end
})
