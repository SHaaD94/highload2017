local function grantGuestAccess()
    box.schema.user.grant('guest', 'read,write,execute', 'universe')
end

local function initTables()
    if not box.space.users then
        box.schema.space.create('users', { if_not_exists = true, engine = memtx })
        box.space.users:create_index('primary', { type = 'HASH', parts = { 1, 'number' } })
        --space:create_index('segment', { unique = false, if_not_exists = true, parts = { 3, 'unsigned' } })

        box.schema.space.create('locations', { if_not_exists = true, engine = memtx })
        box.space.locations:create_index('primary', { type = 'HASH', parts = { 1, 'number' } })

        box.schema.space.create('visits', { if_not_exists = true, engine = memtx })
        box.space.visits:create_index('primary', { type = 'HASH', parts = { 1, 'number' } })
        box.space.visits:create_index('location', { unique = false, type = 'TREE', parts = { 2, 'number' } })
        box.space.visits:create_index('user', { unique = false, type = 'TREE', parts = { 3, 'number' } })
        box.space.visits:create_index('user_vis', { unique = false, type = 'TREE', parts = { 3, 'number', 4, 'number' } })
    end
end

local function migrate()
    box.once('grant_guest_access', grantGuestAccess)
    box.once('init_segment_space', initTables)
end

return {
    migrate = migrate
}