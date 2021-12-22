lexa.match = {}

--
-- The main status object, contains information relating to the current match.
-- If nil, no match has been started. Can be initialized by calling lexa.match.start_match().
--
-- # Properties
--
-- ## def
--
-- A definition table containing the match's parameters.
--
-- map: string, The map name, default, default 'mountain'.
-- waves: number, The number of waves in the match, default 10.
-- wait: number, The time between waves, default 180.
-- enemies_initial: number, The number of enemies in each wave, default 10.
-- enemies_mult: number, The number of additional enemies to add each wave, default 5.
-- materials: table, A materials table (defined below) of initial materials, default nil.
--
-- ## map_meta
--
-- size: vector, the dimensions of the map
-- spawn: vector, the position of the player spawn
--
-- ## status
--
-- Information about the current wave time, enemies, and count.
--
-- wave: number, The current wave number.
-- wave_max: number, The maximum number of waves.
-- wait: number, The time until the enemies spawn, if 0 they have spawned.
-- wait_max: number, The full timer value.
-- enemies: number, The number of enemies remaining.
-- enemies_max: number, The initial number of enemies spawned.
--
-- ## materials
--
-- A key-value table of materials and their counts.
-- If a count is nil, it should be treated as 0 and not displayed on the hud.
--
-- ## Graph
--
-- A graph representation of the map, for enemy pathfinding.
--

lexa.match.state = nil

-- The root directory for map files.
local map_root = minetest.get_modpath('lexa_map') .. '/maps/'

--
-- Starts a match based on the provided definitions.
--
-- # Definition keys:
--
-- waves: The number of waves in the match, default 10.
-- wait: The time between waves, default 180.
-- enemies_initial: The number of enemies in each wave, default 10.
-- enemies_mult: The number of additional enemies to add each wave, default 5.
-- materials: A materials object of initial materials, default nil.
--

lexa.match.start_match = function(def)
	minetest.chat_send_all(' ')
	minetest.chat_send_all('Starting match...')
	minetest.chat_send_all(' ')

	def.map = def.map or 'mountain'
	local map_meta = dofile(map_root .. def.map .. '.meta.lua')

	lexa.nav.load_area(vector.new(0, 0, 0), map_meta.size, function()
		for _, player in ipairs(minetest.get_connected_players()) do player:set_pos(map_meta.spawn) end

		-- minetest.place_schematic(vector.new(0, 0, 0), map_root .. def.map .. '.mts')
		lexa.match.state = {
			def = def,
			map_meta = map_meta,
			status = {
				wave = 1,
				wave_max = def.waves or 180,
				wait = def.wait or 180,
				wait_max = def.wait or 180,
				enemies = 0,
				enemies_max = 0
			},
			materials = def.materials or {},
			graph = lexa.nav.build_graph(map_meta.spawn)
		}

		lexa.hud.update_materials(lexa.match.state.materials)

		minetest.chat_send_all(' ')
		minetest.chat_send_all('Match started, have fun!')
		minetest.chat_send_all(' ')
		minetest.after(5, function() minetest.chat_send_all(' ') end)
	end)
end

minetest.register_on_joinplayer(function()
	if lexa.match.state then return end
	lexa.match.start_match({
		waves = 10,
		wait = 180,
		enemies_initial = 10,
		enemies_mult = 5,
		materials = {
			copper = 25
		}
	})
end)

function lexa.match.respawn(name)
	if not lexa.match.state then
		minetest.chat_send_player(name, 'Please run /start_match first!')
		return
	end
	minetest.get_player_by_name(name):set_pos(lexa.match.state.map_meta.spawn)
end

minetest.register_chatcommand('respawn', {
	description = 'Returns the player to the spawn.',
	func = function(name)
		lexa.match.respawn(name)
	end
})

function lexa.match.set_materials(materials)
	if not lexa.match.state then
		minetest.chat_send_player(name, 'Please run /start_match first!')
		return
	end

	local last = lexa.match.state.materials
	lexa.match.state.materials = materials

	if last.copper ~= materials.copper  or last.titanium ~= materials.titanium or last.cobalt ~= materials.cobalt then
		lexa.hud.update_materials(materials)
	end
end

function lexa.match.use_materials(use)
	if not lexa.match.state then
		minetest.chat_send_player(name, 'Please run /start_match first!')
		return
	end

	local new = table.copy(lexa.match.state.materials)
	if use.copper then new.copper = new.copper - use.copper end
	if use.titanium then new.titanium = new.titanium - use.titanium end
	if use.cobalt then new.cobalt = new.cobalt - use.cobalt end

	if (new.copper and new.copper < 0) or (new.titanium and new.titanium < 0)
		or (new.cobalt and new.cobalt < 0) then return false end

	lexa.match.set_materials(new)
	return true
end

minetest.register_globalstep(function(delta)
	if not lexa.match.state then return end
	lexa.match.state.status.wait = math.max(0, lexa.match.state.status.wait - delta)
	lexa.hud.refresh_bar()

	if lexa.match.state.status.wait == 0 and lexa.match.state.status.enemies ~= 0 then
		lexa.match.spawn_wave()
	end
end)

function lexa.match.spawn_wave()
	for _, spawn in lexa.match.status.graph.enemy_spawns do
		local path = lexa.nav.find_path(lexa.match.state.graph, spawn, lexa.match.state.map_meta.spawn)

		for i = 0, 10 do
			minetest.after(i, function()
				local ent = minetest.add_entity(spawn, 'lexa_enemy:spider', '')
				ent.path = path
			end)
		end
	end
end
