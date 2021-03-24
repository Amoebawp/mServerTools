--- Load UniversalRBA Core
local function Load_URBA_Core()
    local DataStore = MisDB.DataStore

    --- UniversalRBA Public class
    ---@class UniversalRBA
    ---@field state table `Current State of this UniversalRBA Instance`
    ---@field DataStore MisDB.DataStore `URBA PersistantStorage`
    ---@field RoleManager URBA.RoleManager `URBA RoleManager`
    ---@field PermissionManager URBA.PermissionManager `URBA PermissionManager`
    UniversalRBA = {}
    --- g_UniversalRBA will be our index
    setmetatable(UniversalRBA, {__index = g_UniversalRBA})
    return true
end

--- Create UniversalRBA Standard Events
local function CreateStandardEvents()
    -- >> Called after UniversalRBA Core PreLoads esential classes/modules
    UniversalRBA.Events:observe('URBA:OnPreLoaded', function(event, data, ...)
        --- Output to DebugLog
        UniversalRBA.Debug(event.type, 'Stage reached...')
        return true
    end, true)

    -- >> Called after UniversalRBA Core has fully Loaded
    UniversalRBA.Events:observe('URBA:OnAllLoaded', function(event, data, ...)
        --- Output to DebugLog
        UniversalRBA.Debug(event.type, 'Stage reached...')
        return true
    end, true)

    -- Register Init Callback
    function UniversalRBA:Init(init_time)
        -- save init time
        self.state['initialised'] = init_time

        -- emit OnPreloadedEvent passing our final init time
        self.Events:emit('UniversalRBA:OnPreLoaded', {initialised = init_time})
        UniversalRBA.Log('UniversalRBA', 'UniversalRBA Initialised...')
    end
    RegisterCallback(_G, 'OnInitPreLoaded', nil, function() UniversalRBA:Init(os.date()) end)

    -- Register Start Callback
    function UniversalRBA:Start(start_time)
        Script.LoadScriptFolder('UniversalRBA/Systems')
        -- save start time
        self.state['started'] = start_time
        self.Events:emit('UniversalRBA:OnAllLoaded', {started = start_time})
        UniversalRBA.Log('UniversalRBA', 'UniversalRBA Started...')
    end
    RegisterCallback(_G, 'OnInitAllLoaded', nil, function() UniversalRBA:Start(os.date()) end)
    return true
end

local function init()
    if (not Load_URBA_Core()) then
        LogError('URBA:main failed @ stage: Load UniversalRBA Core')
        return
    end
    if (not CreateStandardEvents()) then
        LogError('URBA: init failed @ stage: CreateStandardEvents')
        return
    end
    ---TODO: Improve logging
    -- >> Currently using a simple wrapper to handle logging, we should improve this to include more info.
end

OnlyRunOnce(init)
