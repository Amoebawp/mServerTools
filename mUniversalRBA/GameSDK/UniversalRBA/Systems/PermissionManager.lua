local LogWriter = require('UniversalRBA.Modules.LogWriter')
local Permission = require('UniversalRBA.Classes.URBA_Permission')

--- URBA PersistantStorage
local DataSource ---@type MisDB.DataStore

---@class URBA.PermissionManager
local PermissionManager = Class('URBA.PermissionManager', {})

function PermissionManager:new(source)
    -- Update our DataSource
    DataSource = source
    self.Logger = LogWriter('URBA:PermissionManager', './URBA.log')
    self.Permissions = {}
end

function PermissionManager:Init(default_permissions)
    local permissions = (DataSource:GetValue('URBA.Permissions') or {})
    local initialised = (DataSource:GetValue('URBA.Permissions_initialised') or false)
    --- Check and initialise default permissions
    if (not initialised) then
        self.Logger:Warn('  !!! First Run !!! - Initialising URBA Defaults')
        for _, thisPermission in ipairs(default_permissions) do table.insert(permissions, thisPermission) end
        self.Logger:Warn('Created Default Permissions....')
        DataSource:SetValue('URBA.Permissions', permissions)
        DataSource:SetValue('URBA.Permissions_initialised', true)
    else
        self.Logger:Log('Loading Permissions....')
    end
    --- load all permissions
    for idx, permission in ipairs(permissions) do self.Permissions[idx] = permission end
end

function PermissionManager:createPermission(definition)
    if assert_arg(1, definition, 'table') then return false, 'permission definition must be a table' end
    if type(definition['id']) ~= 'string' then
        return false, 'permission has invalid or missing property: \'id\'<string>'
    elseif type(definition['description']) ~= 'string' then
        return false, 'permission has invalid or missing property: \'description\'<string>'
    elseif type(definition['default']) ~= 'boolean' then
        return false, 'permission has invalid or missing property: \'default\'<boolean>'
    end
    local permission = {id = definition['id'], description = definition['description'], default = definition['default']}
    InsertIntoTable(self.Permissions, permission)
    DataSource:SetValue('URBA.Permissions', self.Permissions)
end

function PermissionManager:getPermission(id)
    local permission = FindInTable(self.Permissions, 'id', id)
    if permission then return Permission(permission), 'Permission found' end
    return false, 'Unknown Permission'
end

function PermissionManager:deletePermission(id)
    local permission = self:getPermission(id)
    if permission then
        RemoveFromTable(self.Permissions, permission:Use())
        DataSource:SetValue("URBA.Permissions", self.Permissions)
        return true, 'Permission Deleted'
    end
    return false, "Unknown Permission"
end

RegisterModule('UniversalRBA.Systems.PermissionManager', PermissionManager)
return PermissionManager