--
-- ────────────────────────────────────────────────────────────── I ──────────
--   :::::: M A I N   S E R V E R : :  :   :    :     :        :          :
-- ────────────────────────────────────────────────────────────────────────
dofile('common.lua')
-- NOTE: use include() not require() algernon runs each file in its own env.
-- include accounts for this and makes use of relative paths

handle(
    '/api/', function()
        local apiHandler = include('handlers/apiHandler')
        return apiHandler:Handle()
    end
)
handle(
    '/test/', function()
        local testHandler = include('handlers/testHandler')
        return testHandler:Handle()
    end
)
handle(
    '/', function()
        local pageHandler = include('handlers/pageHandler')
        return pageHandler:Handle()
    end
)
