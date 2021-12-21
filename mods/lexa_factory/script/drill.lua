minetest.register_entity('lexa_factory:drill_entity', {
	visual = 'mesh',
	visual_size = vector.new(10, 10, 10),
	textures = { 'lexa_factory_drill.png' },
	mesh = 'lexa_factory_drill_entity.b3d',
	pointable = false,
	static_save = false,
	on_activate = function(self, static_data)
		self.node_pos = (minetest.deserialize(static_data) or {}).node_pos
		minetest.after(math.random() * 10, function() self.object:set_animation({ x = 0, y = 375 }, 30, 0, true) end)
	end,
	get_staticdata = function(self)
		return minetest.serialize({ node_pos = self.node_pos })
	end
})

local build_cost = { copper = 10 }

minetest.register_node('lexa_factory:drill', {
	description = 'Drill',
	_cost = build_cost,
	drawtype = 'mesh',
	use_texture_alpha = 'clip',
	mesh = 'lexa_factory_drill_node.b3d',
	tiles = { 'lexa_factory_drill.png' },
	selection_box = {
		type = 'fixed',
		fixed = {
			{ -8/16, -8/16, -8/16, 24/16, 0/16, 24/16 },
			{ -7/16, -2/16, -7/16, 23/16, 24/16, 23/16 },
		}
	},
	collision_box = {
		type = 'fixed',
		fixed = { -8/16, -8/16, -8/16, 24/16, 24/16, 24/16 }
	},
	paramtype = 'light',
	paramtype2 = 'facedier',
	sunlight_propagates = true,
	groups = {
		oddly_breakable_by_hand = 3,
	},
	drop = '',
	on_place = lexa.materials.place(build_cost),
	on_dig = lexa.materials.dig(build_cost),
	on_construct = function(pos)
		minetest.add_entity(pos, 'lexa_factory:drill_entity', minetest.serialize({ node_pos = pos }))
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
