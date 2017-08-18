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
    return controller._repository.updateLocation(locationId, locationJson);
end

local function getLocationAverage(locationId, fromDate, toDate, fromAge, toAge, gender)
    fromDate = tonumber(fromDate)
    toDate = tonumber(toDate)
    fromAge = tonumber(fromAge)
    toAge = tonumber(toAge)
    local status, avg = controller._repository.getLocationAverage(locationId, fromDate, toDate, fromAge, toAge, gender);
    local response = {}
    response.avg = avg
    return status, response
end

function locationEndpoint(req)
    local status = 200
    local response = {}
    if req.method == 'GET' then
        local locationId = parseId(req.uri)
        if string.match(req.uri, '/avg') then
            local s, r = getLocationAverage(locationId, req.args.fromDate, req.args.toDate, req.args.fromAge, req.args.toage, req.args.gender)
            status = s
            response = r
        else
            response = getLocation(locationId)
            if not response then
                status = 404
            end
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