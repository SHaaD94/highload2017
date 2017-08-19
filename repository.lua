local log = require('log')

local currentDate = require('dbFiller').getDateNow()

-------------------------------- Users-----------------------------------
-- 1    "id": 1,
-- 2    "email": "robosen@icloud.com",
-- 3    "first_name": "Данила",
-- 4    "last_name": "Стамленский",
-- 5    "gender": "m",
-- 6    "birth_date": 345081600,
local function getUser(id)
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
    local status, _ = pcall(function()
        return box.space.users:insert { user.id, user.email, user.first_name, user.last_name, user.gender, user.birth_date }
    end)

    if not status then
        return 400
    end
    return 200
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
        return 404
    else
        return 200
    end
end

local function getUserVisits(id, fromDate, toDate, countryEq, toDistance)
    local user = getUser(id)
    if not user then
        return 404, {}
    end
    local userVisits = box.space.visits.index.user_vis:select({ id }, { { iterator = box.index.GE }, { iterator = box.index.EQ } })
    local result = {}
    local index = 1
    for _, visit in pairs(userVisits) do
        local visitObj = {}
        local location = box.space.locations:select { visit[2] }[1]
        local distance = location[5]
        local country = location[3]

        visitObj.place = location[2]
        visitObj.visited_at = visit[4]
        visitObj.mark = visit[5]

        local passByFromDate = not fromDate or fromDate < visitObj.visited_at
        local passByToDate = not toDate or toDate > visitObj.visited_at
        local passByToDistance = not toDistance or toDistance > distance
        local passByCountry = not countryEq or countryEq == country
        if passByFromDate and passByToDate and passByToDistance and passByCountry then
            result[tonumber(index)] = visitObj
            index = index + 1
        end
    end

    return 200, result
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
    local status, _ = pcall(function()
        return box.space.visits:insert { visit.id, visit.location, visit.user, visit.visited_at, visit.mark }
    end)

    if not status then
        return 400
    end
    return 200
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
        return 404
    else
        return 200
    end
end

------------------------------------- Locations----------------------------
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
    local status, _ = pcall(function()
        box.space.locations:insert { location.id, location.place, location.country, location.city, location.distance }
    end)

    if not status then
        return 400
    end
    return 200
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
        return 404
    else
        return 200
    end
end

local function getAge(birthDate)
    -- fucking chicky algorithm, spent about 2 days to find it out
    local diff = os.difftime(currentDate, birthDate)
    return diff / (365.24 * 24 * 60 * 60)
end

local function getAgeTimestamp(age)
    local localDate = os.date("*t", currentDate)
    localDate.year = localDate.year - age;
    return os.time(localDate)
end

local function getLocationAverage(locationId, fromDate, toDate, fromAge, toAge, gender)
    local location = getLocation(locationId)
    if not location then
        return 404, {}
    end

    local locationVisits = box.space.visits.index.location:select(locationId)
    local index = 0
    local avg = 0
    for _, visit in pairs(locationVisits) do
        local user = box.space.users:select { visit[3] }[1]
        local age = getAge(user[6])
        local birthDate = user[6]

        local userGender = user[5]
        local visitedAt = visit[4]

        local passByFromDate = not fromDate or fromDate < visitedAt
        local passByToDate = not toDate or toDate > visitedAt
        local passByToAge = not toAge or toAge > age
        local passByFromAge = not fromAge or fromAge < age
        local passByGender = not gender or gender == userGender
        if passByFromDate and passByToDate and passByToAge and passByFromAge and passByGender then
            avg = avg + visit[5] -- mark
            index = index + 1
        end
    end
    if index ~= 0 then
        avg = math.floor(avg / index * 100000 + 0.5) / 100000
    end
    return 200, avg
end


return {
    ------- User---------
    getUser = getUser,
    saveUser = saveUser,
    updateUser = updateUser,
    getUserVisits = getUserVisits,
    ------- Visit---------
    getVisit = getVisit,
    saveVisit = saveVisit,
    updateVisit = updateVisit,
    ------- Location----------
    getLocation = getLocation,
    getLocationAverage = getLocationAverage,
    saveLocation = saveLocation,
    updateLocation = updateLocation
}
