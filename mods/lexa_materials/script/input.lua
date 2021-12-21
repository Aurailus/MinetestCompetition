minetest.register_node('lexa_materials:input', {
	description = 'Input',
	tiles = {
		'lexa_materials_input_top.png',
		'lexa_materials_input.png'
	},
	groups = {
		dig_build = 1,
		conveyor = 3,
		enemy_target = 100
	},
	_conveyor_function = function(node_pos, item, delta)
		local type = item.type
		item.object:remove()

		local new = table.copy(lexa.match.state.materials)
		new[type] = new[type] + 1
		lexa.match.set_materials(new)
	end,
})
