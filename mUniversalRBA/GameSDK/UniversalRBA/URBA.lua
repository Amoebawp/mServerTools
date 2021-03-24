local default_permissions = readOnly {
    {id = 'urba.roles.manage', description = 'allowed to manage roles', default = false},
    {id = 'urba.roles.view', description = 'allowed to view roles', default = false},
    {id = 'urba.permissions.manage', description = 'allowed to manage permissions', default = false},
    {id = 'urba.permissions.view', description = 'allowed to view permissions', default = false},
}

local default_admin_permissions = readOnly {
    ['urba.roles.manage'] = true,
    ['urba.roles.view'] = true,
    ['urba.permissions.manage'] = true,
    ['urba.permissions.view'] = true,
}

local default_staff_permissions = readOnly {
    ['urba.roles.manage'] = false,
    ['urba.roles.view'] = true,
    ['urba.permissions.manage'] = false,
    ['urba.permissions.view'] = true,
}

local default_player_permissions = readOnly {
    ['urba.roles.manage'] = false,
    ['urba.roles.view'] = false,
    ['urba.permissions.manage'] = false,
    ['urba.permissions.view'] = false,
}

local default_roles = readOnly {
    {
        ID = 0,
        Name = 'Player',
        Description = 'Player has no Role',
        Options = {BUILT_IN = true},
        Permissions = default_player_permissions,
    }, {
        ID = 100,
        Name = 'Admin',
        Description = 'Server Admin',
        Options = {BUILT_IN = true, IS_ADMIN = true},
        Permissions = default_admin_permissions,
    }, {
        ID = 101,
        Name = 'Staff',
        Description = 'Server Staff',
        Options = {BUILT_IN = true},
        Permissions = default_staff_permissions,
    },
    {
        ID = 102,
        Name = 'VIP',
        Description = 'VIP Player',
        Options = {BUILT_IN = true},
        Permissions = {},
    },
}

local LogWriter = require('UniversalRBA.Modules.LogWriter')

local UniversalRBA = {
    DataStore = MisDB.DataStore {name = 'URBA_DATA', persistance_dir = 'UniversalRBA_Data'},
    Logger = LogWriter('URBA:Core', './URBA.log'),
}

function UniversalRBA:InitPermissionManager()
    self.Logger:Log('Starting PermissionManager....')
    local PermissionManager = require('UniversalRBA.Systems.PermissionManager')(self.DataStore)
    PermissionManager:Init(default_permissions)
    self.Logger:Log('PermissionManager Started....')
    return PermissionManager, 'Permission Manager Initialised'
end

function UniversalRBA:InitRoleManager()
    self.Logger:Log('Starting RoleManager....')
    local RoleManager = require('UniversalRBA.Systems.RoleManager')(self.DataStore)
    RoleManager:Init(default_roles, default_permissions)
    self.Logger:Log('RoleManager Started....')
    return RoleManager, 'Role Manager Initialised'
end

function UniversalRBA:InitPlayerManager()
    self.Logger:Log('Starting PlayerManager....')
    local PlayerManager = require('UniversalRBA.Systems.PlayerManager')(self.DataStore)
    self.Logger:Log('PlayerManager Started....')
    return PlayerManager, 'Player Manager Initialised'
end

function UniversalRBA:Init()
    -- #region URBA:INIT:CreateURBACore

    -- Init PermissionManager
    local PermissionManager, pm_msg = self:InitPermissionManager()
    if not PermissionManager then return false, pm_msg end
    self.PermissionManager = PermissionManager ---@type URBA.URBA.PermissionManager
    --- Init RoleManager
    local RoleManager, rm_msg = self:InitRoleManager()
    if not RoleManager then return false, rm_msg end
    self.RoleManager = RoleManager ---@type URBA.URBA.RoleManager

    --- Init PlayerManager
    local PlayerManager, sm_msg = self:InitPlayerManager()
    if not PlayerManager then return false, sm_msg end
    self.PlayerManager = PlayerManager ---@type URBA.PlayerManager
    -- #endregion URBA:INIT:CreateURBACore

    -- #region URBA:INIT:CreatePublicInterfaces

    --- URBA Core loaded ok. create Public interfaces
    local PublicInterface = require('UniversalRBA.Systems.PublicInterface')
    if (not PublicInterface) then return false, 'Failed to Load URBA:PublicInterface' end
    local URBACommands = require('UniversalRBA.Systems.URBACommands')
    if (not URBACommands) then return false, 'Failed to Load URBA:URBACommands' end

    -- #endregion URBA:INIT:CreatePublicInterfaces

    return true
end

RegisterModule('UniversalRBA.URBA', UniversalRBA)
return UniversalRBA
