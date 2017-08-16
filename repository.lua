local log = require('log')

-------------------------------- Users-----------------------------------
-- 1    "id": 1,
-- 2    "email": "robosen@icloud.com",
-- 3    "first_name": "Данила",
-- 4    "last_name": "Стамленский",
-- 5    "gender": "m",
-- 6    "birth_date": 345081600,
local function getUser(id)
    print('getting user')
    local userRow = box.space.users:select(id)[1]
    if not userRow then
        return nil
    end

    local user = {}
    user.id = userRow[1]
    user.email = userRow[2]
    user.first_name = userRow[3]
    user.last_name = userRow[4]
    user.gender = userRow[5]
    user.birth_date = userRow[6]
    return user
end

local function saveUser(user)
    print('saving user')
    box.space.users:insert { user.id, user.email, user.first_name, user.last_name, user.gender, user.birth_date }
end

local function updateUser(userId, userObj)
    local update = {}
    if userObj.email ~= nil then
        table.insert(update, { '=', 2, userObj.email })
    end
    if userObj.first_name ~= nil then
        table.insert(update, { '=', 3, userObj.first_name })
    end
    if userObj.last_name ~= nil then
        table.insert(update, { '=', 4, userObj.last_name })
    end
    if userObj.gender ~= nil then
        table.insert(update, { '=', 5, userObj.gender })
    end
    if userObj.birth_date ~= nil then
        table.insert(update, { '=', 6, userObj.birth_date })
    end
    local result = box.space.users:update({ userId }, update)
    if not result then
        return 400
    else
        return 200
    end
end

------------------------------------- Visits----------------------------
-- 1 id - уникальный внешний id посещения. Устанавливается тестирующей системой. 32-разрядное целое число.
-- 2 location - id достопримечательности. 32-разрядное целое число.
-- 3 user - id путешественника. 32-разрядное целое число.
-- 4 visited_at - дата посещения, timestamp с ограничениями: снизу 01.01.2000, а сверху 01.01.2015.
-- 5 mark - оценка посещения от 0 до 5 включительно. Целое число.
local function getVisit(id)
    local visitRow = box.space.visits:select(id)[1]
    if not visitRow then
        return nil
    end

    local visit = {}
    visit.id = visitRow[1]
    visit.location = visitRow[2]
    visit.user = visitRow[3]
    visit.visited_at = visitRow[4]
    visit.mark = visitRow[5]

    return visit
end

local function saveVisit(visit)
    box.space.visits:insert { visit.id, visit.location, visit.user, visit.visited_at, visit.mark }
end

local function updateVisit(visitId, visitNew)
    local update = {}
    if visitNew.location ~= nil then
        table.insert(update, { '=', 2, visitNew.location })
    end
    if visitNew.user ~= nil then
        table.insert(update, { '=', 3, visitNew.user })
    end
    if visitNew.visited_at ~= nil then
        table.insert(update, { '=', 4, visitNew.visited_at })
    end
    if visitNew.mark ~= nil then
        table.insert(update, { '=', 5, visitNew.mark })
    end
    local result = box.space.visits:update({ visitId }, update)
    if not result then
        return 400
    else
        return 200
    end
end

------------------------------------- Visits----------------------------
-- 1 id - уникальный внешний id достопримечательности. Устанавливается тестирующей системой. 32-разрядное целое число.
-- 2 place - описание достопримечательности. Текстовое поле неограниченной длины.
-- 3 country - название страны расположения. unicode-строка длиной до 50 символов.
-- 4 city - название города расположения. unicode-строка длиной до 50 символов.
-- 5 distance - расстояние от города по прямой в километрах. 32-разрядное целое число.
local function getLocation(id)
    local locationRow = box.space.locations:select(id)[1]
    if not locationRow then
        return nil
    end

    local location = {}
    location.id = locationRow[1]
    location.place = locationRow[2]
    location.country = locationRow[3]
    location.city = locationRow[4]
    location.distance = locationRow[5]

    return location
end

local function saveLocation(location)
    box.space.locations:insert { location.id, location.place, location.country, location.city, location.distance }
end

local function updateLocation(locationId, locationNew)
    local update = {}
    if locationNew.place ~= nil then
        table.insert(update, { '=', 2, locationNew.place })
    end
    if locationNew.country ~= nil then
        table.insert(update, { '=', 3, locationNew.country })
    end
    if locationNew.city ~= nil then
        table.insert(update, { '=', 4, locationNew.city })
    end
    if locationNew.distance ~= nil then
        table.insert(update, { '=', 5, locationNew.distance })
    end
    local result = box.space.locations:update({ locationId }, update)
    if not result then
        return 400
    else
        return 200
    end
end


return {
    ------- User---------
    getUser = getUser,
    saveUser = saveUser,
    updateUser = updateUser,
    ------- Visit---------
    getVisit = getVisit,
    saveVisit = saveVisit,
    updateVisit = updateVisit,
    ------- Location----------
    getLocation = getLocation,
    saveLocation = saveLocation,
    updateLocation = updateLocation
}
