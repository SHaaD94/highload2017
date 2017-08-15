local migrator = {}

local function grantGuestAccess()
    box.schema.user.grant('guest', 'read,write,execute', 'universe')
end

local function initTables()
    if not box.space.users then
        box.schema.space.create('users', { if_not_exists = true, engine = memtx })
        box.schema.space.create('locations', { if_not_exists = true, engine = memtx })
        box.schema.space.create('visits', { if_not_exists = true, engine = memtx })
    end

end

local function migrate()
    box.once('grant_guest_access', grantGuestAccess)
    box.once('init_segment_space', initTables)
end

return {
    migrate = migrate
}