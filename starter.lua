#!    /usr/bin/env tarantool
log = require('log')

box.cfg {
    listen = 3310;
    custom_proc_title = "trip_service",
    log_level = 3,
    rows_per_wal = 10000,
    snapshot_period = 10000000,
    snapshot_count = 1,
    slab_alloc_arena = 3,
    slab_alloc_maximal = 4
}

log.warn('starting new instance')
require('tripService').start()

