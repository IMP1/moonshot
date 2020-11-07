local scene_manager = require 'lib.conductor'
local base_scene = require 'scn._base'

local scene = {}
setmetatable(scene, base_scene)
scene.__index = scene

local BACKGROUND_IMAGE = love.graphics.newImage("res/bar_internal.png")
local BLUR_SHADER_CODE = love.filesystem.read("res/blur_shader.glsl")
local blur_shader = love.graphics.newShader(BLUR_SHADER_CODE)

function scene.new()
	local self = base_scene.new("Bar")
	setmetatable(self, scene)

	self.bar_position = 10 -- from 0 to 400?
    self.mixing_drinks = false
    self.conversation = nil
    self.customers = {}
    self.triggers = {}
    self.timer = 0

    table.insert(self.customers, {
        sprite = love.graphics.newImage("res/test_1.png"),
        position = {100, 130},
    })

	return self
end

function scene:update(dt)
    self.timer = self.timer + dt
end

function scene:keyPressed(key)
    if key == "d" then
        self.mixing_drinks = not self.mixing_drinks
    end
end

function scene:draw()
    if self.mixing_drinks then
        love.graphics.setShader(blur_shader)
        -- TODO: Split background and foreground into different layers and only blur one or the other depending on activity
    end
    love.graphics.draw(BACKGROUND_IMAGE, -self.bar_position, 0)
    for _, customer in pairs(self.customers) do
        local x, y = unpack(customer.position)
        love.graphics.draw(customer.sprite, x, y)
    end
    love.graphics.setShader()
end

return scene
