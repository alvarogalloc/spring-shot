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
-- ---@field angle_input any
-- ---@field compression_input any
simulator = {}
simulator.__index = simulator
local UI = require("ui")

local debug_draw = true
local show_help = false
local launching = false
local init_vel = vec.new(0, 0)
local timepassed = 0
local timeforsimulation = 0
local timestep = 0.15
local hit = false
local angle = {"angulo"}
local compresion = {"compresion"}

---return a mock simulator object
---@return simulator
function simulator.mock()
	-- h0: 100
	-- hf: 100
	-- m: 1
	-- k: 40000
	-- L: 400
	-- obstacle_pos (x,y): 100, 500
	-- g: 9
	return simulator.new(0, 10, 1, 30000, 100, vec.new(550, 400), 9.81)
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
		{ h0 = h0, hf = hf, m = m, k = k, L = L, obstacle_pos = obstacle_pos, g = g, angle = 45, compression = 0.98 }
	setmetatable(ret, simulator)
	return ret
end

-- function get_launch_vel(g, m, h0, hf, k, compression, angle)
function get_launch_vel(k, x, m)
	-- sqrt(2 * (mgh_launch + 1/2 kx^2 - mgh_target) / m)
	-- Epe = k x^2/2
	-- Ek = mV^2/2
	-- kx^2 = mV^2
	-- V = sqrt(kx^2/m)
	local v0 = math.sqrt(k * (x * x) / m)
	return v0
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
	init_vel = vec.new_with_mod(get_launch_vel(self.k, self.compression, self.m), self.angle)
	timeforsimulation = time_for_out_of_bounds(G.width, G.height, vec.new(0, self.h0), init_vel, self.angle, self.g)
	timepassed = 0
	hit = false
end

function simulator:update(dt)
	-- print(init_vel)
	local change = 0.01
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

function simulator:draw_launch()
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

function draw_help()
	-- generate a series of text line that show how to use the simulator
	local lines = {
		"Simulador de lanzamiento de proyectiles",
		"Presione L para lanzar",
		"Presione D para mostrar/ocultar el debug",
		"Presione H para mostrar/ocultar esta ayuda",
		"Presione las flechas para cambiar el ángulo y la compresión del resorte",
	}
	local x = 0
	local y = 0
	local line_height = 20
	love.graphics.setColor(255, 255, 255)
	for _, line in ipairs(lines) do
		love.graphics.print(line, x, y, 0, 1.1, 1.1)
		y = y + line_height
	end
end

function simulator:draw_data()
	-- draw the data of the simulator to the right of the screen
	local data = {
		"Datos del simulador",
		string.format("Altura inicial: %.2f", self.h0),
		string.format("Altura final: %.2f", self.hf),
		string.format("Masa: %.2f", self.m),
		string.format("Constante del resorte: %.2f", self.k),
		string.format("Distancia al objetivo: %.2f", self.L),
		string.format("Posición del obstáculo: (%.2f, %.2f)", self.obstacle_pos.x, self.obstacle_pos.y),
		string.format("Gravedad: %.2f", self.g),
	}
	local x = 0
	local y = 0
	local line_height = 20
	love.graphics.setColor(255, 255, 255)
	for _, line in ipairs(data) do
		love.graphics.print(line, G.width - 300, y, 0, 1.1, 1.1)
		y = y + line_height
	end
end

function simulator:draw_debug()
	-- draw the debug data of the simulator to the left of the screen
	-- include angle and compression, and the current position of the projectile
	local projectile_pos = vec.new(
		x_at_given_time(init_vel, self.angle, timepassed),
		G.height - self.h0 - y_at_given_time(init_vel, self.angle, self.g, timepassed)
	)

	local data = {
		"Datos de debug",
		string.format("Tiempo de simulación: %.2f", timeforsimulation),
		string.format("Tiempo transcurrido: %.2f", timepassed),
		string.format("Velocidad inicial: (%.2f, %.2f)", init_vel.x, init_vel.y),
		string.format("Angulo: %.2f", self.angle),
		string.format("Compresión: %.2f", self.compression),
		string.format("Posición del proyectil: (%.2f, %.2f)", projectile_pos.x, projectile_pos.y),
	}
	local x = 0
	local y = 0
	local line_height = 20
	love.graphics.setColor(255, 255, 255)
	for _, line in ipairs(data) do
		love.graphics.print(line, 0, y, 0, 1.1, 1.1)
		y = y + line_height
	end
end

function simulator:draw()
	if show_help then
		draw_help()
		return
	end

	-- draw a point in the target pos (L, hf)
	love.graphics.setColor(colors.ball)
	love.graphics.circle("fill", self.L, G.height - self.hf, 3)
	-- draw a line of lenght 70 * spring compression, with the angle.
	love.graphics.setColor(colors.line)
	local line_vec = vec.new_with_mod(140 * self.compression, self.angle)
	love.graphics.line(0, G.height - self.h0, line_vec.x, G.height - self.h0 - line_vec.y)
	-- draw obstacle
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", self.obstacle_pos.x, G.height - self.obstacle_pos.y, 3)

	self:draw_data()

	if debug_draw then
		self:draw_debug()
	end

	if launching then
		self:draw_launch()
	end
	function draw_ui()
		UI.draw{ x = 30, y = 30, UI.inputbox{angle} }
	end
	-- draw_ui()
end

function simulator:wheelmoved(x, y) end

---@param key love.KeyConstant
function simulator:keypressed(key)
	if key == "r" then
		local h0, hf, m, k, L, obstacle, g = generate_simulator()
		self.h0 = h0
		self.hf = hf
		self.m = m
		self.k = k
		self.L = L
		self.obstacle_pos = obstacle
		self.g = g
		self:reset_simulation()
	end
	if key == "h" then
		show_help = not show_help
	end
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
