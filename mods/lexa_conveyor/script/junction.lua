local conveyor_speed = 1

minetest.register_node('machine:junction', {
	description = 'Junction',
	_cost = { copper = 5 },
	drawtype = 'mesh',
	use_texture_alpha = 'clip',
	mesh = 'machine_distributor.b3d',
	tiles = { 'machine_junction.png' },
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
		creative_dig = 1,
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
			obj_vel.x = conveyor_speed
			item.object:set_velocity(obj_vel)
		end
	end,
	drop = ''
})
