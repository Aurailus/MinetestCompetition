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

local function get_ores(pos)
	local count = { copper = 0, titanium = 0, cobalt = 0 }

	for _, pos in ipairs({
			vector.add(pos, vector.new(0, -1, 0)),
			vector.add(pos, vector.new(1, -1, 0)),
			vector.add(pos, vector.new(0, -1, 1)),
			vector.add(pos, vector.new(1, -1, 1))
		}) do

		local node = minetest.get_node(pos)
		local def = minetest.registered_nodes[node.name]
		if def and def._ore_type then count[def._ore_type] = count[def._ore_type] + 1 end
	end

	local max = count.copper > count.titanium and count.copper > count.cobalt and 'copper' or count.cobalt > count.titanium and 'titanium' or 'cobalt'

	return max, count[max] / 4
end

local build_cost = { copper = 10 }

local spawn_offset = {
	[0] = vector.new(0, 0, -0.6),
	[1] = vector.new(-0.6, 0, 0),
	[2] = vector.new(0, 0, 0.5),
	[3] = vector.new(0.5, 0, 0)
}

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
	paramtype2 = 'facedir',
	sunlight_propagates = true,
	groups = {
		oddly_breakable_by_hand = 3,
		dig_game = 1,
		enemy_target = 70
	},
	drop = '',
	on_place = lexa.materials.place(build_cost),
	on_dig = lexa.materials.dig(build_cost),
	after_place_node = function(pos)
		local node = minetest.get_node(pos)

		minetest.chat_send_all(tostring(node.param2))

		local base_pos = table.copy(pos)
		if node.param2 == 1 or node.param2 == 2 then base_pos.z = base_pos.z - 1 end
		if node.param2 == 3 or node.param2 == 2 then base_pos.x = base_pos.x - 1 end

		local type, count = get_ores(base_pos)

		local meta = minetest.get_meta(pos)
		meta:set_string('type', type)

		if count > 0 then
			local timer = minetest.get_node_timer(pos)
			timer:start(3 - count * 2.5)
		end

		minetest.add_entity(base_pos, 'lexa_factory:drill_entity', minetest.serialize({ node_pos = pos }))
	end,
	on_timer = function(pos)
		local node = minetest.get_node(pos)
		local type = minetest.get_meta(pos):get_string('type')

		minetest.add_entity(vector.add(pos, spawn_offset[node.param2]), 'lexa_conveyor:ore_chunk', type)
		return true
	end,
	after_destruct = function(pos)
		local entities = minetest.get_objects_in_area(vector.add(pos, vector.new(-1, -1, -1)), vector.add(pos, vector.new(1, 1, 1)))
		for _, entity in ipairs(entities) do
			local lua_entity = entity:get_luaentity()
			if lua_entity and lua_entity.node_pos and lua_entity.node_pos.x == pos.x and lua_entity.node_pos.y == pos.y
				and lua_entity.node_pos.z == pos.z then
				entity:remove()
			end
		end
	end
})
