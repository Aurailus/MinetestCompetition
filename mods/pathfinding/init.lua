local nodes_visible = false

function register_pathfinding_node(name, def)
	minetest.register_node('pathfinding:' .. name, table.merge({
		description = name,
		drawtype = 'glasslike_framed',
		tiles = { 'pathfinding_' .. name .. '_frame.png', 'pathfinding_' .. name .. '.png' },
		walkable = false,
		paramtype = 'light',
		sunlight_propagates = true,
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
			stack:take_item()
			return stack
		end
	}, def or {}))

	minetest.register_node('pathfinding:' .. name .. '_hidden', table.merge({
		description = name,
		drawtype = 'airlike',
		tiles = { 'pathfinding_' .. name .. '_frame.png', 'pathfinding_' .. name .. '.png' },
		walkable = false,
		pointable = false,
		paramtype = 'light',
		sunlight_propagates = true,
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

minetest.register_chatcommand('pathfinding', {
	params = '',
	description = 'Toggles pathfinding node visibility',
	func = function()
		nodes_visible = not nodes_visible
	end
})

register_pathfinding_node('build_deny')
register_pathfinding_node('enemy_barrier')
register_pathfinding_node('player_barrier', { walkable = true })
