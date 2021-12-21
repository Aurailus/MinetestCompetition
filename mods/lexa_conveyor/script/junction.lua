local build_cost = { copper = 5 }

minetest.register_node('lexa_conveyor:junction', {
	description = 'Junction',
	_cost = build_cost,
	drawtype = 'mesh',
	use_texture_alpha = 'clip',
	mesh = 'lexa_conveyor_machine.b3d',
	tiles = { 'lexa_conveyor_junction.png' },
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
	_conveyor_function = function(node_pos, item, delta)
		local obj_pos = item.object:get_pos()
		local obj_vel = item.object:get_velocity()
		local obj_pos_rel = vector.subtract(obj_pos, node_pos)

		if obj_pos_rel.y > 0.5 then
			-- Make the item fall if it's not on the surface of the block.
			obj_vel.y = obj_vel.y - 9.8 * delta
			item.object:set_velocity(obj_vel)
		elseif obj_pos_rel.y < 0.5 then
			-- Put it back on the block if it's below the surface, set vel.y to 0.
			obj_pos.y = node_pos.y + 0.5
			obj_vel.y = 0
			item.object:set_pos(obj_pos)
			item.object:set_velocity(obj_vel)
		elseif obj_vel.x == 0 and obj_vel.z == 0 then
			-- Give the item a default direction to stop it from stalling
			obj_vel.x = lexa.conveyor.speed
			item.object:set_velocity(obj_vel)
		end
	end,
	on_place = lexa.materials.place(build_cost),
	on_dig = lexa.materials.dig(build_cost),
	drop = ''
})
