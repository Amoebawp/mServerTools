--- Server Configuration
-- ────────────────────────────────────────────────────────────────────────────────
-- Globals
globals = {
  SITE = {sitename = "MisApiRelay",},
  AUTH_TOKENS = {}
}

--- Logging (will log to console if an empty string is given)
LogTo("")
--LogTo("./server.log")

--- Clear the URL prefixes for access permissions
ClearPermissions()
--AddAdminPrefix("/admin")
--AddUserPrefix("/user")

-- Output server configuration after parsing this file and commandline arguments
OnReady(function ()
  print(ServerInfo())
end)

-- Custom permission denied handler
DenyHandler(function ()
  content("text/html")
  print[[<!doctype html><html><head><title>Permission denied</title><link href='//fonts.googleapis.com/css?family=Lato:300' rel='stylesheet' type='text/css'></head><body style="background-color: #f0f0f0; color: #101010; font-family: 'Lato', sans-serif; font-weight: 300; margin: 4em; font-size: 2em;">]]
  print("<strong>HTTP "..method()..[[</strong> <font color="red">denied</font> for ]]..urlpath().." (based on the current permission settings).")
  print([[</body></html>]])
end)

-- Store global variables as Lua code in the database.
-- Any other Lua file may load them with: CodeLib():import("globals")
OnReady(function()
  -- Prepare a CodeLib object and clear the "globals" key
  codelib = CodeLib()
  -- Store the configuration strings as Lua code under the key "globals".
  local first = true
  for k, v in pairs(globals) do
    luaCode = k .. "=\"" .. v .. "\""
    if first then
      codelib:set("globals", luaCode)
      first = false
    else
      codelib:add("globals", luaCode)
    end
  end
  print(codelib:get("globals"))

--- We should allways ensure were using sha256
--SetPasswordAlgo('sha256')
  --SetCookieSecret("asdfasdf")
  --print("Cookie secret = " .. CookieSecret())
end)

ServerFile('../public/index.lua')