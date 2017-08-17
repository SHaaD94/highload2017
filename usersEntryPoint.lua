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

local function getUser(id)
    return controller._repository.getUser(id);
end

local function getUserVisits(id, fromDate, toDate, country, toDistance)
    fromDate = tonumber(fromDate)
    toDate = tonumber(toDate)
    toDistance = tonumber(toDistance)
    local status, visits = controller._repository.getUserVisits(id, fromDate, toDate, country, toDistance);
    local response= {}
    response.visits= visits
    return status, response
end

local function saveUser(userJson)
    return controller._repository.saveUser(userJson);
end

local function updateUser(userId, userJson)
    return controller._repository.updateUser(userId, userJson);
end

function userEndpoint(req)
    print('user endpoint')
    local status = 200
    local response = {}
    if req.method == 'GET' then
        local userId = parseId(req.uri)
        if string.match(req.uri, '/visits') then
            local s, r = getUserVisits(userId, req.args.fromDate, req.args.toDate, req.args.country, req.args.toDistance)
            status = s
            response = r
        else
            response = getUser(userId)
            if not response then
                status = 404
            end
        end
    end
    if req.method == 'POST' then
        local jsonBody = json.decode(req.body)
        if string.match(req.uri, '/new') then
            status = saveUser(jsonBody)
        else
            local userId = parseId(req.uri)
            status = updateUser(userId, jsonBody)
        end
    end

    return status, response
end

return {
    new = new
}