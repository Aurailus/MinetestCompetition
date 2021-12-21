local build_cost = { copper = 50 }

minetest.register_node('lexa_turret:turret_base', {
	description = 'Turret',
	_cost = build_cost,
	drawtype = 'mesh',
	use_texture_alpha = 'clip',
	mesh = 'lexa_turret_base.b3d',
	tiles = { 'lexa_turret_base.png' },
	use_texture_alpha = 'opaque',
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
	sunlight_propagates = true,
	groups = {
		conveyor = 3,
		dig_game = 1,
		enemy_target = 70
	},
	drop = '',
	on_place = lexa.materials.place(build_cost),
	on_dig = lexa.materials.dig(build_cost),
	after_place_node = function(pos)
		minetest.set_node(vector.add(pos, vector.new(0, 1, 0)), { name = 'lexa_turret:turret_mid' })
		minetest.set_node(vector.add(pos, vector.new(0, 2, 0)), { name = 'lexa_turret:turret_top' })
	end,
	after_dig_node = function(pos)
		minetest.set_node(vector.add(pos, vector.new(0, 1, 0)), { name = 'air' })
		minetest.set_node(vector.add(pos, vector.new(0, 2, 0)), { name = 'air' })
	end
	-- _conveyor_function = function(node_pos, item, delta)
	-- 	local obj_pos = item.object:get_pos()
	-- 	local obj_vel = item.object:get_velocity()
	-- 	local obj_pos_rel = vector.subtract(obj_pos, node_pos)

	-- 	if obj_pos_rel.y > 0.5 then
	-- 		-- Make the item fall if it's not on the surface of the block.
	-- 		obj_vel.y = obj_vel.y - 9.8 * delta
	-- 		item.object:set_velocity(obj_vel)
	-- 	elseif obj_pos_rel.y < 0.5 then
	-- 		-- Put it back on the block if it's below the surface, set vel.y to 0.
	-- 		obj_pos.y = node_pos.y + 0.5
	-- 		obj_vel.y = 0
	-- 		item.object:set_pos(obj_pos)
	-- 		item.object:set_velocity(obj_vel)
	-- 	elseif obj_vel.x == 0 and obj_vel.z == 0 then
	-- 		-- Give the item a default direction to stop it from stalling
	-- 		obj_vel.x = lexa.conveyor.speed
	-- 		item.object:set_velocity(obj_vel)
	-- 	end
	-- end,
})

minetest.register_node('lexa_turret:turret_mid', {
	tiles = { 'lexa_turret_side.png' }
})

minetest.register_node('lexa_turret:turret_top', {
	tiles = { 'lexa_turret_side.png' }
})
