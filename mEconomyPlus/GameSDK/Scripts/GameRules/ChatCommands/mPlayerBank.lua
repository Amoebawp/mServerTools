local PreformattedResponse = {
    ["Balance"] = " Account Balance for:%s" .. "\n - Available:%s amBits {1 amBit = %s AmcoinLedger}"
}

local function RespondBalance(bank, player)
    if (player.player) and (bank.Balance) then
        return g_gameRules.game:SendTextMessage(
            4,
            player.id,
            string.format(
                PreformattedResponse["Balance"],
                player.player:GetSteam64Id(),
                tostring(bank:Balance()),
                tostring(bank:Rate())
            )
        )
    end
end

local function HandleWithdraw(bank, player, withdrawAmount)
    if (player.player) and (bank.Balance) then
        local balance = bank:Balance()
        if (balance - withdrawAmount) >= 0 then
            local SpawnResult, ItemsRemain, SpawnError =
                mSpawnTools:SpawnAsStacks(player.id, "AmcoinLedger", withdrawAmount)
            if SpawnResult ~= nil and (ItemsRemain == 0) then
                local TransactionSuccess, TransactionResult =
                    bank:Transaction {
                    type = "debit",
                    value = withdrawAmount
                }
                if not TransactionSuccess then
                    return nil, TransactionResult or "Something Went Wrong Bank:Transaction fail"
                end
                local msg = tostring("You Have withdrawn %s Amcoins"):format(withdrawAmount)
                g_gameRules.game:SendTextMessage(4, player.id, msg)
                return RespondBalance(bank, player)
            else
                return nil, SpawnError
            end
        else
            return g_gameRules.game:SendTextMessage(
                4,
                player.id,
                string.format("Could not Withdraw %s > Insufficiant Balance!", tostring(withdrawAmount))
            )
        end
    end
end

ChatCommands["!mBank"] = function(playerId, command)
    local NewPlayerBank = mFramework.PlayerBank
    local player = System.GetEntity(playerId)
    local cmd_arg = cmdSplit(command, " ")
    local steamId = player.player:GetSteam64Id()
    local PlayerBank = NewPlayerBank(player)
    if cmd_arg[1] == "balance" then
        return RespondBalance(PlayerBank, player)
    elseif cmd_arg[1] == "withdraw" then
        if type(cmd_arg[2]) == "string" then
            local withdrawAmount = tonumber(cmd_arg[2])
            return HandleWithdraw(PlayerBank, player, withdrawAmount)
        end
    end
end
