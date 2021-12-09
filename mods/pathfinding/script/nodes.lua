local nodes_visible = false

function register_pathfinding_node(name, color, def)
	minetest.register_node('pathfinding:' .. name, table.merge({
		description = name,
		drawtype = 'glasslike_framed',
		tiles = { 'pathfinding_indicator_frame.png^[multiply:' .. color, 'pathfinding_indicator.png^[multiply:' .. color },
		walkable = false,
		paramtype = 'light',
		sunlight_propagates = true,
		drop = '',
		groups = {
			pathfinding = 1,
			pathfinding_visible = 1,
			['pathfinding_' .. name] = 1,
			creative_dig = 1
		},
		on_place = function(stack, player, target)
			local pos = target.above
			if nodes_visible then minetest.set_node(pos, { name = 'pathfinding:' .. name })
			else minetest.set_node(pos, { name = 'pathfinding:' .. name .. '_hidden' }) end
			return stack
		end
	}, def or {}))

	minetest.register_node('pathfinding:' .. name .. '_hidden', table.merge({
		description = name,
		drawtype = 'airlike',
		walkable = false,
		pointable = false,
		paramtype = 'light',
		sunlight_propagates = true,
		drop = '',
		groups = {
			pathfinding = 1,
			pathfinding_hidden = 1,
			['pathfinding_' .. name] = 1,
			creative_dig = 1,
			not_in_creative_inventory = 1
		}
	}, def))
end

minetest.register_abm({
	label = 'Making pathfinding nodes visible',
	nodenames = { 'group:pathfinding_hidden' },
	interval = 1,
	chance = 1,
	min_y = -300,
	max_y = 300,
	action = function(pos, node)
		if not nodes_visible then return end
		local node_name = node.name:gsub('_hidden', '')
		minetest.set_node(pos, { name = node_name })
	end
})

minetest.register_abm({
	label = 'Making pathfinding nodes hidden',
	nodenames = { 'group:pathfinding_visible' },
	interval = 1,
	chance = 1,
	min_y = -300,
	max_y = 300,
	action = function(pos, node)
		if nodes_visible then return end
		local node_name = node.name .. '_hidden'
		minetest.set_node(pos, { name = node_name })
	end
})

minetest.register_chatcommand('toggle_paths', {
	params = '',
	description = 'Toggles pathfinding node visibility',
	func = function()
		nodes_visible = not nodes_visible
	end
})

register_pathfinding_node('navigation', '#5CD9FF')
register_pathfinding_node('navigation_magnet', '#3DFF7E')
register_pathfinding_node('barrier', '#FF33A7', { walkable = true })
register_pathfinding_node('player_spawn', '#FFED47')
register_pathfinding_node('enemy_spawn', '#C53DFF')
