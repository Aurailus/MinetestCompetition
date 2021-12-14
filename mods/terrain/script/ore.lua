local ores = { 'coal', 'copper', 'titanium', 'cobalt', 'iridium' }

minetest.register_entity('terrain:ore_chunk', {
	visual = 'mesh',
	visual_size = vector.new(10, 10, 10),
	mesh = 'terrain_chunk.b3d',
	physical = true,
	stepheight = 4.1/16,
	collisionbox = { -4/16, 0, -4/16, 4/16, 4/6, 4/16 },
	selectionbox = { -4/16, 0, -4/16, 4/16, 4/16, 4/16 },
	on_activate = function(self, static_data)
		self.type = static_data
		self.object:set_properties({ textures = { 'terrain_chunk_' .. self.type .. '.png' }})

		self.last_direction = vector.new(0, 0, 0)
		self.object:set_rotation(vector.new(0, math.rad(math.floor(math.random() * 12) * 30), 0))
		self.object:set_acceleration(vector.new(0, -9.8, 0))
	end,
	on_punch = function(self)
		self.object:remove()
	end,
	on_step = function(self, _, move_result)
		local node = minetest.get_node(vector.round(vector.add(
			vector.multiply(self.last_direction, -0.5), self.object:get_pos())))

		local conveyor_below = (((minetest.registered_nodes[node.name] or {}).groups or {}).conveyor or 0) > 0

		if conveyor_below then
			self.last_direction = minetest.facedir_to_dir(node.param2)
		end

		if conveyor_below then
			local dir = minetest.facedir_to_dir(node.param2)
			local vel = { x = dir.x, y = self.object:get_velocity().y, z = dir.z }
			self.object:set_velocity(vel)
		end
	end,
	get_staticdata = function(self)
		return self.type
	end
})

for _, type in ipairs(ores) do
	terrain.register_node_variations('ore_' .. type, { 'base', 'beach', 'black', 'mountain', 'shist' }, {
		drawtype = 'mesh',
		mesh = 'terrain_ore.b3d',
		tiles = {
			{ name = 'terrain_stone', align_style = 'world', scale = 2 },
			function() return 'terrain_ore_' .. type .. '.png' end
		},
		description = type .. ' Ore',
		paramtype2 = 'facedir',
		groups = { creative_dig = 1 }
	})
end

minetest.register_chatcommand('spawnore', {
	params = '<type>',
	description = 'Spawns an ore chunk',
	func = function(name, type)
		local player = minetest.get_player_by_name(name)
		minetest.add_entity(vector.round(player:get_pos()), 'terrain:ore_chunk', type)
	end
})
