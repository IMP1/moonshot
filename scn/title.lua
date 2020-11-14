local scene_manager = require 'lib.conductor'

local base_scene = require 'scn._base'
local scene = {}
setmetatable(scene, base_scene)
scene.__index = scene

local BACKGROUND_IMAGE = love.graphics.newImage("res/moonscape.png")
local GUI_FONT = love.graphics.newFont("res/MandroidBB.ttf")

local function play()
	local game_scene = require 'scn.bar'
	scene_manager.setScene(game_scene.new())
end

local function settings()
end

local function quit()
	love.event.quit()
end

function scene.new()
	local self = base_scene.new("Title")
	setmetatable(self, scene)

	self.buttons = {
		{
			action = play,
			position = {155, 350},
			radius = 100,
			text = "Play",
			text_position = {155, 350-100-16},
		},
		{
			action = settings,
			position = {0, 0},
			radius = 0,
			text = "Settings",
			text_position = {0, 0},
		},
		{
			action = quit,
			position = {299, 163},
			radius = 30,
			text = "Quit",
			text_position = {299, 163-30-16},
		},
	}
	return self
end

function scene:mouseMoved(mx, my)
	for _, button in pairs(self.buttons) do
		local bx, by = unpack(button.position)
		local dx = bx - mx
		local dy = by - my
		button.hover = (dx * dx + dy * dy < button.radius * button.radius)
	end
end

function scene:keyPressed(key)
	if key == "p" then
		play()
	elseif key == "s" then
        settings()
	elseif key == "x" then
		quit()
	end
end

function scene:mouseReleased(mx, my, key)
	for _, button in pairs(self.buttons) do
		local bx, by = unpack(button.position)
		local dx = bx - mx
		local dy = by - my
		if dx * dx + dy * dy < button.radius * button.radius then
			button.action()
		end
	end
end

function scene:draw()
	local WIDTH = love.graphics.getWidth()
	
	love.graphics.setFont(GUI_FONT)
	love.graphics.draw(BACKGROUND_IMAGE)
	love.graphics.setShader()

	for _, button in pairs(self.buttons) do
		local x, y = unpack(button.position)
		local a = 0.4
		if button.hover then
			a = 1
		end
		love.graphics.setColor(1, 1, 1, a)
		local tx, ty = unpack(button.text_position)
		love.graphics.print(button.text, tx, ty)
		-- love.graphics.circle("line", x, y, button.radius)
	end
end

return scene
