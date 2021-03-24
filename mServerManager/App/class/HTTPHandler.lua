-- template http status codes.
local HTTPCODE = {
    [100] = 'CONTINUE',
    [200] = 'OK',
    [201] = 'CREATED',
    [202] = 'ACCEPTED',
    [203] = 'UNKNOWN MESSAGE', -- ? Fallback
    [302] = 'FOUND',
    [400] = 'BAD REQUEST',
    [401] = 'UNAUTHORISED',
    [403] = 'FORBIDDEN',
    [404] = 'NOT FOUND',
    [405] = 'METHOD NOT ALLOWED', -- ? Fallback: you should pass a message with this defining allowed methods GET|POST|?
    [500] = 'INTERNAL SERVER ERROR', -- ! Internal DONT USE THIS
}

---* pack http status and result into to json string
---@param code number
---@param data string|table
function HTTPCode(code, data)
    local response
    local status
    -- check its a valid code
    local httpcode = HTTPCODE[code]
    -- pack and return response
    if httpcode then return {status = code .. ' ' .. httpcode, result = (data or {})} end
end

local HTTPHandler = Class {Routes = {}}

function HTTPHandler:new(baseurl)
    self.base_url = (baseurl or '/')
    self.Routes = {}
end

---* Route Builder, creates a new route Handler from a url path and function.
---| the handler function you provide should return a single response table,
---| {[1] = number:http_status,[2] = any:result}.
---| set requreAuth true protect this endpoint with a basic apiKey (configured in the config)
function HTTPHandler:addRoute(route, handler, requireAuth)
    if not self.Routes[route] then
        self.Routes[route] = function(request, ...)
            if requireAuth then if not hasApiAuth(request) then return HTTPCode(401) end end
            return handler(request, ...)
        end
    end
end

--- Main Handler
---| handles the current request
function HTTPHandler:Handle()
    local httpcode -- returned http status
    local response -- response from Handler

    -- >> fetch RequestData
    local request = {
        route = urlpath(),
        method = method(),
        headers = headers(),
        params = urldata(),
        body = body(),
        formdata = formdata(),
        endpoint = string.gsub(urlpath(), self.base_url, ''),
    }

    -- >> try to find a valid Handler.
    -- use endpoint, route includes basepath
    local Handler = self.Routes[request.endpoint]
    if Handler then
        local result = Handler(request)

        if result then
            httpcode = (result[1] or 200)
            response = HTTPCode(httpcode, result[2])
        else
            httpcode = 202
            response = HTTPCode(httpcode, 'No Response')
        end
    else
        httpcode = 404
        response = HTTPCode(404, request.route)
    end
    response.route = request.route
    status(httpcode)
    return print(JSON(response))
end

return HTTPHandler
