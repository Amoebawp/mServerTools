local HTTPHandler = include('class/HTTPHandler')

local Handler = HTTPHandler('/test')

Handler:addRoute(
    '/hello', function(request)
        if request.method == 'GET' then
            local message = 'Hello '
            local name = request.params['name']
            if not (name == nil or name == '') then
                message = message .. name
            else
                message = message .. 'World'
            end
            return {200, message}
        elseif request.method == 'POST' then
            return HTTPCode(405, 'This route only Accepts GET requests')
        else
            return HTTPCode(400)
        end
    end
)

return Handler
