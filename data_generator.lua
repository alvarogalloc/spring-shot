-- right now i have a mock data that is just random data
-- i want to make a function that generates the same but with constraints
-- it generates the call to a simulator constructor with these params
-- h0 : initial height
-- hf : final height
-- m : mass of projectile
-- k : spring stiffness
-- L : lenght of objective
-- obstacle_pos : x y coords of an obstacle
-- g : gravity
math.randomseed(os.time())

local function gen_obstacle_xy(h0, hf, L)
	local x = math.floor(math.random(0.6*L/6, 5.6*L/6))
	local y = math.floor(math.random(h0 + (hf - h0) / 2, math.max(hf, h0)))
	return x,y
end


function generate_simulator()
	-- Generate random values within the specified constraints
	local h0 = math.random(0, 400)
	local hf = math.random(0, 400)
	local m = math.random() * 4.99 + 0.1 -- Random mass between 0.1 and 100
	local k = math.random(10000, 40000)
	local L = math.random(300, 599) -- Random length between 0 and 599.9
	local obstacle_x, obstacle_y = gen_obstacle_xy(h0, hf, L) -- Assuming x coordinate of obstacle is between 601 and 1000
	local g = math.random(3, 7)

	return h0, hf, m, k, L, vec.new(obstacle_x, obstacle_y), g
end

return generate_simulator
