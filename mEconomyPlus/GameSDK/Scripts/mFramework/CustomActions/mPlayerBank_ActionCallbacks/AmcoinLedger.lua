Log("   [mBank] -> Registering AmcoinLedger Callbacks")

if CryAction.IsDedicatedServer() then
    RegisterCallback(
        Item,
        "OnActionPerformed",
        function(itemId, playerId, action)
            if action ~= "Deposit to mBank" then
                return
            else
                local player = System.GetEntity(playerId)
                local thisLedger = System.GetEntity(itemId)
                if thisLedger.class ~= "AmcoinLedger" then
                    return
                end
                local thisLedgerStack = thisLedger.item:GetStackCount()
                local PlayerBank = mFramework.PlayerBank(player)
                if PlayerBank then
                    local f_stat, e_msg =
                        PlayerBank:Transaction {
                        type = "credit",
                        value = (thisLedgerStack * mFramework.PlayerBank:Rate())
                    }
                    if f_stat then
                        System.RemoveEntity(itemId)
                    end
                else
                    Log(
                        "[mBank] -> Failed Getting PlayerBank for Player: %s [%s]",
                        player:GetName(),
                        player.player:GetSteam64Id()
                    )
                end
            end
        end
    )
end
