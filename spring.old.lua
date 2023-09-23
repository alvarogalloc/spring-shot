---@class spring
---@field x number
---@field k number
spring = {}
spring.__index = spring

---comment
---@param x number
---@param k number
---@return spring
function spring.new(x, k)
	local s = { x = x or 0, k = k or 0 }
	setmetatable(s, spring)
	return s
end

---get the velocity with the spring conditions
---@param sim simulation
---@return vec
function spring:launch_vel(sim)
	-- sqrt(2 * (mgh_launch + 1/2 kx^2 - mgh_target) / m)
	local g = 9.81
	local v0 =
		math.sqrt(2 * ((sim.mass * g * sim.pos.y) + 0.5 * self.k * (self.x * self.x) - sim.mass * g * 0) / sim.mass)
	print(v0)
		return vec.new_with_mod(v0, sim.angle)
end


return spring