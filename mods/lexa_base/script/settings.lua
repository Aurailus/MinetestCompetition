--
-- Hacks to enforce settings to make the game work.
--

--
-- If the user has a user-level time_speed then we will create a loop to set the time to noon every 5 seconds.
-- This is stupid, but so is minetest so what are you going to do?
--

local manually_update_time = tonumber((minetest.settings:get('time_speed') or 72)) > 0

function update_time()
	minetest.set_timeofday(0.5)
	if manually_update_time then
		minetest.after(5, update_time)
	end
end

update_time()
