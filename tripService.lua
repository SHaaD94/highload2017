local log = require('log')

local function start()
    log.info('starting server')

    require('si_migrator').migrate()

    require('si_httpController').new()
end

return {
    start = start;
}
