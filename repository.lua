local log = require('log')

--1    "id": 1,
--2    "email": "robosen@icloud.com",
--3    "first_name": "Данила",
--4    "last_name": "Стамленский",
--5    "gender": "m",
--6    "birth_date": 345081600,

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

local function updateUser(user, userObj)
    print('updating')
    if userObj.email ~= nil then
        user.email = userObj.email
    end
    if userObj.first_name ~= nil then
        user.first_name = userObj.first_name
    end
    if userObj.last_name ~= nil then
        user.last_name = userObj.last_name
    end
    if userObj.gender ~= nil then
        user.gender = userObj.gender
    end
    if userObj.birth_date ~= nil then
        user.birth_date = userObj.birth_date
    end
    print('get params')
    box.space.users:update({ user.id }, {
        { '=', 2, user.email },
        { '=', 3, user.first_name },
        { '=', 4, user.last_name },
        { '=', 5, user.gender },
        { '=', 6, user.birth_date }
    })
    return 200
end

return {
    getUser = getUser,
    saveUser = saveUser,
    updateUser = updateUser
}
