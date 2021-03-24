---@class URBA.Permission
local Permission = Class('URBA.Permission', {})

function Permission:new(permissionkey, description, default)
    local data = {id = permissionkey, description = description, default = default}
    self.data = readOnly(data)
    return self.data
end

function Permission:Use() return self.data end

function Permission:Id() return self.data['id'] end
function Permission:Name() return self.data['name'] end

function Permission:Description() return self.data['description'] end

function Permission:Default() return self.data['default'] end

RegisterModule('UniversalRBA.Classes.URBA_Permission', Permission)
return Permission
