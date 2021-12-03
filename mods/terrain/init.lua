minetest.register_node('terrain:ground', {
	tiles = { 'terrain_ground.png' },
	description = 'Ground',
	groups = { oddly_breakable_by_hand = 2 }
})

minetest.register_node('terrain:stone_green', {
	tiles = { { name = 'terrain_stone_green.png', align_style = 'world', scale = 2 } },
	description = 'Green Stone',
	groups = { oddly_breakable_by_hand = 2 }
})

minetest.register_node('terrain:grass_teal_on_stone_green', {
	tiles = {
		{ name = 'terrain_grass_teal_top.png', align_style = 'world', scale = 4 },
		{ name = 'terrain_stone_green.png', align_style = 'world', scale = 2 },
		'([combine:16x16:0,0=terrain_stone_green.png)^terrain_grass_teal_side.png'
	},
	description = 'Teal Grass on Green Stone',
	groups = { oddly_breakable_by_hand = 2 }
})

minetest.register_node('terrain:fern', {
	drawtype = 'mesh',
	mesh = 'terrain_fern.b3d',
	tiles = { 'terrain_fern.png' },
	description = 'Fern',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = { -4/16, -8/16, -4/16, 4/16, -4/16, 4/16 }
	},
	groups = {
		oddly_breakable_by_hand = 3,
	}
})

minetest.register_node('terrain:tall_grass', {
	drawtype = 'plantlike',
	tiles = { 'terrain_tall_grass.png' },
	description = 'Tall Grass',
	paramtype = 'light',
	paramtype2 = 'degrotate',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = { -7/16, -8/16, -7/16, 7/16, 0/16, 7/16 }
	},
	groups = {
		oddly_breakable_by_hand = 3,
	},
	on_construct = function(pos)
		minetest.swap_node(pos, { name = 'terrain:tall_grass', param2 = math.floor(math.random() * 24) * 20 })
		print(minetest.get_node(pos).param2)
	end
})

minetest.register_node('terrain:ore_copper', {
	drawtype = 'mesh',
	mesh = 'terrain_ore.b3d',
	tiles = { 'terrain_stone_green.png', 'terrain_ore_copper.png' },
	description = 'Copper Ore',
	paramtype2 = 'facedir',
	groups = {
		oddly_breakable_by_hand = 3,
	}
})

minetest.register_node('terrain:ore_coal', {
	drawtype = 'mesh',
	mesh = 'terrain_ore.b3d',
	tiles = { 'terrain_stone_green.png', 'terrain_ore_coal.png' },
	description = 'Coal Ore',
	paramtype2 = 'facedir',
	groups = {
		oddly_breakable_by_hand = 3,
	}
})

minetest.override_item('', {
	range = 10.0,
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			oddly_breakable_by_hand = { times={ [1] = 0.5, [2] = 0.30, [3] = 0.15 }, uses = 0 }
		},
		damage_groups = { fleshy = 1 },
	}
})

local plat_y = -5
local plat_size = 20

minetest.register_on_generated(function(a, b)
	local min = vector.new(math.max(-plat_size, a.x), plat_y, math.max(-plat_size, a.z))
	local max = vector.new(math.min(plat_size, b.x), plat_y, math.min(plat_size, b.z))

	if (max.y < plat_y or min.y > plat_y) then return end

	for x = min.x, max.x do
		for z = min.z, max.z do
			minetest.set_node(vector.new(x, plat_y, z), { name = 'terrain:ground' })
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	if player.name == 'singleplayer' then
		minetest.set_player_privs('singleplayer', { fly = true, teleport = true, noclip = true, fast = true, give = true })
		player:override_day_night_ratio(1)
	end
end)

minetest.register_entity('terrain:copper_chunk', {
	visual = 'mesh',
	visual_size = vector.new(10, 10, 10),
	textures = { 'terrain_chunk_copper.png' },
	mesh = 'terrain_chunk.b3d',
	physical = true,
	stepheight = 4.1/16,
	collisionbox = { -4/16, 0, -4/16, 4/16, 4/6, 4/16 },
	selectionbox = { -4/16, 0, -4/16, 4/16, 4/16, 4/16 },
	on_activate = function(self)
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
		-- if not conveyor_below then
		-- 	self.object:set_velocity(vector.new(0, self.object:get_velocity().y, 0))
		-- 	self.last_direction = vector.new()
		-- end

		local pos_y = self.object:get_pos().y
		if not move_result.touching_ground or not conveyor_below then
			-- local last_vel = self.object:get_velocity()
			-- self.object:set_velocity(vector.new(last_vel.x, (last_vel.y - 0.1) * 1.05, last_vel.z))
			-- return
		end

		if conveyor_below then
			local dir = minetest.facedir_to_dir(node.param2)
			print(dump(dir))
			local vel = { x = dir.x, y = self.object:get_velocity().y, z = dir.z }
			self.object:set_velocity(vel)
		end
	end
})

minetest.register_chatcommand('copper', {
	params = '',
	description = 'aaa',
	func = function(name)
		local player = minetest.get_player_by_name(name)
		minetest.add_entity( vector.round(player:get_pos()), 'terrain:copper_chunk')
	end
})
