local mod = ISAACREBALANCED

---@param player EntityPlayer
function mod:SamsonInitLevelStats(player)
    player:AddCollectible(CollectibleType.COLLECTIBLE_BLOOD_RIGHTS)
end

mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, mod.SamsonInitLevelStats, PlayerType.PLAYER_SAMSON)