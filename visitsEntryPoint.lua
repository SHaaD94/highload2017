require('si_configReader')

local json = require('json')
local log = require('log')
local controller = {}

local function new()
    controller._repository = require('repository')

    return controller
end

local function isNumber(value)
    local result, _ = pcall(function() math.floor(value) end)
    return result
end

local function parseId(uri)
    return tonumber(string.split(string.split(uri, '/')[3], '?')[1])
end

local function getVisit(id)
    return controller._repository.getVisit(id);
end

local function saveVisit(visitJson)
    if visitJson.id == nil or not isNumber(visitJson.id) then
        return 400
    end

    for _, value in pairs(visitJson) do
        if value == nil then
            return 400
        end
    end
    return controller._repository.saveVisit(visitJson);
end

local function updateVisit(visitId, visitJson)
    for arg, value in pairs(visitJson) do
        if arg == 'id' then
            return 400
        end
        if value == nil then
            return 400
        end
    end
    if (visitJson.location ~= nil and not isNumber(visitJson.location)) or
            (visitJson.user ~= nil and not isNumber(visitJson.user)) or
            (visitJson.visited_at ~= nil and not isNumber(visitJson.visited_at)) then
        return 400
    end

    return controller._repository.updateVisit(visitId, visitJson);
end

function visitEndpoint(req)
    local status = 200
    local response = {}
    if req.method == 'GET' then
        local visitId = parseId(req.uri)
        response = getVisit(visitId)
        if not response then
            status = 404
        end
    end
    if req.method == 'POST' then
        local parseStatus, jsonBody = pcall(function()
            return json.decode(req.body)
        end)
        if not parseStatus then
            return 400, response
        end
        if (string.match(req.uri, '/new')) then
            status = saveVisit(jsonBody)
        else
            local visitId = parseId(req.uri)
            status = updateVisit(visitId, jsonBody)
        end
    end

    return status, response
end

return {
    new = new
}