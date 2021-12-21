-- Whether or not the navigation nodes are visible.
local nav_visible = false

--
-- Registers an invisible navigation node that defines the navmesh of the map.
-- You can toggle the visibility and targeting of the node with /toggle_paths.
-- The properties below determine the functionality of the node.
--
-- @param def - The definition of the node, with the following keys:
-- - name: The name of the node.
-- - color: The color of the node when paths are toggled on.
-- - traversable: Whether or not the node is traversable by enemies.
-- - placeable: Whether or not items can be placed on this node.
-- - collidable: Whether or not the player collides with the node.
--   If true, functions as a barrier.
-- - magnet: If the node functions as an attractive or repulsive magnet to navigation.
--   A positive number defines an attractive magnet of the radius supplied.
--   A negative number defines a repulsive magnet of the absolute value of the radius supplied.
-- - spawn: The type of spawnpoint this node is
--   nil, 'player', 'enemy'
--

function register_nav_node(def)
	local navigation = {
		placeable = def.placeable,
		traversable = def.traversable,
		magnet = def.magnet,
		spawn = def.spawn
	}

	minetest.register_node('lexa_nav:' .. def.name, {
		description = def.name,
		drawtype = 'glasslike_framed',
		tiles = {
			'lexa_nav_indicator_frame.png^[multiply:' .. def.color,
			'lexa_nav_indicator.png^[multiply:' .. def.color
		},
		walkable = def.collidable or false,
		paramtype = 'light',
		sunlight_propagates = true,
		drop = '',
		groups = {
			nav_node = 1,
			nav_traversable = def.traversable and 1 or 0,
			nav_visible = 1,
			dig_build = 1
		},
		_navigation = navigation,
		on_place = function(stack, player, target)
			local pos = target.above
			if nav_visible then minetest.set_node(pos, { name = 'lexa_nav:' .. def.name })
			else minetest.set_node(pos, { name = 'lexa_nav:' .. def.name .. '_hidden' }) end
			return stack
		end
	})

	minetest.register_node('lexa_nav:' .. def.name .. '_hidden', {
		description = def.name,
		drawtype = 'airlike',
		walkable = def.collidable or false,
		pointable = false,
		paramtype = 'light',
		sunlight_propagates = true,
		drop = '',
		groups = {
			nav_node = 1,
			nav_traversable = def.traversable and 1 or 0,
			nav_hidden = 1,
			build_dig = 1,
			not_in_creative_inventory = 1
		},
		_navigation = navigation
	})
end

minetest.register_chatcommand('toggle_nav', {
	description = 'Toggle nav node visibility',
	privs = { cheats = true },
	func = function()
		nav_visible = not nav_visible

		if not lexa.match.state then return end
		local voxel = minetest.get_voxel_manip(vector.new(0, 0, 0), lexa.match.state.map_meta.size)
		local data = voxel:get_data()

		local nodes = {}
		for name, def in pairs(minetest.registered_nodes) do
			if def.groups.nav_node and
				((nav_visible and def.groups.nav_hidden) or
				(not nav_visible and def.groups.nav_visible)) then
				local alt = nav_visible and name:gsub('_hidden', '') or name .. '_hidden'
				nodes[minetest.get_content_id(name)] = minetest.get_content_id(alt)
			end
		end

		for i = 1, #data do
			if nodes[data[i]] then data[i] = nodes[data[i]] end
		end

		voxel:set_data(data)
		voxel:write_to_map()
	end
})

--
-- Register the nav nodes.
--

register_nav_node({
	name = 'ground',
	color = '#5CD9FF',
	traversable = true,
	placeable = true
})

register_nav_node({
	name = 'magnet_pos',
	color = '#3DFF7E',
	traversable = true,
	placeable = true,
	magnet = 5
})

register_nav_node({
	name = 'magnet_neg',
	color = '#F56642',
	traversable = true,
	placeable = true,
	magnet = -5
})

register_nav_node({
	name = 'barrier',
	color = '#FF33A7',
	collidable = true
})

register_nav_node({
	name = 'spawn_player',
	color = '#FFED47',
	traversable = true,
	spawn = 'player'
})

register_nav_node({
	name = 'spawn_enemy',
	color = '#C53DFF',
	traversable = true,
	spawn = 'enemy'
})
