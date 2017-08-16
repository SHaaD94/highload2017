require('si_configReader')

local json = require('json')
local log = require('log')
local controller = {}

local function new()
    controller._repository = require('repository')

    return controller
end

--method
--GET
-------
-- uri
-- /users/343?id=1
-------
-- args
-- table: 0x407f0030
-------
-- proto
-- HTTP/1.1
-------
-- headers
-- table: 0x407f0058
-------
-- body
-- table
local function parseId(uri)
    return tonumber(string.split(string.split(uri, '/')[3], '?')[1])
end

local function getUser(id)
    return controller._repository.getUser(id);
end

local function saveUser(userJson)
    if getUser(userJson.id) ~= nil then
        return 400
    end
    controller._repository.saveUser(userJson);
    return 200
end

local function updateUser(userId, userJson)
    local user = getUser(userId)
    if not user then
        return 400
    end
    return controller._repository.updateUser(user, userJson);
end

function userEndpoint(req)
    print('user endpoint')
    local status = 200
    local response = {}
    if req.method == 'GET' then
        local userId = parseId(req.uri)
        response = getUser(userId)
        if not response then
            status = 404
        end
    end
    if req.method == 'POST' then
        print('post')
        local jsonBody = json.decode(req.body)
        if (string.match(req.uri, '/new')) then
            status = saveUser(jsonBody)
        else
            local userId = parseId(req.uri)
            status = updateUser(userId, jsonBody)
        end
    end

    return status, response
end

--
--function getIdsBySegment(req)
--    local segmentId = req.args.segmentId;
--    local className = req.args.dataClass;
--
--    local response = {}
--    response.status = 400;
--
--    if segmentId == nil then
--        response.body = "segmentId must be set";
--        return response
--    elseif className == nil then
--        response.body = "class must be set";
--        return response
--    else
--        --required for correct serialization by nginx
--        local result = {}
--        result.result = controller._repository:getIdsBySegment(tonumber64(segmentId), className)
--        return result;
--    end
--end

return {
    new = new
}