local Vec = require("vec")
---@class simulation
---@field pos vec
---@field v0 vec
---@field angle number
---@field mass number
local simulation = {}
local g = 9.8

---@param initial_pos vec
---@param v0 vec
---@param angle number
---@param mass number
function simulation.new(initial_pos, v0, angle, mass)
	return setmetatable({
		pos = initial_pos,
		v0 = v0,
		angle = angle,
		mass = mass,
	}, { __index = simulation })
end
function x_at_given_time(v0, angle, t)
	return v0:mod() * math.cos(math.rad(angle)) * t
end
function y_at_given_time(v0, angle, t)
	return v0:mod() * math.sin(math.rad(angle)) * t - 0.5 * g * t * t
end

function simulation:gen_points()
	local points = {}
	-- t, will be iterated from 0 to 10 with a step of 0.01
	for t = 0, 20, 0.07 do
		local x = self.pos.x + x_at_given_time(self.v0, self.angle, t)
		local y = G.height - (self.pos.y + y_at_given_time(self.v0, self.angle, t))
		points[#points + 1] = x
		points[#points + 1] = y
		if y > G.height or x > G.width then
			break
		end
	end
	return points
end
local timepassed = 0

function simulation:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(self:gen_points())

	timepassed = timepassed + 0.1
	love.graphics.setColor(0, 255, 10)
	local current_x = self.pos.x + x_at_given_time(self.v0, self.angle, timepassed)
	local current_y = G.height - (self.pos.y + y_at_given_time(self.v0, self.angle, timepassed))
	love.graphics.circle("fill", current_x, current_y, 5)
	if current_y > G.height or current_x > G.width then
		timepassed = 0
	end

	love.graphics.print("initial pos: " .. self.pos.x .. ", " .. self.pos.y, 0, 0)
	love.graphics.print("v0: " .. self.v0.x .. ", " .. self.v0.y, 0, 10)
	love.graphics.print("angle: " .. self.angle, 0, 20)
	love.graphics.print("mass: " .. self.mass, 0, 30)
	love.graphics.print("time passed: " .. timepassed, 0, 40)
	love.graphics.print("x: " .. self.pos.x + x_at_given_time(self.v0, self.angle, timepassed), 0, 60)
	love.graphics.print("y: " .. self.pos.y + y_at_given_time(self.v0, self.angle, timepassed), 0, 70)
end

return simulation.new(vec.new(100, 100), vec.new(50, 20), 60, 1)
