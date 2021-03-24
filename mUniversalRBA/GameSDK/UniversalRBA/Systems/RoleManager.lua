local LogWriter = require('UniversalRBA.Modules.LogWriter')
local Role = require('UniversalRBA.Classes.URBA_Role')

--- URBA PersistantStorage
local DataSource ---@type MisDB.DataStore

---@class URBA.RoleManager
local RoleManager = Class('URBA.RoleManager', {})

function RoleManager:new(source)
    -- Update our DataSource
    DataSource = source
    self.Logger = LogWriter('URBA:RoleManager', './URBA.log')
    self.Roles = {}
end

local gen_rolePermissions = function(default_perms, role_perms)
    local new_perms = {}
    for _, permission in ipairs(default_perms) do new_perms[permission.id] = permission.default end
    return merge(new_perms, role_perms)
end

function RoleManager:Init(default_roles, default_permissions)
    local roles = (DataSource:GetValue('URBA.Roles') or {})
    local initialised = (DataSource:GetValue('URBA.Roles_initialised') or false)
    --- Check and initialise default Roles
    if (not initialised) then
        self.Logger:Warn('  !!! First Run !!! - Initialising URBA Default Roles')
        for _, thisRole in ipairs(default_roles) do
            local role_perms = gen_rolePermissions(default_permissions, thisRole.Permissions)
            local new_role = {
                id = thisRole.ID,
                name = thisRole.Name,
                description = thisRole.Description,
                options = thisRole.Options,
                permissions = role_perms,
            }
            table.insert(roles, new_role)
        end
        self.Logger:Warn('Created Default Roles....')
        DataSource:SetValue('URBA.Roles', roles)
        DataSource:SetValue('URBA.Roles_initialised', true)
    else
        self.Logger:Log('Loading Roles....')
    end
    --- load all Roles
    for idx, role in ipairs(roles) do self.Roles[idx] = role end
end

---comment
---@param definition table `role definition table`
---@return boolean
---@return string
function RoleManager:createRole(definition)
    if assert_arg(1, definition, 'table') then return false, 'Role definition must be a table' end
    if type(definition['id']) ~= 'string' then
        return false, 'Role has invalid or missing property: \'id\'<string>'
    elseif type(definition['name']) ~= 'string' then
        return false, 'Role has invalid or missing property: \'name\'<string>'
    elseif type(definition['description']) ~= 'string' then
        return false, 'Role has invalid or missing property: \'description\'<string>'
    elseif type(definition['default']) ~= 'boolean' then
        return false, 'Role has invalid or missing property: \'default\'<boolean>'
    end
    local role = {
        id = definition['id'],
        name = definition['name'],
        description = definition['description'],
        options = definition['options'],
        permissions = definition['permissions'],
    }
    InsertIntoTable(self.Roles, role)
    DataSource:SetValue('URBA.Roles', self.Roles)
end

---Fetch a Role by given RoleId
---@param id number `roleid to fetch`
---@return URBA.Role|boolean
---@return string
function RoleManager:getRoleById(id)
    local role = FindInTable(self.Roles, 'id', id)
    if role then return Role(role), 'Role found' end
    return false, 'Unknown Role'
end

---Fetch a Role by given Role Name
---@param id number `roleid to fetch`
---@return URBA.Role|boolean
---@return string
function RoleManager:getRoleByName(name)
    local role = FindInTable(self.Roles, 'name', name)
    if role then return Role(role), 'Role found' end
    return false, 'Unknown Role'
end

---Delete a Role by given RoleId
---@param id number `roleid of Role to Delete`
---@return boolean
---@return string
function RoleManager:deleteRole(id)
    local role = self:getRole(id)
    if role then
        RemoveFromTable(self.Roles, role:Use())
        DataSource:SetValue('URBA.Roles', self.Roles)
        return true, 'Role Deleted'
    end
    return false, 'Unknown Role'
end

RegisterModule('UniversalRBA.Systems.RoleManager', RoleManager)
return RoleManager
