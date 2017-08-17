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

local function getLocation(id)
    return controller._repository.getLocation(id);
end

local function saveLocation(locationJson)
    return controller._repository.saveLocation(locationJson);
end

local function updateLocation(locationId, locationJson)
    print('update loc')
    return controller._repository.updateLocation(locationId, locationJson);
end

function locationEndpoint(req)
    print('location endpoint')
    local status = 200
    local response = {}
    if req.method == 'GET' then
        local locationId = parseId(req.uri)
        response = getLocation(locationId)
        if not response then
            status = 404
        end
    end
    if req.method == 'POST' then
        print('post')
        local jsonBody = json.decode(req.body)
        if (string.match(req.uri, '/new')) then
            status = saveLocation(jsonBody)
        else
            local locationId = parseId(req.uri)
            status = updateLocation(locationId, jsonBody)
        end
    end

    return status, response
end

return {
    new = new
}