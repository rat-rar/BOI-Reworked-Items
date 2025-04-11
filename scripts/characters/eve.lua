local mod = ISAACREBALANCED

---@param player EntityPlayer
function mod:EveInitLevelStats(player)
    player:RemoveCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON)
end

mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, mod.EveInitLevelStats, PlayerType.PLAYER_EVE)

---@param player EntityPlayer
function mod:EvePeffectUpdate(player)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) then
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, 1)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.EvePeffectUpdate, PlayerType.PLAYER_EVE)

---@param player EntityPlayer
function mod:PreEveClicker(_, rng, player, flags, slot)
    if player:GetPlayerType() == PlayerType.PLAYER_EVE then
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, -1)
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.PreEveClicker, CollectibleType.COLLECTIBLE_CLICKER)