local CATEGORY_PADDING = 32
local CATEGORY_SPACING = 16
local INVENTORY_BUFFER = 32
local DEFAULT_INVENTORY_SIZE = 32
local LABEL_BUFFER = 48

local item_lists = {
	{ 'lexa_conveyor:belt_mono', 'lexa_conveyor:distributor', 'lexa_conveyor:junction' },
	{ 'lexa_factory:drill' },
	{ 'lexa_wall:bottom_cobalt', 'lexa_wall:bottom_titanium', 'lexa_wall:bottom_copper', 'lexa_wall:ladder' },
	{ 'lexa_map:grass_teal', 'lexa_map:stone_mountain', 'lexa_map:log_1_birch', 'lexa_map:leaves_birch', 'lexa_map:fern_teal', 'lexa_map:tall_grass_teal' },
	{ 'air' },
	{ 'air' }
}

minetest.register_craftitem('lexa_hud:item_placeholder', {
	stack_max = 1,
	description = ' ',
	short_description = ' ',
	groups = { not_in_creative_inventory = 1 },
	inventory_image = 'lexa_hud_item_placeholder.png',
	on_place = function(_, player, target)
		local name = player:get_player_name()
		local menu = lexa.hud.state[name].menu_state
		local inv = player:get_inventory()
		local item = inv:get_stack('menu_category_' .. menu.selected._, menu.selected[menu.selected._])
		local def = minetest.registered_items[item:get_name()]
		if def.on_place then
			def.on_place(item, player, target)
		else
			minetest.item_place(item, player, target)
		end
	end,
	on_drop = function(stack)
		return stack
	end
})

local function get_list_background(size)
	local str = '[combine:' .. (size * 19) .. 'x19'
	for i = 0, size - 1 do
		str = str .. ':' .. (i * 19) .. ',0=lexa_hud_item_background.png'
	end
	return str
end

local function get_category_icon(i, active)
	local color = active and '#7aedff' or '#ffffff'
	return 'lexa_hud_category_background.png^([combine:12x12:' .. (-(i - 1) * 12)
		.. ',0=lexa_hud_category_icon.png^[multiply:' .. color .. ')'
end

