---@class URBA.Player
local Player = Class('URBA.Player', {})

function Player:new(playerData)
    self.data = playerData
end

function Player:Use() return self.data end

function Player:Name() return self.data['name'] end

function Player:RoleId() return self.data['currentRoleId'] end

function Player:Steam64Id() return self.data['steamId'] end

RegisterModule('UniversalRBA.Classes.URBA_Player', Player)
return Player
