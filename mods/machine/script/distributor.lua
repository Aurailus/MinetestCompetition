local dir_to_adj = {
	[1] = { x =  1, y = 0, z =  0 },
	[2] = { x =  0, y = 0, z =  1 },
	[3] = { x = -1, y = 0, z =  0 },
	[4] = { x =  0, y = 0, z = -1 }
}

-- minetest.register_entity('machine:distributor_entity', {
-- 	visual = 'mesh',
-- 	visual_size = vector.new(10, 10, 10),
-- 	mesh = 'machine_distributor_entity.b3d',
-- 	pointable = false,
-- 	on_activate = function(self, static_data)
-- 		self.node_pos = (minetest.deserialize(static_data) or {}).node_pos
-- 		self.dir = 0
-- 		self.delta = 0
-- 		self.till_next = 1
-- 	end,
-- 	on_step = function(self, delta)
-- 		self.delta = self.delta + delta

-- 		if self.till_next <= 0 then
-- 			local next = nil
-- 			for i = self.dir + 7, self.dir + 1, -1 do
-- 				local dir = (i - 1) % 4 + 1
-- 				local adj = vector.add(self.node_pos, dir_to_adj[dir])
-- 				local node = minetest.get_node(adj)
-- 				local is_conveyor = ((minetest.registered_nodes[node.name] or {}).groups or {}).conveyor

-- 				if is_conveyor then
-- 					next = dir
-- 					break
-- 				end
-- 			end

-- 			if next then self.dir = next end
-- 			self.till_next = 1
-- 			self.object:set_rotation({ x = 0, y = math.rad((next + 2) * 90), z = 0 })
-- 		else
-- 			self.till_next = self.till_next - delta
-- 		end

-- 		self.object:set_properties({
-- 			textures = {
-- 				'[combine:14x8:0,' .. (-(math.floor(self.delta * 20) % 4) * 8) .. '=machine_distributor_belt.png',
-- 				'machine_distributor_frame_entity.png'
-- 			}
-- 		})

-- 		-- local rot = math.floor(self.delta / 3) % 4
-- 		-- if not self.last_rot or rot ~= self.last_rot then
-- 		-- 	self.object:set_rotation({ x = 0, y = math.rad(rot * 90), z = 0 })
-- 		-- 	self.last_rot = rot
-- 		-- end
-- 	end,
-- 	get_staticdata = function(self)
-- 		return minetest.serialize({ node_pos = self.node_pos })
-- 	end
-- })

minetest.register_node('machine:distributor', {
	description = 'Distributor',
	_cost = { copper = 5 },
	drawtype = 'mesh',
	use_texture_alpha = 'clip',
	mesh = 'machine_distributor_2.b3d',
	inventory_image = 'machine_distributor_inventory.png',
	tiles = { 'machine_distributor_2.png' },
	use_texture_alpha = 'opaque',
	-- tiles = { 'machine_distributor_frame.png', 'machine_conveyor_belt_strip.png' },
	selection_box = {
		type = 'fixed',
		fixed = {
			{ -8/16, -2/16, -8/16, 8/16, 8/16, 8/16 },
			{ -10/16, -8/16, -10/16, 10/16, -2/16, 10/16 }
		}
	},
	collision_box = {
		type = 'fixed',
		fixed = { -8/16, -8/16, -8/16, 8/16, 8/16, 8/16 }
	},
	paramtype = 'light',
	paramtype2 = 'facedir',
	sunlight_propagates = true,
	groups = {
		conveyor = 3,
		creative_dig = 1,
	},
	drop = '',
	on_construct = function(pos)
		-- minetest.add_entity(pos, 'machine:distributor_entity', minetest.serialize({ node_pos = pos }))
	end,
	after_destruct = function(pos)
		local entities = minetest.get_objects_in_area(pos, pos)
		for _, entity in ipairs(entities) do
			local lua_entity = entity:get_luaentity()
			if lua_entity and lua_entity.node_pos.x == pos.x and lua_entity.node_pos.y == pos.y
				and lua_entity.node_pos.z == pos.z then
				entity:remove()
			end
		end
	end
})
