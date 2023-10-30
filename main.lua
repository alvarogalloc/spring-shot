---@diagnostic disable: duplicate-set-field
-- Game resolution

local vec = require("vec")
local suit = require("suit")
require("data_generator")

G = {
	width = 700,
	height = 700,
	fullscreenON = false,
	fullscreenKEY = "f11",
	scaleX = 0,
	scaleY = 0,
	-- simulation = require("simulation").new(vec.new(0, 0), vec.new_with_mod(42.426, 64), 64, 1, target.new(vec.new(500, G.width - 50), 2))
	simulation = require("simulator").mock(),
}

function love.load()
	-- Remove filter
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- trick to get the real screen size
	love.window.setMode(0, 0, {})
	G.s_width = love.graphics.getWidth()
	G.s_height = love.graphics.getHeight()
	-- Window parameters
	love.window.setTitle("Simulador Tiro Parabolico (Hecho por: Alvaro Gallo)")
	love.window.setMode(G.width, G.height, { resizable = true, minwidth = G.width, minheight = G.height })
end

function love.update(dt)
	-- uncomment line to live reload
	if arg[2] == "debug" then
		require("lurker").update()
	end
	-- Scale value
	G.scaleX = love.graphics.getWidth() / G.width
	G.scaleY = love.graphics.getHeight() / G.height
	G.simulation:update(dt)
end

function love.draw()
	-- make a gray grid background
	love.graphics.setColor(0.2, 0.2, 0.2)
	for i = 0, G.width, 50 do
		love.graphics.setLineWidth(1)
		love.graphics.line(i, 0, i, G.height)
		love.graphics.line(0, i, G.width, i)
	end
	-- Scale
	love.graphics.scale(G.scaleX, G.scaleY)
	-- Draw
	G.simulation:draw()
	suit.draw()
end

function love.mousemoved(x, y, dx, dy) end

function love.mousepressed(x, y, button, isTouch) end

function love.mousereleased(x, y, button, isTouch) end

function love.keypressed(key, scancode, isrepeat)
	-- Fullscreen ON/OFF
	if key == G.fullscreenKEY and G.fullscreenON == false then
		G.fullscreenON = true
		love.window.setFullscreen(true)
	elseif key == G.fullscreenKEY and G.fullscreenON == true then
		G.fullscreenON = false
		love.window.setFullscreen(false)
	end
	G.simulation:keypressed(key)
	suit.keypressed(key)
end

function love.wheelmoved(x, y)
	G.simulation:wheelmoved(x, y)
end

function love.keyreleased(key) end

function love.textinput(text)
	suit.textinput(text)
end

function love.textedited(text, start, length)
	-- for IME input
	suit.textedited(text, start, length)
end
