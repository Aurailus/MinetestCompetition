local build_cost = { copper = 5 }

minetest.register_node('lexa_conveyor:distributor', {
	description = 'Distributor',
	_cost = build_cost,
	drawtype = 'mesh',
	use_texture_alpha = 'clip',
	mesh = 'lexa_conveyor_machine.b3d',
	tiles = { 'lexa_conveyor_distributor.png' },
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
	paramtype2 = 'facedir',
	sunlight_propagates = true,
	groups = {
		conveyor = 3,
		dig_game = 1,
	},
	_conveyor_function = function(node_pos, item, delta)
		local node = minetest.get_node(node_pos)
		local dir = minetest.facedir_to_dir(node.param2)
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
		else
			local main_axis = dir.x ~= 0 and 'x' or 'z'
			local norm_axis = dir.x == 0 and 'x' or 'z'

			if util.sign(obj_vel[main_axis]) + util.sign(dir[main_axis]) == 0
				or (obj_vel[norm_axis] < 0 and obj_pos_rel[norm_axis] > 0.05)
				or (obj_vel[norm_axis] > 0 and obj_pos_rel[norm_axis] < -0.05) then
				-- Bad entry, stop the item.
				obj_vel.x = 0
				obj_vel.z = 0
				item.object:set_velocity(obj_vel)
			elseif obj_pos_rel[main_axis] * util.sign(dir[main_axis]) < 0
				and obj_pos_rel[main_axis] * util.sign(dir[main_axis]) > -0.05 then
			  -- Awaiting direction
				local meta = minetest.get_meta(node_pos)
				local last_dir = meta:get_int('last_dir')

				local found_dir = nil
				for i = last_dir + 1, last_dir + 4 do
					local i_mod = (i - 1) % 4 + 1
					local adj = util.cardinal_vectors[i_mod]
					if minetest.get_item_group(minetest.get_node(vector.add(node_pos, adj)).name, 'conveyor') ~= 0 then
						found_dir = i_mod
						break
					end
				end

				if found_dir ~= nil then
					local dir_vec = found_dir and util.cardinal_vectors[found_dir] or dir
					obj_pos[main_axis] = node_pos[main_axis]
					obj_pos[norm_axis] = node_pos[norm_axis]
					meta:set_int('last_dir', found_dir)
					item.object:set_pos(obj_pos)
					item.object:set_velocity(dir_vec)
				end
			elseif obj_pos_rel[main_axis] * util.sign(dir[main_axis]) <= -0.05 then
				-- Move the item
				item.object:set_velocity(vector.multiply(dir, lexa.conveyor.speed))
			end
		end
	end,
	on_place = lexa.materials.place(build_cost),
	on_dig = lexa.materials.dig(build_cost),
	drop = ''
})
