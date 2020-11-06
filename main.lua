local scene_manager = require 'lib.conductor'
local settings_manager = require 'lib.settings_manager'
local localisation = require 'lib.sweet_nothings'

scene_manager.hook()

T = localisation.internationalise

local window_canvas

-- Rewrite LOVE functions to correct mouse positions.
local global_position = love.mouse.getPosition
function love.mouse.getPosition()
    local scale = math.min(love.graphics.getWidth() / window_canvas:getWidth(), love.graphics.getHeight() / window_canvas:getHeight())
    local ox = ((love.graphics.getWidth() - (window_canvas:getWidth() * scale)) / 2) / scale
    local oy = ((love.graphics.getHeight() - (window_canvas:getHeight() * scale)) / 2) / scale
    local mx, my = global_position()
    return (mx / scale) - ox, (my / scale) - oy
end
local global_pressed = love.handlers.mousepressed
function love.handlers.mousepressed(mx, my, ...)
    mx, my = love.mouse.getPosition()
    global_pressed(mx, my, ...)
end
local global_released = love.handlers.mousereleased
function love.handlers.mousereleased(mx, my, ...)
    mx, my = love.mouse.getPosition()
    global_released(mx, my, ...)
end
local global_moved = love.handlers.mousemoved
function love.handlers.mousemoved(mx, my, ...)
    mx, my = love.mouse.getPosition()
    global_moved(mx, my, ...)
end

function love.load()
    -- Setup Graphics
	love.graphics.setBackgroundColor(0.125, 0.125, 0.2)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    -- Load Settings (using defaults)
    settings_manager.load({
        window_width = 1280,
        window_height = 720,
        volumn_music = 1,
        volumn_sfx = 1,
        language = "en-gb",
    })

    -- Apply Settings
    target_width, target_height, _ = love.window.getMode()
    local width = settings_manager.get("window_width")
    local height = settings_manager.get("window_height")
    local window_scaling = math.min(width / target_width, height / target_height)
    window_canvas = love.graphics.newCanvas(target_width, target_height)
    love.window.setMode(width, height)
	localisation.setLanguage(settings_manager.get("language"))
	-- TOOD: Set volumes

    -- Start Game
	local title_scene = require 'scn.title'
	scene_manager.setScene(title_scene.new())
end

function love.update(dt)
	scene_manager.update(dt)
end

function love.draw()
    local window_scaling = math.min(love.graphics.getWidth() / window_canvas:getWidth(), love.graphics.getHeight() / window_canvas:getHeight())
    -- Resolution Handling
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas(window_canvas)
    love.graphics.clear()
	scene_manager.draw()
    love.graphics.setCanvas()
    local ox, oy = 0, 0
    local letterboxing = false
    if window_canvas:getWidth() * window_scaling < love.graphics.getWidth() then
        ox = ((love.graphics.getWidth() - (window_canvas:getWidth() * window_scaling)) / 2) / window_scaling
        letterboxing = true
    end
    if window_canvas:getHeight() * window_scaling < love.graphics.getHeight() then
        oy = ((love.graphics.getHeight() - (window_canvas:getHeight() * window_scaling)) / 2) / window_scaling
        letterboxing = true
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(window_canvas, 0, 0, 0, window_scaling, window_scaling, -ox, -oy)

    -- Letterboxing
    if letterboxing then
        love.graphics.setColor(0, 0, 0)
        local w = ox * window_scaling
        love.graphics.rectangle("fill", 0, 0, w, love.graphics.getHeight())
        love.graphics.rectangle("fill", love.graphics.getWidth() - w, 0, w, love.graphics.getHeight())

        local h = oy * window_scaling
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), h)
        love.graphics.rectangle("fill", 0, love.graphics.getHeight() - h, love.graphics.getWidth(), h)
    end

    -- DEBUG info
    local mx, my = love.mouse.getPosition()
    love.graphics.setColor(1, 1, 1)
	love.graphics.print(T("Moon Shots! | " .. scene_manager.scene().name), 0, love.graphics.getHeight() - 16)
    love.graphics.print(mx .. ", " .. my, 0, 0)
end
