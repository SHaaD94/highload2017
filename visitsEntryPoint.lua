require('si_configReader')

local json = require('json')
local log = require('log')
local controller = {}

local function new()
    controller._repository = require('repository')

    return controller
end

local function parseId(uri)
    return tonumber(string.split(string.split(uri, '/')[3], '?')[1])
end

local function getVisit(id)
    return controller._repository.getVisit(id);
end

local function saveVisit(visitJson)
    if visitJson.id == nil or type(visitJson.id) ~= 'number' then
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

    return controller._repository.updateVisit(visitId, visitJson);
end

function visitEndpoint(req)
    print('visit endpoint')
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
        print('post')
        local jsonBody = json.decode(req.body)
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