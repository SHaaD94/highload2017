require('si_configReader')

local log = require('log')
local controller = {}

local function new()
--    controller._repository = Repository:new(controller._generator)

    return controller
end

function userEndpoint(req)
    log.info(req)
    print(req)
    for a,b in pairs(req) do
        print (a)
        print (b)
        print ('-----')
    end

    local result = {}
    result.ololo=12312
    return result
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