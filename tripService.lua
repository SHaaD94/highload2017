local log = require('log')

local function start()
    log.info('starting server')

    require('migrationHandler').migrate()

    require('userEntryPoint').new()
end

return {
    start = start;
}
