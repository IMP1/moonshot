local scene_manager = require 'lib.conductor'
local localisation = require 'lib.sweet_nothings'

scene_manager.hook()

T = localisation.internationalise

function love.load()
	-- TODO: Try to load settings
	-- TODO: Fail to default settings
	-- TODO: Apply settings: 
	--         * Set window size/fullscreen
	--         * Set volumes
	--         * etc...
	love.graphics.setBackgroundColor(0.125, 0.125, 0.2)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
	local title_scene = require 'scn.title'
	scene_manager.setScene(title_scene.new())
end

function love.update(dt)
	scene_manager.update(dt)
end

function love.draw()
	scene_manager.draw()
end
