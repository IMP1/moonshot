local scene_manager = require 'lib.conductor'

local base_scene = require 'scn._base'
local scene = {}
setmetatable(scene, base_scene)
scene.__index = scene

local BACKGROUND_IMAGE = love.graphics.newImage("res/moonscape.png")

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
		},
		{
			action = settings,
			position = {0, 0},
			radius = 0,
		},
		{
			action = quit,
			position = {299, 163},
			radius = 30,
		},
	}
	return self
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
	love.graphics.draw(BACKGROUND_IMAGE)

	-- DEBUG BUTTON DRAWING
	love.graphics.setColor(1, 0, 0)
	for _, button in pairs(self.buttons) do
		local x, y = unpack(button.position)
		love.graphics.circle("line", x, y, button.radius)
	end
end

return scene
