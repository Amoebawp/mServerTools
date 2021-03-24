local MisDB = include('modules/MisDB')
local APP_DB = MisDB("./data/persistantStorage")
local UserData = APP_DB:Collection("UserData/")

local TokenManager = {}
function TokenManager:AddToken(username)
    local user_data = (UserData:GetPage(username) or {})
    if user_data then
        if user_data.token then
            return false, "user allready has active authtoken"
        end
        user_data.token = UUID()
        UserData:SetPage(username, user_data)
        return true, "token added"
    end
end
function TokenManager:RemoveToken(username, token)
    local user_data = UserData:GetPage(username)
    if user_data then
        if user_data.token then
            if not (user_data.token == token) then
                return false, "incorrect token"
            end
            user_data.token = nil
            UserData:SetPage(username, user_data)
            return true, "token cleared"
        end
    end
    return false, "user has no active authtoken"
end
function TokenManager:Validate(username, token)
    local user_data = UserData:GetPage(username)
    if user_data then
        if user_data.token then
            if not (user_data.token == token) then
                return false, "invalid token"
            end
            return true, "valid token"
        end
    end
    return false, "user has no active authtoken"
end

local Auth = Class {}
---* Add a new User
function Auth:AddUser(username, password, email)
    if HasUser(username) then return false, 'username unavailable' end
    AddUser(username, password, email)
    if HasUser(username) then
        return true, "User Created"
    else
        return nil, 'Failed to Create User: ' .. username
    end
end

function Auth:RemoveUser(username)
    --- check user doesnt allready exist
    if not HasUser(username) then return false, 'user not found' end
    -- remove user
    RemoveUser(username)
    -- validate
    if HasUser(username) then
        return nil, 'failed to remove user: ' .. username
    else
        local user_data = UserData:GetPage(username)
        if user_data then
            if user_data.token then
                TokenManager:RemoveToken(username, user_data.token)
            end
        end
        return true
    end
end

function Auth:Login(username, password, forcedLogin)
    if not HasUser(username) then return false, "unknown user" end
    if CorrectPassword(username, password) then
        if IsLoggedIn(username) then
            if not (forcedLogin == "true") then
                return nil, 'user allready logged in'
            else
                local user_data = UserData:GetPage(username)
                if user_data then
                    if user_data.token then
                        TokenManager:RemoveToken(username, user_data.token)
                    end
                end
            end
            Logout(username)
        end
    end
    Login(username)
    if IsLoggedIn(username) then
        TokenManager:AddToken(username)
        local user_data = UserData:GetPage(username)
        if user_data then
            return true, username .. ' logged in', user_data.token
        else
            return nil, 'failed to login'
        end
    else
        return false, 'invalid user details'
    end
end

function Auth:Logout(username, token)
    if IsLoggedIn(username) then
        if TokenManager:Validate(username, token) then
            Logout(username)
            if IsLoggedIn(username) then
                return false, 'failed to logout'
            else
                TokenManager:RemoveToken(username, token)
                return true, username .. ' logged out'
            end
        else
            return false, 'invalid username or token'
        end
    else
        return nil, 'user allready logged out'
    end
end

function Auth:GetUsers() end

function Auth:GetUser() end

return Auth
