local LogWriter = require('UniversalRBA.Modules.LogWriter')
local Player = require('UniversalRBA.Classes.URBA_PLayer')
local RoleManager = require 'UniversalRBA.Systems.RoleManager'

--- URBA PersistantStorage
local DataSource ---@type MisDB.DataStore

---@class URBA.PlayerManager
local PlayerManager = Class('URBA.PlayerManager', {})

function PlayerManager:new(source)
    -- Update our DataSource
    DataSource = source
    self.Logger = LogWriter('URBA:PlayerManager', './URBA.log')
    self.Players = {}
    self.DataSync = function()
        DataSource:SetValue('URBA.Players', self.Players)
        self.Players = DataSource:GetValue('URBA.Players')
    end
end

function PlayerManager:Init()
    local Players = (DataSource:GetValue('URBA.Players') or {})
    self.Logger:Log('Loading Players....')
    --- load all Players
    for idx, player in ipairs(Players) do self.Players[idx] = player end
end

---comment
---@param definition table `Player definition table`
---@return boolean
---@return string
function PlayerManager:createPlayer(player)
    if assert_arg(1, player, 'table') then return false, 'Player be a table' end
    if (not type(player['player']) == 'table') then return false, 'not a player' end
    local thisplayer = {id = UUID(), steamId = player.player:GetSteam64Id(), currentRoleId = 0}
    local playerExist = FindInTable(self.Players, 'steamId', thisplayer.steamId)
    if playerExist then return false, 'player Exists' end
    InsertIntoTable(self.Players, thisplayer)
    self:DataSync()
    if IsInsideTable(self.Players, thisplayer) then return true, 'player added' end
end

--- fetch an URBAPlayer instance for the given URBAPlayer GUID
---@param playerGUID string `URBAPlayer GUID of player to get`
---@return URBA.Player|boolean
---@return string
function PlayerManager:getPlayerByGUID(playerGUID)
    if assert_arg(1, playerGUID, 'string') then
        return false, 'must pass a valid player GUID string'
    end
    local thisplayer = FindInTable(self.Players, 'id', playerGUID)
    if Player then return Player(thisplayer), 'Player found' end
    return false, 'Unknown Player'
end

---Delete a Player by given PlayerId
---@param id number `Playerid of Player to Delete`
---@return boolean
---@return string
function PlayerManager:deletePlayer(playerGUID)
    local player = self:getPlayerByGUID(playerGUID)
    if player then
        local playerData = player:Use()
        RemoveFromTable(self.Players, playerData)
        self.DataSync()
        if (not IsInsideTable(self.Players, playerData)) then
            return true, 'Player Deleted'
        else
            return false, 'failed removing playerdata'
        end
    end
    return false, 'Unknown Player'
end

--- fetch an URBAPlayer instance for the given player entity
---@param player entity|table `Player entity to get URBAPlayer for`
---@return URBA.Player|boolean
---@return string
function PlayerManager:GetPlayer(player)
    if assert_arg(1, player, 'table') then return false, 'player must be a table' end
    if (not type(player['player']) == 'table') then return false, 'not a player' end
    local thisplayer = FindInTable(self.Players, 'steamId', player.player:GetSteam64Id())
    if Player then return Player(thisplayer), 'Player found' end
    return false, 'Unknown Player'
end

function PlayerManager:GetPlayerRole(player)
    if assert_arg(1, player, 'table') then return false, 'player must be a table' end
    if (not type(player['player']) == 'table') then return false, 'not a player' end

    local thisplayer = FindInTable(self.Players, 'steamId', player.player:GetSteam64Id())
    if (not thisplayer) then return false, 'Unknown Player' end
    if (not thisplayer.currentRoleId) then return false, 'Player has no Role' end
    local player_role = RoleManager:getRoleById(thisplayer.currentRoleId)
end

function PlayerManager:SetPlayerRole(player, target_role)
    if assert_arg(1, player, 'table') then return false, 'player must be a table' end
    if (not type(player['player']) == 'table') then return false, 'not a player' end

    local thisplayer = FindInTable(self.Players, 'steamId', player.player:GetSteam64Id())
    local current_role = self:GetPlayerRole(player) ---@type URBA.Role
    local new_role
    if current_role then
        local currentRoleId = current_role.id
        if type(target_role) == 'string' then
            -- we got a role name
            if (current_role.GetName() ~= target_role) then
                -- Role Name doesnt match, Update role
                new_role = RoleManager:getRoleByName(target_role)
            end
        elseif type(target_role) == 'number' then
            -- we got role Id
            if not (current_role.id ~= target_role) then
                -- Role Id doesnt match, Update role
                new_role = RoleManager:getRoleById(target_role)
            end
        end
        if new_role and new_role.id then
            thisplayer.currentRoleId = new_role.id
        else
            thisplayer.currentRoleId = currentRoleId
            self.DataSync()
            if self:GetPlayerRole(player) == new_role then
                return true, 'role updated for player'
            else
                return false, 'failed to update role for player'
            end
        end
        return false, 'unknown error'
    end
    return false, 'invalid target_role'
end

RegisterModule('UniversalRBA.Systems.PlayerManager', PlayerManager)
return PlayerManager
