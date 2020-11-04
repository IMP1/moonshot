local base_scene = require 'scn._base'

local scene = {}
setmetatable(scene, base_scene)
scene.__index = scene

local BACKGROUND_IMAGE = love.graphics.newImage("res/bar_internal.png")

function scene.new()
	local self = base_scene.new("Bar")
	setmetatable(self, scene)

	self.bar_position = 10 -- from 0 to 400?

	return self
end

function scene:draw()
    love.graphics.draw(BACKGROUND_IMAGE, -self.bar_position, 0)
end

return scene
