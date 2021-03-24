include('common')

local Authorization = (include('controllers/authorization'))()
local HTTPHandler = include('class/HTTPHandler')

local Handler = HTTPHandler('/api')

Handler:addRoute(
    '/servers', function(request)
        if request.method == 'GET' then
            local params = request.params
            local action = params.action
            if not action then return end
            local ServerList = List('mAr_ServerList')
            ---? List all Servers
            if action == 'list' then
                local servers = ServerList:getall()
                return {200, JSON(servers)}
                ---? Query for a Specific Server
            elseif action == 'query' then
                if params.id then
                    local foundServer = servers:findById(params.id)
                    if foundServer then
                        -- return found server
                        return {200, JSON(foundServer)}
                    else
                        -- nothing found
                        return {403, 'server not found'}
                    end
                end
                return {203, 'invalid query'}
            else
                ---? No action Requested
                return {203, 'No Query'}
            end
        elseif request.method == 'POST' then
            return HTTPCode(405, 'This route only Accepts GET requests')
        else
            return HTTPCode(400)
        end
    end
)

return Handler
