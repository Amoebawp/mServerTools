include('common')

local Authorization = (include('controllers/authorization'))()
local HTTPHandler = include('class/HTTPHandler')

local Handler = HTTPHandler('/')

Handler:addRoute('login', function(request)
    if request.method == 'GET' then
        local params = request.params
        local action = params.action
        if action == "login" then
            local LoggedIn, LoginResult, Token =
                Authorization:Login(request['params'].username,
                                    request['params'].password,
                                    request['params'].forcelogin)
            if LoggedIn then
                return {
                    202, {
                        user = request['params'].username,
                        logged_in = 'true',
                        reason = LoginResult,
                        token = Token
                    }
                }
            else
                return {
                    401, {
                        user = request['params'].username,
                        logged_in = 'false',
                        reason = LoginResult,
                        token = Token
                    }
                }
            end
        elseif action == "logout" then
            local LogoutOk, LogoutResult =
                Authorization:Logout(request['params'].username,
                                     request['params'].token)
            if LogoutOk then
                return {
                    202,
                    {
                        user = request['params'].username,
                        logged_out = 'true',
                        result = LogoutResult
                    }
                }
            else
                return {
                    401, {
                        user = request['params'].username,
                        logged_out = 'false',
                        reason = LogoutResult
                    }
                }
            end
        elseif action == "register" then
            local RegisterOk, RegisterResult =
                Authorization:AddUser(request['params'].username,
                                      request['params'].password,
                                      request['params'].email)
            if RegisterOk then
                return {
                    202, {
                        user = request['params'].username,
                        user_created = 'true',
                        result = RegisterResult
                    }
                }
            else
                return {
                    401, {
                        user = request['params'].username,
                        user_created = 'false',
                        reason = RegisterResult
                    }
                }
            end
        end
    elseif request.method == 'POST' then
        return HTTPCode(405, 'This route only Accepts GET requests')
    else
        return HTTPCode(400)
    end
end)

return Handler
