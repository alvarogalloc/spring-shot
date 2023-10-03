
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
function generate_simulator()
    -- Generate random values within the specified constraints
    local h0 = math.random(0, 600)
    local hf = math.random(0, 600)
    local m = math.random() * 9.99 + 0.1  -- Random mass between 0.1 and 100
    local k = math.random(10000, 30000)
    local L = math.random(400, 599)  -- Random length between 0 and 599.9
    local obstacle_x = math.random(601, 1000)  -- Assuming x coordinate of obstacle is between 601 and 1000
    local obstacle_y = math.random(601, 1000)  -- Assuming y coordinate of obstacle is between 601 and 1000
    local g = math.random(5, 10)

  return h0, hf, m, k, L, vec.new(obstacle_x, obstacle_y), g
end

return generate_simulator
