local settings_manager = {}
local settings_manager_mt = {}
setmetatable(settings_manager, settings_manager_mt)

SETTINGS_FILEPATH = ".user_settings"

local user_settings = {}

function settings_manager.clear(defaults)
    user_settings = {}
    for k, v in pairs(defaults) do
        user_settings[k] = v
    end
end

local function pack_value(value, depth)
    -- TODO: Test with strings containing various combinations of `"`, `\"`, `\\"`etc.
    if type(value) == "string" then
        return "\"" .. value .. "\""
    end
    if type(value) == "table" then
        local padding = string.rep("\t", rep(depth or 0))
        local packed_value = padding .. "{\n"
        for k, v in pairs(value) do
            packed_value = packed_value .. padding .. "\t[" .. pack_value(k, depth+1)
            packed_value = packed_value .. "] = " .. pack_value(v, depth+1) .. ",\n"
        end
        packed_value = packed_value .. padding .. "}\n"
        return packed_value
    end
    if type(value) == "number" or type(value) == "boolean" then
        return value
    end
end

function settings_manager.load(defaults)
    settings_manager.clear(defaults)

    local file_info = love.filesystem.getInfo(SETTINGS_FILEPATH)
    if not file_info then
        local settings_file = love.filesystem.newFile(SETTINGS_FILEPATH)
        settings_file:open('w')
        settings_file:write("return {\n")
        settings_file:write("}\n")
        settings_file:close()
    end

    local saved_settings = love.filesystem.load(SETTINGS_FILEPATH)()
    for k, v in pairs(saved_settings) do
        settings_manager.set(k, v)
    end
end

function settings_manager.save()
    local settings_file = love.filesystem.newFile(SETTINGS_FILEPATH)
    settings_file:open('w')
    settings_file:write("return {\n")
    for k, v in pairs(user_settings) do
        local packed_value = pack_value(v)
        settings_file:write("\t" .. k .. " = " .. packed_value .. ",\n")
    end
    settings_file:write("}\n")
    settings_file:close()
end

function settings_manager.set(key, value)
    user_settings[key] = value
end

function settings_manager.get(key)
    return user_settings[key]
end

return settings_manager
