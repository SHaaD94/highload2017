local log = require('log')

Repository = {}

function Repository:new()
    local repository = {}

    local function safeGetSpace(spaceName)
        local fiber = require('fiber')
        for i = 1, 4 do
            local spaceStatus, spaceResult = pcall(safeCreateSpace, spaceName)
            if spaceStatus then
                local indexStatus, indexResult = pcall(safeCreateIndex, spaceResult)
                if indexStatus then
                    box.begin()
                    fiber.sleep(1)
                    box.commit()
                    return spaceResult
                end
            end
            fiber.sleep(1)
        end

        error('Something went wrong while creating space')
    end

    local function getSpace(spaceName)
        local space = repository._createdSpaces[spaceName]

        if space == nil then
            space = box.space[spaceName]
        end

        if space == nil then
            space = safeGetSpace(spaceName)
            repository._createdSpaces[spaceName] = space
        end

        return space
    end


    local function getLastId(segmentId)
        local status, segmentInfo = pcall(function()
            return box.space.segmentInfo:select(segmentId)[1]
        end)

        if not status then
            error(segmentInfo)
        end

        if segmentInfo == nil then
            error('segment with id ' .. tostring(segmentId) .. ' does not exist')
        end

        local minId = segmentInfo[2]
        local maxId = segmentInfo[3]
        local lastId = segmentInfo[4]

        if (minId == nil or maxId == nil or lastId == nil) then
            error('something wrong with data of segment ' .. segmentInfo[1])
        end

        local resultFeatureId = lastId
        if (resultFeatureId == 0) then
            resultFeatureId = minId + 1
        else
            resultFeatureId = resultFeatureId + 1
        end

        if (resultFeatureId > maxId) then
            error('segment id limit has exceeded')
        end

        local status, message = pcall(function()
            box.space.segmentInfo:update(segmentId, { { '=', 4, resultFeatureId } })
        end)

        if not status then
            error(message)
        end

        return resultFeatureId
    end

    local function selectFeature(space, id, sourceId)
        return space:select { id, sourceId }[1]
    end

    function repository:getStableId(segmentId, class, id, sourceId)
        local space = getSpace(class)
        local selectIdStatus, result = pcall(selectFeature, space, id, sourceId)

        if not selectIdStatus then
            error(result)
        end
        if result ~= nil then
            return result[4]
        end

        --if stable id doesn't exist, get stable id
        local getIdStatus, stableIdResult = pcall(getLastId, segmentId)
        if not getIdStatus then
            error(stableIdResult)
        end

        -- insert stableId
        local insertStatus, insertResult = pcall(function()
            box.space[class]:insert { id, sourceId, segmentId, stableIdResult }
        end)

        if insertStatus then
            return stableIdResult
        else
            local selectIdStatus, secondTryResult = pcall(selectFeature, space, id, sourceId)

            if not selectIdStatus then
                error(secondTryResult)
            end

            return secondTryResult[4]
        end
    end

    function repository:getIdsBySegment(segmentId, class)
        local space = getSpace(class)
        local selected = space.index.segment:select { segmentId }
        local resultObject = {}
        for counter, value in pairs(selected) do
            local obj = {}
            obj.id = value[1]
            obj.sourceId = value[2]
            obj.stableId = value[4]
            resultObject[counter] = obj
        end
        return resultObject
    end

    return repository
end
