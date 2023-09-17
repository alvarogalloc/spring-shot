-- Game resolution

local vec = require("vec")

G = {
	width = 600,
	height = 600,
	fullscreenON = false,
	fullscreenKEY = "f11",
	scaleX = 0,
	scaleY = 0,
  simulation = require("simulation")
}

function love.load()
	-- Remove filter
	love.graphics.setDefaultFilter("nearest", "nearest")
	-- trick to get the real screen size
	love.window.setMode(0, 0, {})
	G.s_width = love.graphics.getWidth()
	G.s_height = love.graphics.getHeight()
	-- Window parameters
	love.window.setTitle("Holaa")
	love.window.setMode(
		G.width,
		G.height,
		{ resizable = true, minwidth = G.width, minheight = G.height, x = love.graphics.getWidth() - G.width }
	)
end

function love.update(dt)
  require("lurker").update()
	-- Scale value
	G.scaleX = love.graphics.getWidth() / G.width
	G.scaleY = love.graphics.getHeight() / G.height
end

function love.draw()
  -- Scale
  love.graphics.scale(G.scaleX, G.scaleY)
  -- Draw
  G.simulation:draw()
end

function love.keypressed(key)
	-- Fullscreen ON/OFF
	if key == G.fullscreenKEY and G.fullscreenON == false then
		G.fullscreenON = true
		love.window.setFullscreen(true)
	elseif key == G.fullscreenKEY and G.fullscreenON == true then
		G.fullscreenON = false
		love.window.setFullscreen(false)
	end
end
