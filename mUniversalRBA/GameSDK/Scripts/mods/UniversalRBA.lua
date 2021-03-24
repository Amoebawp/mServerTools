--
-- ──────────────────────────────────────────────────────────────────────────── I ──────────
--          :::::: m F r a m e w o r k  S T A R T U P   F I L E ::::::
-- ──────────────────────────────────────────────────────────────────────────────────────
--- UniversalRBA Global Namespace.
g_UniversalRBA = {
    --- UniversalRBA
    _NAME = 'UniversalRBA',
    --- UniversalRBA Version
    _VERSION = '0.1.0a',
    --- UniversalRBA Description
    _DESCRIPTION = [[
        UniversalRBA2 
            a Miscreated Role Base Access system.
        - made with MisModWorkspace.
    ]],
    LOGLEVEL = 1,
    LOGFILE = './UniversalRBA.log',
    --- UniversalRBA BaseDir
    BASEDIR = 'UniversalRBA/',
    --- UniversalRBA global classes
    classes = {}, ---@type table<string,table|function>
    --- UniversalRBA global modules
    modules = {}, ---@type table<string,table|function>
    --- UniversalRBA global plugins
    plugins = {}, ---@type table<string,table|function>
    --- UniversalRBA global state
    state = {
        --- UniversalRBA Init Time
        initialised = false, ---@type boolean|table
        --- UniversalRBA Start Time
        started = false, ---@type boolean|table
    },
}

if System.IsEditor() then g_UniversalRBA.LOGLEVEL = 3 end

-- >> load common files
Script.ReloadScript(g_UniversalRBA.BASEDIR .. 'Common.lua')
Script.LoadScriptFolder(g_UniversalRBA.BASEDIR .. 'Common/')

-- >> load MisDB2
Script.LoadScriptFolder('MisDB2/')
MisDB = require('MisDB2.MisDB')

-- >> reload modules
Script.LoadScriptFolder(g_UniversalRBA.BASEDIR .. 'Modules/')

--- UniversalRBA Event Manager
g_UniversalRBA.Events = require('UniversalRBA.Modules..events')

--- >> reload classes
Script.LoadScriptFolder(g_UniversalRBA.BASEDIR .. 'Classes/')

-- >> load UniversalRBA/main
Script.ReloadScript(g_UniversalRBA.BASEDIR .. 'main.lua')
