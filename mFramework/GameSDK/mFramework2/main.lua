local DataStore = require('mFramework2.Classes.DataStore')

--- Create mFramework Public interface
local function CreatePublicInterface()
    --- mFramework Public class
    ---@class mFramework
    ---@field state table `Current State of this mFramework Instance`
    mFramework2 = {}
    g_mFramework.PersistantStorage = DataStore {persistance_dir = 'mFramewor2/PersistantStorage'} ---@type DataStore
    --- g_mFramework will be our index
    setmetatable(mFramework2, {__index = g_mFramework})
    return true
end

--- Create mFramework Standard Events
local function CreateStandardEvents()
    -- >> Called after mFramework Core PreLoads esential classes/modules
    mFramework2.Events:observe('mFramework2:OnPreLoaded', function(event, data, ...)
        --- Output to DebugLog
        mFramework2.Debug(event.type, 'Stage reached...')
        return true
    end, true)

    -- >> Called after mFramework Core has fully Loaded
    mFramework2.Events:observe('mFramework2:OnAllLoaded', function(event, data, ...)
        --- Output to DebugLog
        mFramework2.Debug(event.type, 'Stage reached...')
        return true
    end, true)

    return true
end

--- Create mFramework Standard Interface
local function CreateStandardInterface()
    -- Register Init Callback
    function mFramework2:Init(init_time)
        -- setup CustomEntity Support
        Script.ReloadScript(FS.joinPath(self.BASEDIR, 'CustomEntity.lua'))
        -- Load CustomEntities
        Script.LoadScriptFolder('Scripts/CustomEntities')
        -- >> in editor we need to ReExpose Registered CustomEntities extra early else stuff wont work properly
        if System.IsEditor() then ReExposeAllRegistered() end

        -- Setup our CustomPlayer
        Script.ReloadScript(FS.joinPath(self.BASEDIR, 'CustomPlayer.lua'))

        -- save init time
        self.state['initialised'] = init_time

        -- emit OnPreloadedEvent passing our final init time
        self.Events:emit('mFramework2:OnPreLoaded', {initialised = init_time})
        mFramework2.Log('mFramework', 'mFramework Initialised...')
    end
    RegisterCallback(_G, 'OnInitPreLoaded', nil, function() mFramework2:Init(os.date()) end)

    -- Register Start Callback
    function mFramework2:Start(start_time)
        -- save start time
        self.state['started'] = start_time
        Script.ReloadScript(FS.joinPath(self.BASEDIR, 'Scripts', 'OnStartup.lua'))
        ReExposeAllRegistered()
        self.Events:emit('mFramework2:OnAllLoaded', {started = start_time})
        mFramework2.Log('mFramework', 'mFramework Started...')
    end
    RegisterCallback(_G, 'OnInitAllLoaded', nil, function() mFramework2:Start(os.date()) end)

    return true
end

local function init()
    if (not CreatePublicInterface()) then
        LogError('mFramework2:main failed @ stage: CreatePublicInterface()')
        return
    end
    if (not CreateStandardEvents()) then
        LogError('mFramework2: init failed @ stage: CreateStandardEvents')
        return
    end
    if (not CreateStandardInterface()) then
        LogError('mFramework2: init failed @ stage: CreateStandardInterface()')
        return
    end
    ---TODO: Improve logging
    -- >> Currently using a simple wrapper to handle logging, we should improve this to include more info.
end

OnlyRunOnce(init)
