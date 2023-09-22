local vec = require("vec")
local target = require("target")
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
---@param mytarget target
function simulation.new(initial_pos, v0, angle, mass, mytarget )
	return setmetatable({
		pos = initial_pos,
		v0 = v0,
		angle = angle,
		mass = mass,
		mytarget = mytarget,
	}, { __index = simulation })
end
function x_at_given_time(v0, angle, t)
	return v0:mod() * math.cos(math.rad(angle)) * t
end
function y_at_given_time(v0, angle, t)
	return v0:mod() * math.sin(math.rad(angle)) * t - 0.5 * g * t * t
end

---@param boundx number
---@param boundy number
---@param pos vec
---@param v0 vec
---@param angle number
---@return number
function time_for_out_of_bounds(boundx, boundy, pos, v0, angle)
	local x_vel = v0:mod() * math.cos(math.rad(angle))
	local time_x = (boundx - pos.x) / x_vel
	local y_vel = v0:mod() * math.sin(math.rad(angle))
	local time_y = (y_vel + math.sqrt(math.pow(y_vel, 2) + (2 * g * pos.y))) / g
	return math.min(time_x, time_y)
end

function simulation:gen_points()
	local points = {}
	-- t, will be iterated from 0 to 10 with a step of 0.01
	for t = 0, time_for_out_of_bounds(G.width, G.height, self.pos, self.v0, self.angle), 0.1 do
		local x = self.pos.x + x_at_given_time(self.v0, self.angle, t)
		local y = G.height - (self.pos.y + y_at_given_time(self.v0, self.angle, t))
		points[#points + 1] = x
		points[#points + 1] = y
		if y > G.height or x > G.width then
			break
		end
	end
	-- blank line if no more than 2 points produced
	-- this behaviour is made by the trajectorie being so little
	if #points < 4 then
		for i = 0, 4, 1 do
			points[i] = -i
		end
	end
	return points
end
local timepassed = 0
local timestep = 1
local colors = {
	ball = { 0, 255, 10 },
	line = { 255, 55, 0 },
}

function simulation:draw()
	love.graphics.setColor(colors.line)
	love.graphics.setLineWidth(3)
	love.graphics.line(self:gen_points())

	love.graphics.setColor(colors.ball)
	local current_x = self.pos.x + x_at_given_time(self.v0, self.angle, timepassed)
	local current_y = G.height - (self.pos.y + y_at_given_time(self.v0, self.angle, timepassed))
	love.graphics.circle("fill", current_x, current_y, 5)
  love.graphics.print("initial height: " .. self.pos.y, 0, 0)
	love.graphics.print("v0: " .. self.v0:mod(), 0, 10)
	love.graphics.print("angle: " .. self.angle, 0, 20)
	love.graphics.print("mass: " .. self.mass, 0, 30)
	love.graphics.print("time passed: " .. timepassed, 0, 40)
	love.graphics.print(
		"x: " .. string.format("%.2f", self.pos.x + x_at_given_time(self.v0, self.angle, timepassed)),
		0,
		60
	)
	love.graphics.print(
		"y: " .. string.format("%.2f", self.pos.y + y_at_given_time(self.v0, self.angle, timepassed)),
		0,
		70
	)
end

local lastmouse_pos = vec.new(love.mouse.getPosition())

---@param dt number
function simulation:update(dt)
	local move_timestep = 5 * timestep * dt
	if love.keyboard.isDown("left") then
		if timepassed - move_timestep > 0 then
			timepassed = timepassed - move_timestep
		end
	elseif love.keyboard.isDown("right") then
		local time_for_out_of_bounds = time_for_out_of_bounds(G.width, G.height, self.pos, self.v0, self.angle)
		if timepassed + move_timestep < time_for_out_of_bounds then
			timepassed = timepassed + move_timestep
		end
	else
		timepassed = timepassed + timestep * dt
		local current_x = self.pos.x + x_at_given_time(self.v0, self.angle, timepassed)
		local current_y = G.height - (self.pos.y + y_at_given_time(self.v0, self.angle, timepassed))
		if current_y > G.height or current_x > G.width then
			timepassed = 0
		end
	end

	local mouse_pos = vec.new(love.mouse.getX(), G.height - love.mouse.getY())
	if love.mouse.isDown(1) then
		self.pos.y = mouse_pos.y
	end
end

function simulation:wheelmoved(x, y)
	local new_angle = self.angle + x * 0.5
	if new_angle > -90 and new_angle < 90 then
		self.angle = new_angle
	end
end

function simulation:keypressed(key) end

return simulation.new(vec.new(0, 0), vec.new(50, 70), 40, 1, target.new(vec.new(10, 10), 20))
