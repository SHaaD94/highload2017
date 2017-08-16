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
        --print(content)
    end
end

return {
    fill = fill
}
