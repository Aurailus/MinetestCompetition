_G['RPQ'] = {
	insert = function(self, v, key_hint)
		assert(v, 'tried to insert a nil value')

		local function heapify(i, i_key)
			if i == 1 then return end
			local parent = math.floor(i / 2)
			local p_i = self.get_priority(self.heap[i])
			local p_p = self.get_priority(self.heap[parent])

			if p_p > p_i then
				local p_key = self.get_key(self.heap[parent])
				self.heap[i], self.heap[parent] = self.heap[parent], self.heap[i]
				self.keys[p_key] = i
				self.keys[i_key] = parent
				heapify(parent, p_key)
			end
		end

		local k = key_hint or self.get_key(v)
		local i = self.size + 1

		self.heap[i] = v
		self.keys[k] = i
		self.size = i

		heapify(i, k)
	end,
	is_empty = function(self)
		return self.size == 0
	end,
	top = function(self)
		return self.heap[1]
	end,
	contains = function(self, k)
		return self.keys[k] ~= nil
	end,
	get = function(self, k)
		return self.heap[self.keys[k]]
	end,
	remove = function(self, k)
		assert(self.size > 0, 'tried to remove from an empty heap')

		local i = k and self.keys[k] or 1

		local function heapify(i, s_key)
			local s_i = i
			local l_i = 2 * i
			local r_i = 2 * i + 1

			local s_p = self.get_priority(self.heap[s_i])

			if l_i <= self.size then
				local l_p = self.get_priority(self.heap[l_i])
				if l_p < s_p then
					s_i = l_i
					s_p = l_p
				end
			end

			if r_i <= self.size then
				local r_p = self.get_priority(self.heap[r_i])
				if r_p < s_p then
					s_i = r_i
					s_p = r_p
				end
			end

			if s_i ~= i then
				local i_key = self.get_key(self.heap[i])
				self.keys[i_key] = s_i
				self.keys[s_key] = i
				self.heap[i], self.heap[s_i] = self.heap[s_i], self.heap[i]
				heapify(s_i, i_key)
			end
		end

		local largest_key = self.get_key(self.heap[self.size])
		self.keys[largest_key] = i
		self.keys[self.get_key(self.heap[i])] = nil
		local v = self.heap[i]
		self.heap[i] = self.heap[self.size]
		self.heap[self.size] = nil
		self.size = self.size - 1

		if self.size > 0 then
			heapify(i, largest_key)
		end

		return v
	end,
	new =	function(get_priority, get_key)
		return setmetatable({
			heap = {},
			keys = {},
			size = 0,
			get_key = get_key,
			get_priority = get_priority
		}, { __index = _G['RPQ'] })
	end
}

-- local rpq = RPQ.new(
-- 	function(v) return v.f end,
-- 	function(v) return tostring(v.pos.x) .. ' ' .. tostring(v.pos.y) .. ' ' .. tostring(v.pos.z) end
-- )

-- rpq:insert({ f = 5, pos = { x = 1, y = 2, z = 8 } })
-- rpq:insert({ f = 4, pos = { x = 1, y = 2, z = 7 } })
-- rpq:insert({ f = 3, pos = { x = 1, y = 2, z = 6 } })
-- rpq:insert({ f = 2, pos = { x = 1, y = 2, z = 5 } })
-- rpq:insert({ f = 1, pos = { x = 1, y = 2, z = 4 } })
-- rpq:insert({ f = 0, pos = { x = 1, y = 2, z = 3 } })

-- rpq:remove('1 2 5')

-- print(dump(rpq))
