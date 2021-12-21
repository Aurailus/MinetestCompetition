--
-- Functions for conveyor item enities to call to interact with the conveyor.
--

lexa.conveyor.entity = {}

lexa.conveyor.entity.on_activate = function(self)
	self.last_vel = vector.new(0, 0, 0)
	self.death_time = 0
end

lexa.conveyor.entity.on_step = function(self, delta)
	local node_pos = vector.round(vector.add(self.object:get_pos(), vector.new(0, -0.5, 0)))
	if not self.conveyor_function or not self.last_pos or self.last_pos ~= node_pos then
		self.conveyor_function = minetest.registered_nodes[minetest.get_node(node_pos).name]._conveyor_function or false
	end

	if self.conveyor_function and self.conveyor_function ~= false then
		local found = false
		local others = minetest.get_objects_inside_radius(
			vector.add(self.object:get_pos(), vector.multiply(self.last_vel, 0.2)), 0.2)
		for _, obj in ipairs(others) do
			local lua = obj:get_luaentity()
			if obj ~= self.object and lua and lua.name == 'lexa_map:ore_chunk' then
				found = true
				break
			end
		end

		if not found then
			self.conveyor_function(node_pos, self, delta)
			self.last_vel = self.object:get_velocity()
		else
			self.object:set_velocity(vector.new(0, 0, 0))
		end
	else
		self.death_time = self.death_time + delta
		if self.death_time > 1 then
			self.object:remove()
		else
			if self.death_time > 0.25 then
				if (self.death_time * 5) % 2 < 0.75 then
					if not self.hidden then
						self.object:set_properties({ textures = { 'lexa_hud_hidden.png' } })
						self.hidden = true
					end
				else
					if self.hidden then
						self.object:set_properties({ textures = { 'lexa_materials_chunk_' .. self.type .. '.png' } })
						self.hidden = false
					end
				end
			end

			local obj_pos = self.object:get_pos()
			obj_pos.y = node_pos.y + 0.99

			self.object:set_velocity(vector.new(0, 0, 0))
			self.object:set_pos(obj_pos)
		end
	end
end
