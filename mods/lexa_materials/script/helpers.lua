function lexa.materials.place(cost)
	return function(stack, player, target)
		if not lexa.match.use_materials(cost) then return end
		minetest.item_place_node(stack, player,	target)
	end
end

function lexa.materials.dig(cost)
	return function(pos, node, player)
		local last = table.copy(lexa.match.state.materials)
		for type, val in pairs(cost) do
			last[type] = last[type] + math.floor(val / 2)
		end
		lexa.match.set_materials(last)
		minetest.node_dig(pos, node, player)
	end
end
