require('zip')
local function fill()
    local json = require('json')
    local repository = require('repository')

    local path = '/tmp/data/data.zip'
    local zfile, err = zip.open(path)

    for file in zfile:files() do
        local currentFile, err = zfile:open(file.filename)
        local entityName = string.split(file.filename, '_')[1]
        local content = json.decode(currentFile:read("*a"))

        for _, entity in pairs(content[entityName]) do
            if (entityName == 'locations') then
                repository.saveLocation(entity)
            end
            if (entityName == 'users') then
                repository.saveUser(entity)
            end
            if (entityName == 'visits') then
                repository.saveVisit(entity)
            end
        end
    end
end

local function getDateNow()
    local path = '/tmp/data/options.txt'
    local fio = require('fio')
    local file = fio.open(path, {'O_RDONLY'})
    print('found options.txt!')
    print('reading currentDate!')
    local content = tonumber(string.split(file:read(25), '\n')[1])
    file:close()
    print('current date has been read successfully:')
    print(content)

    print('removing hours, minutes and seconds:')
    local localDate = os.date("*t",os.time())
    localDate.hour = 0
    localDate.min = 0
    localDate.sec = 0
    content = os.time(localDate)
    print('new date is :')
    print(content)

    return content
end

return {
    fill = fill,
    getDateNow = getDateNow
}
