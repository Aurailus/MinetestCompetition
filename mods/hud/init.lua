local CATEGORY_PADDING = 32
local CATEGORY_SPACING = 16
local INVENTORY_BUFFER = 16

local hud_status = {}

local item_lists = {
	{ 'machine:conveyor_mono', 'terrain:grass_teal', 'terrain:stone_mountain' },
	{ 'machine:mining_drill' },
	{ 'wall:bottom_cobalt', 'wall:bottom_titanium', 'wall:bottom_copper', 'wall:ladder' },
	{ 'wall:bottom_copper', 'terrain:grass_teal' },
	{ 'wall:bottom_titanium', 'terrain:grass_teal' },
	{ 'wall:bottom_cobalt' }
}

minetest.register_craftitem('hud:item_placeholder', {
	stack_max = 1,
	description = ' ',
	short_description = ' ',
	inventory_image = 'hud_item_placeholder.png',
	on_place = function(_, player, target)
		local name = player:get_player_name()
		local hud = hud_status[name]
		local inv = player:get_inventory()
		local item = inv:get_stack('game_category_' .. hud.selected._, hud.selected[hud.selected._])
		local def = minetest.registered_items[item:get_name()]
		if def.on_place then
			def.on_place(item, player, target)
		else
			minetest.item_place(item, player, target)
		end
	end
})

local hud_backgrounds = {
	'[combine:20x20:0,0=hud_item_background.png',
	'[combine:40x20:0,0=hud_item_background.png:19,0=hud_item_background.png',
	'[combine:60x20:0,0=hud_item_background.png:19,0=hud_item_background.png:38,0=hud_item_background.png',
	'[combine:80x20:0,0=hud_item_background.png:19,0=hud_item_background.png:38,0=hud_item_background.png:57,0=hud_item_background.png',
	'[combine:100x20:0,0=hud_item_background.png:19,0=hud_item_background.png:38,0=hud_item_background.png:57,0=hud_item_background.png:76,=hud_item_background.png',
}

local function get_category_icon(i, active)
	local color = active and '#7aedff' or '#ffffff'
	return 'hud_category_background.png^([combine:12x12:' .. (-(i - 1) * 12)
		.. ',0=hud_category_icon.png^[multiply:' .. color .. ')'
end

minetest.register_on_joinplayer(function(player)

	local name = player:get_player_name()

	for i = 1, 10 do
		minetest.chat_send_player(name, ' ')
	end

	player:hud_set_flags({
		hotbar = false,
		heathbar = false,
		crosshair = true,
		wielditem = false,
		minimap = false,
		minimap_radar = false
	})

	player:hud_set_hotbar_itemcount(INVENTORY_BUFFER)
	player:hud_set_hotbar_image('hud_hidden.png')
	player:hud_set_hotbar_selected_image('hud_hidden.png')

	hud_status[name] = { item_slots = {}, categories = {}, cursor = nil, selected = { _ = 1 }, ind = 4 }

	for i = 6, 1, -1 do
		hud_status[name].selected[i] = 1
		hud_status[name].categories[i] = player:hud_add({
			hud_elem_type = 'image',
			position = { x = 1, y = 1 },
			text = get_category_icon(i),
			scale = { x = 3, y = 3 },
			alignment = { x = -1, y = -1 },
			offset = { x = -CATEGORY_PADDING, y = -(6 - i) * (36 + CATEGORY_SPACING) - CATEGORY_PADDING }
		})
	end

	local inv = player:get_inventory()

	inv:set_size('main', INVENTORY_BUFFER)
	local list = {}
	for i = 1, INVENTORY_BUFFER do list[i] = 'hud:item_placeholder' end
	inv:set_list('main', list)

	for i, list in ipairs(item_lists) do
		inv:set_list('game_category_' .. i, {})
		inv:set_size('game_category_' .. i, #list)
		inv:set_list('game_category_' .. i, list)
	end
end)

function render_selected(player, hud, inv)
	local category_ind = hud.selected._
	local item_ind = hud.selected[category_ind]
	local inv_size = inv:get_size('game_category_' .. category_ind)

	if hud.cursor ~= nil then
		player:hud_remove(hud.cursor)
	end

	-- local item = inv:get_stack('game_category_' .. category_ind, item_ind):get_name()
	-- local list = {}
	-- for i = 1, INVENTORY_BUFFER do list[i] = item end
	-- inv:set_list('main', list)

	hud.cursor = player:hud_add({
		hud_elem_type = 'image',
		position = { x = 1, y = 1 },
		text = 'hud_item_selected.png',
		scale = { x = 3, y = 3 },
		alignment = { x = 1, y = 1 },
		offset = { x = -80 - 19 * 3 * (inv_size - item_ind + 1), y = -78 - (6 - category_ind) * (36 + CATEGORY_SPACING) }
	})
end

function render_categories(player, hud, ind, last_ind)
	local inv = player:get_inventory()
	local ind = hud.selected._

	for _, elem in ipairs(hud.item_slots) do player:hud_remove(elem) end
	hud.last_ind = ind
	hud.item_slots = {}

	local size = inv:get_size('game_category_' .. ind)

	player:hud_change(hud.categories[last_ind], 'text', get_category_icon(last_ind, false))
	player:hud_change(hud.categories[ind], 'text', get_category_icon(ind, true))

	table.insert(hud.item_slots, player:hud_add({
		hud_elem_type = 'image',
		position = { x = 1, y = 1 },
		text = hud_backgrounds[size],
		scale = { x = 3, y = 3 },
		alignment = { x = 1, y = 1 },
		offset = { x = -80 - 19 * 3 * size, y = -78 - (6 - ind) * (36 + CATEGORY_SPACING) }
	}))

	table.insert(hud.item_slots, player:hud_add({
		hud_elem_type = 'inventory',
		text = 'game_category_' .. ind,
		number = size,
		position = { x = 1, y = 1 },
		offset = { x = -80 + 1 - 19 * 3 * size, y = -78 - (6 - ind) * (36 + CATEGORY_SPACING) }
	}))

	render_selected(player, hud, inv)
end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local hud = hud_status[name]

		local ind = player:get_wield_index()
		local left = ind - hud.ind - INVENTORY_BUFFER
		local norm = ind - hud.ind
		local right = ind + INVENTORY_BUFFER - hud.ind

		local ind_delta = 0
		if math.abs(left) < math.abs(right) then
			if math.abs(norm) < math.abs(left) then
				ind_delta = norm
			else
				ind_delta = left
			end
		elseif math.abs(norm) < math.abs(right) then
			ind_delta = norm
		else
			ind_delta = right
		end

		if ind_delta ~= 0 then
			print(hud.ind .. ', ' .. ind .. ', ' .. left .. ', ' .. right .. ', ' .. ind_delta)
			local alt = player:get_player_control().sneak

			if alt then
				local inv = player:get_inventory()
				hud.selected[hud.selected._] = (hud.selected[hud.selected._] + ind_delta - 1) %
				inv:get_size('game_category_' .. hud.selected._) + 1
				render_selected(player, hud, inv)
			else
				local last_ind = hud.selected._
				hud.selected._ = (hud.selected._ + ind_delta - 1) % 6 + 1
				render_categories(player, hud, hud.selected._, last_ind)
			end

			hud.ind = ind
		end
	end
end)
