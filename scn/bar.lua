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
    self.possible_conversations = {}
    self.conversation = nil
    self.customers = {}
    self.triggers = {}
    self.timer = 0
    self.drinks_made = {}

    self:addCustomer("test")

    table.insert(self.possible_conversations, love.filesystem.load("dat/conversations/test_1.lua")())

	return self
end

function scene:startConversation(convo)
    self.conversation = convo
    self.conversation.stage = 1
    self.conversation.timer = 0
    self.conversation.stage_timer = 0
end

function scene:addCustomer(id)
    local details = love.filesystem.load("dat/people/" .. id .. ".lua")()
    table.insert(self.customers, {
        id = id,
        name = details.name,
        sprite = love.graphics.newImage("res/" .. details.graphics_prefix .. "_1.png"),
        position = {100, 130},
    })
end

function scene:addDrinkRequest(customer_name, drink_name)
end

function scene:giveDrink(customer_name, drink_name)
end

function scene:drinksReady(...)
    return false
end

function scene:getCustomer(id)
    for _, customer in pairs(self.customers) do
        if customer.id == id then
            return customer
        end
    end
    return nil
end

function scene:updateConversation(dt)
    if self.conversation then
        self.conversation.timer = self.conversation.timer + dt
        self.conversation.stage_timer = self.conversation.stage_timer + dt
        if self.conversation.stage_timer >= self.conversation.tree[self.conversation.stage].time then
            self.conversation.stage_timer = self.conversation.stage_timer - self.conversation.tree[self.conversation.stage].time
            self.conversation.stage = self.conversation.tree[self.conversation.stage].timeout
            if self.conversation.stage == 0 then
                self.conversation = nil
            end
        end
    else
        local next_convo = nil
        for i, convo in pairs(self.possible_conversations) do
            local condition_met = (convo.condition == nil or convo.condition(self))
            local participants_present = true
            for _, participant_id in pairs(convo.participants) do
                local present = false
                for _, customer in pairs(self.customers) do
                    if customer.id == participant_id then
                        present = true
                    end
                end
                if not present then
                    participants_present = false
                end
            end
            if condition_met and participants_present then
                next_convo = i
            end
        end
        if next_convo then
            self:startConversation(self.possible_conversations[next_convo])
            table.remove(self.possible_conversations, next_convo)
        end
    end
end

function scene:update(dt)
    self.timer = self.timer + dt
    self:updateConversation(dt)
end

function scene:keyPressed(key)
    if key == "d" then
        self.mixing_drinks = not self.mixing_drinks
    end
    if self.conversation and (key <= "9" and key >= "0") then
        local n = tonumber(key)
        if n >= 1 and n <= #self.conversation.tree[self.conversation.stage].responses then
            local response = self.conversation.tree[self.conversation.stage].responses[n]
            local condition = response.condition
            if condition == nil or condition(self) then
                local action = response.action
                if action then
                    action(self)
                end
                print(response.text)
                self.conversation.stage = response.next
            end
        end
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
    if self.conversation then
        local convo_stage = self.conversation.tree[self.conversation.stage]
        local text = convo_stage.text
        local speaker_id = convo_stage.speaker
        local x = self:getCustomer(speaker_id).position[1]
        -- TODO: Have a text outline shader to make it all more readable.
        -- TODO: Get a better font.
        love.graphics.printf(text, x, 160, 300)

        local time_taken = self.conversation.stage_timer
        local time_total = convo_stage.time
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", x - 40, 160, 4, 120)
        love.graphics.setColor(0, 1, 1)
        love.graphics.rectangle("fill", x - 40, 160 + (time_taken / time_total) * 120, 4, 120 * (1 - time_taken / time_total))
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x - 40, 160, 4, 120)

        for i, response in ipairs(convo_stage.responses) do
            local available = response.condition == nil or response.condition(self)
            if available then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.6, 0.6, 0.6)
            end
            -- TODO: Calculate where to draw response options
            love.graphics.print(tostring(i) .. ". " .. response.text, x, 280 + i*16)
        end
    end
end

return scene
