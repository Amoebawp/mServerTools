---@class URBA.Role
---* Describes a Server Role
local Role = Class('URBA.Role', {})

---? internal function used to validate the options table passed to URBA.Role()
local function validateOptions(options)
    local opts = {}
    if options then
        if (options['BUILT_IN'] == true) then
            opts.BUILT_IN = true

        elseif (options['IS_ADMIN'] == true) then
            opts.IS_ADMIN = true
        end
    end
    return opts
end

function Role:new(definition)
    if not definition then return nil end
    if (not definition.id) or (type(definition.id) ~= 'number') then
        return nil, 'Invalid Role id (must be a number)'
    elseif (not definition.name) or (type(definition.name) ~= 'string') then
        return nil, 'Invalid Role name (must be a string)'
    elseif (not definition.description) or (type(definition.description) ~= 'string') then
        return nil, 'Invalid Role description (must be a string)'
    end
    --- URBA.Role ID
    ---@type number
    self.id = definition.id
    --- URBA.Role Properties
    ---@type table
    self.Properties = {
        --- Role Name
        ---@type string
        Name = definition.name,
        --- Role Description
        ---@type string
        Description = definition.description,
        --- Contains Role Options
        ---@type table
        Options = validateOptions(definition['options']),
        --- Role Permissions
        ---@type table<string,string|number|boolean>
        Permissions = {},
    }

    --- create Permissions
    if type(definition.permissions) == 'table' then
        for key, value in pairs(definition.permissions) do
            self.Properties.Permissions[key] = value
        end
    end

    -- Bind Getters

    --- Returns this Roles Name
    ---@return string Name
    self.GetName = bind_getter(self.Properties, 'Name')
    --- Returns this Roles Description
    ---@return string Description
    self.GetDescription = bind_getter(self.Properties, 'Description')
    --- Returns this Roles Permission Value named `key`
    ---@param key string
    ---@return string|number|boolean value
    self.GetPermission = setter(self.Properties['Permissions'])
    --- Returns this Roles Options
    ---@return table Options
    self.GetOption = getter(self.Properties['Options'])

    -- Bind Setters

    --- Sets this Roles Name
    ---@param name string
    self.SetName = bind_setter(self.Properties, 'Name')
    --- Sets this Roles Description
    ---@param Description string
    self.SetDescription = bind_setter(self.Properties, 'Description')
    --- Sets this Roles Permissions
    ---@param key string
    ---@param value string|number|boolean
    self.SetPermission = setter(self.Properties['Permissions'])
    --- Sets this Roles Options
    ---@param key string
    ---@param value string|number|boolean|table
    self.SetOption = setter(self.Properties['Options'])
end

function Role:Use()
    return self.Properties
end

RegisterModule('UniversalRBA.Classses.URBA_Role', Role)
return Role
