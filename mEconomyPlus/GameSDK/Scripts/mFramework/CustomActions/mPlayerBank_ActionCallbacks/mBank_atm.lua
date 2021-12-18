local mPlayerBank = mFramework.PlayerBank
Log("   [mBank] -> Registering mBank_atm Callbacks")
--
-- ────────────────────────────────────────────────────────── PLAYERRESPONSES ─────
--

--Respond to the Player with a Preformatted Error Message
local function RespondError(msg, playerId)
    if msg and playerId then
        local PreformattedResponse = "{mBank}   ERROR:" .. "\n -> %s"
        g_gameRules.game:SendTextMessage(4, playerId, string.format(PreformattedResponse, msg))
    end
end

--Respond to the Player with a Preformatted Balance Message
local function RespondBalance(PlayerBank, player)
    local PreformattedResponse =
        "{mBank} Balance" .. "\n -> Account: %s" .. "\n -> Available: %s amCoins   {1 amCoin = %s AmcoinLedger}"
    g_gameRules.game:SendTextMessage(
        4,
        player.id,
        string.format(
            PreformattedResponse,
            player.player:GetSteam64Id(),
            tostring(PlayerBank:Balance()),
            tostring(PlayerBank:Rate())
        )
    )
end

--Respond to the Player with a Preformatted Message of How many AmcoinLedger had been Converted
local function RespondATMConverted(PlayerBank, player, converted, convertedTotal)
    local PreformattedResponse = "{mBank} Area Conversion" .. "\n Converted: %s AmcoinLedgers - Value: %s"
    g_gameRules.game:SendTextMessage(
        4,
        player.id,
        string.format(PreformattedResponse, tostring(converted), tostring(convertedTotal))
    )
end
-- ────────────────────────────────────────────────────────────────────────────────

local atmRange = 5
local actionTag = "{mBank} "

--
-- ─── HANDLERS ───────────────────────────────────────────────────────────────────
--

function HandleWithdrawls(PlayerBank, player)
    return
end

-- ────────────────────────────────────────────────────────────────────────────────

--
-- ────────────────────────────────────────────────────────────────── ACTIONS ─────
--

local mBankActions = {
    ["Account Balance"] = function(mATM, PlayerBank, player)
        return RespondBalance(PlayerBank, player)
    end,
    ["Withdraw"] = function(mATM, PlayerBank, player)
        return HandleWithdrawls(PlayerBank, player)
    end,
    ["Area Deposit"] = function(mATM, PlayerBank, player)
        local ATMLocation = mATM:GetPos()
        if ATMLocation then
            local AreaItems = mF_FindItemsAtPos(ATMLocation, atmRange, "AmcoinLedger")
            if AreaItems then
                local AmcoinLedgers = AreaItems:Items()
                if AmcoinLedgers then
                    local foundConverted = 0
                    local foundTotal = 0
                    for idx, thisLedger in ipairs(AmcoinLedgers) do
                        local ledger = System.GetEntity(thisLedger.itemid)
                        if ledger then
                            local ledgerValue = ledger.item:GetStackCount()
                            if ledgerValue then
                                System.RemoveEntity(thisLedger.itemid)
                                foundConverted = (foundConverted + 1)
                                foundTotal = (foundTotal + ledgerValue)
                                PlayerBank:Transaction {
                                    type = "credit",
                                    value = (ledgerValue * (mFramework.PlayerBank:Rate() or 1))
                                }
                            end
                        end
                    end
                    return RespondATMConverted(PlayerBank, player, foundConverted, foundTotal)
                end
            else
                local err = string.format("No AmcoinLedgers in Range [%s m]", tostring(atmRange))
                return RespondError(err, player.id)
            end
        else
            return RespondError("Failed Fetching WorldPos", player.id)
        end
    end
}
-- ────────────────────────────────────────────────────────────────────────────────

--
-- ─── HANDLE SERVERLISTENER CALLBACK ─────────────────────────────────────────────
--

if CryAction.IsDedicatedServer() then
    RegisterCallback(
        Item,
        "OnActionPerformed",
        function(itemId, playerId, action)
            if not (tostring(action):find(actionTag) == 1) then
                return
            else
                action = string.gsub(action, actionTag, "")
                local mATM = System.GetEntity(itemId)
                if mATM and (mATM.class == "mBank_atm_packed") then
                    local player = System.GetEntity(playerId)
                    local PlayerBank = mPlayerBank(player)
                    if PlayerBank then
                        local Handler = mBankActions[action]
                        if type(Handler) == "function" then
                            return Handler(mATM, PlayerBank, player)
                        else
                            Log("No Handler found for mATM Action: %s", action)
                            return
                        end
                    else
                        Log(
                            "Failed to Init PlayerBank for Player: %s [%s]",
                            player:GetName(),
                            player.player:GetSteam64Id()
                        )
                        return
                    end
                else
                    Log("Entity isnt an mATM? class: %s", tostring(mATM.class or "Not Found"))
                    return
                end
            end
        end
    )
end

--
-- ────────────────────────────────────────────────────────────────────── END ─────
--
