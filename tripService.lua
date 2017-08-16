local log = require('log')

local function start()
    log.info('starting server')

    require('dbFiller').fill()
    require('migrationHandler').migrate()

    require('usersEntryPoint').new()
    require('visitsEntryPoint').new()
    require('locationsEntryPoint').new()
end

return {
    start = start;
}