table.insert(lexa.hud.callbacks.register, function(player)
	local name = player:get_player_name()
	local state = lexa.hud.state[name]
	local elems = state.elements
	state.menu_state = {}
	local menu = state.menu_state

	player:hud_set_flags({ hotbar = false, wielditem = false })
	player:hud_set_hotbar_itemcount(INVENTORY_BUFFER)
	player:hud_set_hotbar_image('lexa_hud_hidden.png')
	player:hud_set_hotbar_selected_image('lexa_hud_hidden.png')

	menu.selected = { _ = 1 }
	menu.ind = 1

	for i = 6, 1, -1 do
		menu.selected[i] = 1
		elems['menu_category_' .. i] = player:hud_add({
			hud_elem_type = 'image',
			position = { x = 1, y = 0.5 },
			text = get_category_icon(i),
			scale = { x = 3, y = 3 },
			alignment = { x = -1, y = -1 },
			offset = { x = -CATEGORY_PADDING, y = -(6 - i) * (36 + CATEGORY_SPACING) + (36 + CATEGORY_SPACING) * 5 / 2 }
		})
	end

	local inv = player:get_inventory()

	inv:set_list('main_backup', inv:get_list('main'))
	inv:set_size('main', INVENTORY_BUFFER)

	local list = {}
	for i = 1, INVENTORY_BUFFER do list[i] = 'lexa_hud:item_placeholder' end
	inv:set_list('main', list)

	for i, list in ipairs(item_lists) do
		inv:set_list('menu_category_' .. i, {})
		inv:set_size('menu_category_' .. i, #list)
		inv:set_list('menu_category_' .. i, list)
	end

	render_categories(player, state, 1, 1)
end)

table.insert(lexa.hud.callbacks.unregister, function(player)
	player:hud_set_flags({ hotbar = true, wielditem = true })
	player:hud_set_hotbar_itemcount(9)
	player:hud_set_hotbar_image('')
	player:hud_set_hotbar_selected_image('')

	local inv = player:get_inventory()

	inv:set_size('main', DEFAULT_INVENTORY_SIZE)
	inv:set_list('main', inv:get_list('main_backup'))
end)

function get_cost_str(cost)
	if not cost.copper and not cost.titanium and not cost.cobalt then
		return ''
	end

	local str = '[!ss] [[!ss][!ss]'

	if cost.copper then
		str = str .. '[!ore_copper][!ss][!ss]' .. cost.copper
	end
	if cost.titanium then
		if cost.copper then str = str .. ' ' end
		str = str .. '[!ore_titanium][!ss][!ss]' .. cost.titanium
	end
	if cost.cobalt then
		if cost.copper or cost.titanium then str = str .. ' ' end
		str = str .. '[!ore_cobalt][!ss][!ss]' .. cost.cobalt
	end

	str = str .. '[!ss][!ss]]'

	return str
end

function render_selected(player, state, inv)
	local menu = state.menu_state
	local elems = state.elements

	local category_ind = menu.selected._
	local item_ind = menu.selected[category_ind]
	local inv_size = inv:get_size('menu_category_' .. category_ind)

	if elems.menu_selected then player:hud_remove(elems.menu_selected) end
	if elems.menu_label then player:hud_remove(elems.menu_label) end

	local item_iden = inv:get_stack('menu_category_' .. category_ind, item_ind):get_name()
	local item_def = minetest.registered_items[item_iden]
	assert(item_def, '[lexa_hud] item definition not found for \'' .. item_iden .. '\'.')
	local item_name = item_def.description or item_def.name
	local item_cost = get_cost_str(item_def._cost or {})

	elems.menu_selected = player:hud_add({
		hud_elem_type = 'image',
		position = { x = 1, y = 0.5 },
		text = 'lexa_hud_item_selected.png',
		scale = { x = 3, y = 3 },
		z_index = 100,
		alignment = { x = 1, y = 1 },
		offset = { x = -80 - 19 * 3 * (inv_size - item_ind + 1),
			y = -48 - (6 - category_ind) * (36 + CATEGORY_SPACING) + (36 + CATEGORY_SPACING) * 5 / 2  }
	})

	elems.menu_label = player:hud_add({
		hud_elem_type = 'image',
		position = { x = 1, y = 0.5 },
		text = lexa.text.render_text(item_name .. item_cost),
		scale = { x = 2, y = 2 },
		alignment = { x = -1, y = -1 },
		offset = { x = -CATEGORY_PADDING - 52,
			y = -(6 - category_ind) * (36 + CATEGORY_SPACING) - LABEL_BUFFER + (36 + CATEGORY_SPACING) * 5 / 2  }
	})
end

function render_categories(player, state, ind, last_ind)
	local inv = player:get_inventory()
	local menu = state.menu_state
	local elems = state.elements
	local ind = menu.selected._

	if elems.menu_list_background then player:hud_remove(elems.menu_list_background) end
	if elems.menu_list_inventory then player:hud_remove(elems.menu_list_inventory) end

	local size = inv:get_size('menu_category_' .. ind)

	player:hud_change(elems['menu_category_' .. last_ind], 'text', get_category_icon(last_ind, false))
	player:hud_change(elems['menu_category_' .. ind], 'text', get_category_icon(ind, true))

	elems.menu_list_background = player:hud_add({
		hud_elem_type = 'image',
		position = { x = 1, y = 0.5 },
		text = get_list_background(size),
		scale = { x = 3, y = 3 },
		alignment = { x = 1, y = 1 },
		offset = { x = -80 - 19 * 3 * size,
			y = -48 - (6 - ind) * (36 + CATEGORY_SPACING) + (36 + CATEGORY_SPACING) * 5 / 2  }
	})

	-- elems.menu_list_inventory = player:hud_add({
	-- 	hud_elem_type = 'inventory',
	-- 	text = 'menu_category_' .. ind,
	-- 	number = size,
	-- 	position = { x = 1, y = 0.5 },
	-- 	offset = { x = -80 + 1 - 19 * 3 * size,
	-- 		y = -48 - (6 - ind) * (36 + CATEGORY_SPACING) + (36 + CATEGORY_SPACING) * 5 / 2  }
	-- })

	render_selected(player, state, inv)
end

minetest.register_globalstep(function(dtime)
	for name, state in pairs(lexa.hud.state) do
		local menu = state.menu_state
		local player = minetest.get_player_by_name(name)

		-- Get the delta ind.

		local ind = player:get_wield_index()
		local left = ind - menu.ind - INVENTORY_BUFFER
		local norm = ind - menu.ind
		local right = ind + INVENTORY_BUFFER - menu.ind

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

		-- Update the menu if the player changed indexes.

		if ind_delta ~= 0 then
			local alt = player:get_player_control().sneak

			if alt then
				local inv = player:get_inventory()
				menu.selected[menu.selected._] = (menu.selected[menu.selected._] + ind_delta - 1) %
				inv:get_size('menu_category_' .. menu.selected._) + 1
				render_selected(player, state, inv)
			else
				local last_ind = menu.selected._
				menu.selected._ = (menu.selected._ + ind_delta - 1) % 6 + 1
				render_categories(player, state, menu.selected._, last_ind)
			end

			menu.ind = ind
		end
	end
end)
