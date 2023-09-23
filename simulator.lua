---@class simulator
---@field h0 number
---@field hf number
---@field m number
---@field k number
---@field L number
---@field obstacle_pos vec
---@field g number
---@field angle number
---@field compression number
simulator = {}
simulator.__index = simulator

local debug_draw = true
local launching = false
local init_vel = vec.new(0, 0)
local timepassed = 0
local timeforsimulation = 0
local timestep = 0.15
local hit = false

---return a mock simulator object
---@return simulator
function simulator.mock()
	return simulator.new(100, 400, 1, 10000, 300, vec.new(100, 500), 9.81)
end

---return a new simulator object
---@param h0 number
---@param hf number
---@param m number
---@param k number
---@param L number
---@param obstacle_pos vec
---@param g number
function simulator.new(h0, hf, m, k, L, obstacle_pos, g)
	local ret =
		{ h0 = h0, hf = hf, m = m, k = k, L = L, obstacle_pos = obstacle_pos, g = g, angle = 45, compression = 0.8 }
	setmetatable(ret, simulator)
	return ret
end

function get_launch_vel(g, m, h0, hf, k, compression, angle)
	-- sqrt(2 * (mgh_launch + 1/2 kx^2 - mgh_target) / m)
	local v0 = math.sqrt(2 * ((m * g * h0) + 0.5 * k * (compression * compression) - m * g * 0) / m)
	return vec.new_with_mod(v0, angle)
end

function x_at_given_time(v0, angle, t)
	return v0:mod() * math.cos(math.rad(angle)) * t
end
function y_at_given_time(v0, angle, g, t)
	return v0:mod() * math.sin(math.rad(angle)) * t - 0.5 * g * t * t
end

---@param boundx number
---@param boundy number
---@param pos vec
---@param v0 vec
---@param angle number
---@param g number
---@return number
function time_for_out_of_bounds(boundx, boundy, pos, v0, angle, g)
	local x_vel = v0:mod() * math.cos(math.rad(angle))
	local time_x = (boundx - pos.x) / x_vel
	local y_vel = v0:mod() * math.sin(math.rad(angle))
	local time_y = (y_vel + math.sqrt(math.pow(y_vel, 2) + (2 * g * pos.y))) / g
	return math.min(time_x, time_y)
end

function simulator:reset_simulation()
	init_vel = get_launch_vel(self.g, self.m, self.h0, self.hf, self.k, self.compression, self.angle)
	timeforsimulation = time_for_out_of_bounds(G.width, G.height, vec.new(0, self.h0), init_vel, self.angle, self.g)
	timepassed = 0
	hit = false
end

function simulator:update(dt)
	local change = 0.02
	if love.keyboard.isDown("up") and self.compression < 1 then
		self.compression = self.compression + change
		self:reset_simulation()
	elseif love.keyboard.isDown("down") and self.compression > 0 then
		self.compression = self.compression - change
		self:reset_simulation()
	end

	local angle_change = 1
	if love.keyboard.isDown("right") then
		self.angle = self.angle - angle_change
		self:reset_simulation()
	elseif love.keyboard.isDown("left") then
		self.angle = self.angle + angle_change
		self:reset_simulation()
	end
end
local colors = {
	ball = { 0, 255, 10 },
	ball_hit = { 0, 255, 0 },
	line = { 255, 55, 0 },
}

function simulator:draw()
	-- draw a point in the target pos (L, hf)
	love.graphics.setColor(colors.ball)
	love.graphics.circle("fill", self.L, G.height - self.hf, 3)
	-- draw a line of lenght 70 * spring compression, with the angle.
	love.graphics.setColor(colors.line)
	local line_vec = vec.new_with_mod(140 * self.compression, self.angle)
	love.graphics.line(0, G.height - self.h0, line_vec.x, G.height - self.h0 - line_vec.y)

	if debug_draw then
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(string.format("Compresión %.2f", self.compression), 0, 10)
		love.graphics.print(string.format("Angulo %d", self.angle), 0, 25)
	end

	if launching then
		timepassed = timepassed + timestep
		love.graphics.setColor(colors.ball)
		local projectile_pos = vec.new(
			x_at_given_time(init_vel, self.angle, timepassed),
			G.height - self.h0 - y_at_given_time(init_vel, self.angle, self.g, timepassed)
		)
		love.graphics.circle("fill", projectile_pos.x, projectile_pos.y, 3)
		if timepassed > timeforsimulation then
			timepassed = 0
			hit = false
		end
		-- collision
		local distance = vec.new(self.L, G.height - self.hf) - projectile_pos
		if distance:mod() < 6 then
			hit = true
		end
		if hit then
			love.graphics.setColor(colors.ball_hit)
			love.graphics.circle("fill", self.L, G.height - self.hf, 3)
			if debug_draw then
				love.graphics.print("Hit!", 0, 40)
			end
		end
	end
end

function simulator:wheelmoved(x, y) end

---@param key love.KeyConstant
function simulator:keypressed(key)
	if key == "d" then
		debug_draw = not debug_draw
	end
	if key == "l" then
		if not launching then
			launching = true
			self:reset_simulation()
		else
			launching = false
			timepassed = 0
		end
	end
end
return simulator
