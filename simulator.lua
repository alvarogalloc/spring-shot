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
local suit = require("suit")

local debug_draw_checkbox = { text = "Debug", checked = false }
local input_angulo = { text = "45" }
local input_compresion = { text = "89" }
local is_showing_help = false
local is_launching = false
local init_vel = vec.new(0, 0)
local timepassed = 0
local timeforsimulation = 0
local time_step = 0.15
local is_hit_target = false
local colors = {
	ball = { 0, 255, 10 },
	ball_hit = { 255, 0, 0 },
	line = { 255, 55, 0 },
}
local ball_radius = 3
local target_radius = 10
local obstacle_radius = 15

local function benchmark(name, func)
	local start = os.clock()
	func()
	print(string.format("func %s takes %.3f", name, os.clock() - start))
end

---return a mock simulator object
---@return simulator
function simulator.mock()
	return simulator.new(1, 9.81, 10000, 240, 120, 400, vec.new(90, 151))
end

---return a new simulator object
---@param m number
---@param g number
---@param k number
---@param hf number
---@param h0 number
---@param L number
---@param obstacle_pos vec
function simulator.new(m, g, k, hf, h0, L, obstacle_pos)
	local ret =
		{ h0 = h0, hf = hf, m = m, k = k, L = L, obstacle_pos = obstacle_pos, g = g, angle = 45, compression = 0.98 }
	setmetatable(ret, simulator)
	return ret
end

-- function get_launch_vel(g, m, h0, hf, k, compression, angle)
local function get_launch_vel(k, x, m)
	-- sqrt(2 * (mgh_launch + 1/2 kx^2 - mgh_target) / m)
	-- Epe = k x^2/2
	-- Ek = mV^2/2
	-- kx^2 = mV^2
	-- V = sqrt(kx^2/m)
	local v0 = math.sqrt(k * (x * x) / m)
	return v0
end

local function x_at_t(v0, angle, t)
	return v0:mod() * math.cos(math.rad(angle)) * t
end
local function y_at_t(v0, angle, g, t)
	return v0:mod() * math.sin(math.rad(angle)) * t - 0.5 * g * t * t
end

---@param boundx number
---@param boundy number
---@param pos vec
---@param v0 vec
---@param angle number
---@param g number
---@return number
local function time_for_out_of_bounds(boundx, boundy, pos, v0, angle, g)
	local x_vel = v0:mod() * math.cos(math.rad(angle))
	local time_x = (boundx - pos.x) / x_vel
	local y_vel = v0:mod() * math.sin(math.rad(angle))
	local time_y = (y_vel + math.sqrt(math.pow(y_vel, 2) + (2 * g * pos.y))) / g
	return math.min(time_x, time_y)
end

function simulator:time_to_target()
	return ""
end

function simulator:reset_simulation()
	init_vel = vec.new_with_mod(get_launch_vel(self.k, self.compression, self.m), self.angle)
	timeforsimulation = time_for_out_of_bounds(G.width, G.height, vec.new(0, self.h0), init_vel, self.angle, self.g)
	timepassed = 0
	is_hit_target = false
	is_launching = false
end
function simulator:init_launch()
	self:reset_simulation()
	-- as reset_simulation stops the simulation, in this special case rerun it
	is_launching = true
end

