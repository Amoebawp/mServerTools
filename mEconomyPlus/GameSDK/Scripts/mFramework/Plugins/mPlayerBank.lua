local mPlayerBankObject
if mObject then
	mPlayerBankObject = mObject()
else
	mPlayerBankObject = require("Object")
end
local mPlayerBank = mPlayerBankObject:extend()
mPlayerBank.__PLUGININFO = {Plugin = "mPlayerBank", Version = "01a"}
mPlayerBank.Properties = {Rate = 1}
mPlayerBank.PlayerDataSource = mFramework.PersistantStorage:Collection("PlayerBank")
function mPlayerBank:new(player)
    if not player then return nil, "no player provided" end
    if player and player.player then
        self.player = player
        self.SteamId = player.player:GetSteam64Id()
        self.PlayerData = self.PlayerDataSource:GetPage(self.SteamId)
        if (not self.PlayerData) or (not self.PlayerData.AccountBalance) then
            self.PlayerData = {AccountBalance = 0}
            self.PlayerDataSource:SetPage(player.player:GetSteam64Id())
        end
    end
    self.GetAccountBalance = bind_getter(self.PlayerData, "AccountBalance")
    self.SetAccountBalance = bind_setter(self.PlayerData, "AccountBalance")
end

function mPlayerBank:Sync()
    self.PlayerDataSource:SetPage(self.SteamId, self.PlayerData)
end

function mPlayerBank:Rate(newRate)
    if newRate then self.Properties.Rate = newRate end
    return self.Properties.Rate
end

function mPlayerBank:Transaction(transaction)
    if (not type(transaction) == "table") then
        return nil, "invalid transaction"
    elseif not transaction.type == ("credit" or "debit") then
        return nil, "invalid transaction type"
    elseif (not type(transaction.value) == "number") or (transaction.value == 0) then
        return nil, "invalid transaction value"
    end

    local headermsg = "[mPlayerBank] => Transaction"
    local trxWrap = " >> Type:%s" .. "\n >> Value:%s"
    if transaction.type == "credit" then
        Log(headermsg .. "\nPlayer:" .. self.player:GetName() .. " [" ..
                self.SteamId .. "]")
        local AccountBalance = self.GetAccountBalance()
        Log(trxWrap, transaction.type, tostring(transaction.value))
        local newBalance = AccountBalance + transaction.value
        local ret = self.SetAccountBalance(newBalance)
        if ret then
            Log(" -> New Balance: " .. tostring(self:Balance()))
            self:Sync()
            return ret
        end
    elseif transaction.type == "debit" then
        Log(headermsg .. "\nPlayer:" .. self.player:GetName() .. " [" ..
                self.SteamId .. "]")
        local AccountBalance = self.GetAccountBalance()
        Log(trxWrap, transaction.type, tostring(transaction.value))
        local newBalance = AccountBalance - transaction.value
        if newBalance <= 0 then
            return nil, "Insufficiant Funds - No Transaction Performed"
        end
        local ret = self.SetAccountBalance(newBalance)
        if ret then
            Log(" -> New Balance: " .. tostring(self:Balance()))
            self:Sync()
            return ret
        end
    end
    return nil, "Unknown Error - No Transaction Performed"
end

function mPlayerBank:Balance() return self.GetAccountBalance() end

mFramework.PlayerBank = mPlayerBank
