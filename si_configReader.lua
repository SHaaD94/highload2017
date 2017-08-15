ConfigReader = {}
local log = require('log')

function ConfigReader:new(fileName)
    local currentInstance = {}
    currentInstance._configEntries = {}

    log.info("trying to read file: " .. fileName)

    local file, msg
    file, msg = io.open(fileName, "r+")

    if file then
        log.info('file opened successfully')
        currentInstance._configEntries = require('json').decode(file:read("*a"))
        io.close(file)
    else
        log.error("** Error: cannot open file " .. fileName .. " reason: " .. msg)
    end

    function currentInstance:getValue(property)
        return self._configEntries[property]
    end

    return currentInstance
end