function simulator:update(dt)
	function make_ui()
		suit.layout:reset(0, 0)
		suit.Label("Debug:", { align = "left" }, suit.layout:row(50, 20))
		suit.Checkbox(debug_draw_checkbox, suit.layout:col(20, 20))
		-- suit.layout:row(40, 40)
		suit.layout:left(40, 20)
		-- separation
		suit.Label("Angulo:", { align = "left" }, suit.layout:row(150, 20))
		suit.Input(input_angulo, suit.layout:row(150, 20))
		suit.Label("Compresion (%):", { align = "left" }, suit.layout:row(150, 20))
		suit.Input(input_compresion, suit.layout:row(150, 20))
		suit.layout:row(200, 10)

		if suit.Button("Reset", suit.layout:row(70, 30)).hit then
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
		suit.layout:col(10, 30)
		if suit.Button("Launch", suit.layout:col(70, 30)).hit then
			self:init_launch()
		end
	end
	function update_ui()
		if input_angulo.text == "" or input_compresion.text == "" or input_angulo.text == "-" then
			return
		end
		if tonumber(input_compresion.text) == nil or tonumber(input_angulo.text) == nil then
			input_compresion.text = tostring(self.compression)
			input_angulo.text = tostring(self.angle)
		end
		if self.compression ~= tonumber(input_compresion.text) / 100 or self.angle ~= tonumber(input_angulo.text) then
			self.compression = tonumber(input_compresion.text) / 100 or self.compression
			self.angle = tonumber(input_angulo.text) or self.angle
			local was_launching = is_launching
			self:reset_simulation()
			if was_launching then
				is_launching = true
			end
		end
	end
	update_ui()
	make_ui()
end

function simulator:draw_launch()
	timepassed = timepassed + time_step

	-- dibujar proyectil
	love.graphics.setColor(colors.ball)
	local projectile_pos = vec.new(
		x_at_t(init_vel, self.angle, timepassed),
		G.height - self.h0 - y_at_t(init_vel, self.angle, self.g, timepassed)
	)
	love.graphics.circle("fill", projectile_pos.x, projectile_pos.y, ball_radius)

	-- if reached the edge in x or y of the window
	if timepassed > timeforsimulation then
		timepassed = 0
		is_hit_target = false
	end

	-- collision
	local distance = vec.new(self.L, G.height - self.hf) - projectile_pos
	local distance_to_obstacle = vec.new(projectile_pos.x, G.height - projectile_pos.y) - self.obstacle_pos
	-- this assumes that the radius of the target is the same as the ball
	-- print(distance_to_obstacle:mod())
	if distance_to_obstacle:mod() < ball_radius + obstacle_radius then
		self:reset_simulation()
	end
	if distance:mod() < ball_radius + target_radius then
		is_hit_target = true
	end
	if is_hit_target then
		love.graphics.setColor(colors.ball_hit)
		-- draw target with another color
		love.graphics.circle("fill", self.L, G.height - self.hf, target_radius)
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
		string.format("Masa balón: %.2f", self.m),
		string.format("Gravedad: %.2f", self.g),
		string.format("Constante del resorte: %.2f", self.k),
		string.format("Altura final: %.2f", self.hf),
		string.format("Altura inicial: %.2f", self.h0),
		string.format("Distancia horizontal: %.2f", self.L),
		string.format("Posición del obstáculo: (x: %.2f,y: %.2f)", self.obstacle_pos.x, self.obstacle_pos.y),
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
		x_at_t(init_vel, self.angle, timepassed),
		G.height - self.h0 - y_at_t(init_vel, self.angle, self.g, timepassed)
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
		love.graphics.print(line, 0, y + 300, 0, 1.1, 1.1)
		y = y + line_height
	end
end

function simulator:draw()
	if is_showing_help then
		draw_help()
		return
	end

	-- draw a point in the target pos (L, hf)
	love.graphics.setColor(colors.ball)
	love.graphics.circle("fill", self.L, G.height - self.hf, target_radius)
	-- draw a line of lenght 70 * spring compression, with the angle.
	love.graphics.setColor(colors.line)
	local line_vec = vec.new_with_mod(140 * self.compression, self.angle)
	love.graphics.line(0, G.height - self.h0, line_vec.x, G.height - self.h0 - line_vec.y)
	-- draw obstacle
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", self.obstacle_pos.x, G.height - self.obstacle_pos.y, obstacle_radius)

	self:draw_data()

	if debug_draw_checkbox.checked then
		self:draw_debug()
	end

	if is_launching then
		self:draw_launch()
	end
end

function simulator:wheelmoved(x, y) end
function simulator:keypressed(key) end
return simulator
