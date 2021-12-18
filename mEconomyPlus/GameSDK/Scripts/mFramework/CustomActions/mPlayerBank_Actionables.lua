Log("===mPlayerBank starting===")
--
-- ─── CUSTOMIZED AmcoinLedger ────────────────────────────────────────────────────
--
local AmcoinLedger_actions = {
    ["Deposit to mBank"] = function(self, player, action)
        --handled serverside
        return
    end
}
local AmcoinLedgerCustomized, AmcoinLedger_reason = mCustomizeActions("AmcoinLedger", AmcoinLedger_actions, true)
if AmcoinLedgerCustomized then
    Script.ReloadScript("Scripts/mFramework/CustomActions/mPlayerBank_ActionCallbacks/AmcoinLedger.lua")
else
    Log("   - AmcoinLedger Customize Fail > %s", AmcoinLedger_reason)
end
-- ────────────────────────────────────────────────────────────────────────────────
--
-- ─── MBANK ATM ──────────────────────────────────────────────────────────────────
--
local mBank_atm_packed_actions = {
    ["{mBank} Account Balance"] = function(self, player, action)
        --handled serverside
        return
    end,
    ["{mBank} Area Deposit"] = function(self, player, action)
        --handled serverside
        return
    end
}
local mBank_atm_packedCustomized, mBank_atm_packed_reason =
    mCustomizeActions("mBank_atm_packed", mBank_atm_packed_actions, true)
if mBank_atm_packedCustomized then
    Script.ReloadScript("Scripts/mFramework/CustomActions/mPlayerBank_ActionCallbacks/mBank_atm.lua")
else
    Log("   - mBank_atm_packed Customize Fail > %s", mBank_atm_packed_reason)
end
-- ────────────────────────────────────────────────────────────────────────────────
