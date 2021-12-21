minetest.register_entity('lexa_materials:ore_chunk', {
	visual = 'mesh',
	mesh = 'lexa_materials_chunk.b3d',
	visual_size = vector.new(10, 10, 10),
	collisionbox = { -4/16, -8/16 -4/16, 4/16, -4/16, 4/16 },
	selectionbox = { -4/16, -8/16, -4/16, 4/16, -4/16, 4/16 },
	on_activate = function(self, static_data)
		lexa.conveyor.entity.on_activate(self)
		self.type = static_data
		self.object:set_properties({ textures = { 'lexa_materials_chunk_' .. self.type .. '.png' } })
		self.object:set_rotation(vector.new(0, math.rad(math.floor(math.random() * 12) * 30), 0))
	end,
	on_punch = function(self) self.object:remove() end,
	on_step = lexa.conveyor.entity.on_step,
	get_staticdata = function(self) return self.type end
})

minetest.register_chatcommand('spawn_ore', {
	params = '<type>',
	description = 'Spawns an ore chunk',
	func = function(name, type)
		local player = minetest.get_player_by_name(name)
		minetest.add_entity(vector.round(player:get_pos()), 'lexa_materials:ore_chunk', type)
	end
})
