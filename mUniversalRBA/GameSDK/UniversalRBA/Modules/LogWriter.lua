local template = [[  [${level}:${prefix}] >> 
        ${content}"]]

local function createLogger(filepath)
    local log = {
        path = filepath,
        update = function(self, line)
            local file = io.open(self.path, 'a+')
            if file then
                file:write(line .. '\n')
                file:close()
                return true, 'updated'
            end
            return false, 'failed to update file: ', (self.path or 'invalid path')
        end,
        purge = function(self) os.remove(self.path) end,
    }
    return log
end

local function writer(logger, logtype, source, message)
    local line = string.expand(template, {level = logtype, prefix = source, content = message})
    return logger:update(os.date() .. '  >> ' .. line)
end

local LogWriter = Class('URBA.LogWriter', {})

function LogWriter:new(name, filepath)
    self.Name = name
    self.isDebug = false
    self.Logger = createLogger(filepath)
end

--- Writes a [Log] level entry to the log
function LogWriter:Log(message) return writer(self.Logger, 'LOG', self.Name, message) end

--- Writes a [Error] level entry to the log
function LogWriter:Err(message) return writer(self.Logger, 'ERROR', self.Name, message) end

--- Writes a [Warning] level entry to the log
function LogWriter:Warn(message) return writer(self.Logger, 'WARNING', self.Name, message) end
--- Writes a [Debug] level entry to the log
function LogWriter:Debug(message)
    if not self.isDebug then return end
    return writer(self.Logger, 'DEBUG', self.Name, message)
end

RegisterModule("UniversalRBA.Modules.LogWriter", LogWriter)
return LogWriter