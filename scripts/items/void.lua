local mod = ISAACREBALANCED
Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_VOID).MaxCharges = 4

---@param item CollectibleType
---@param player EntityPlayer
---@param flags UseFlag
function mod:PreUseVoid(item, _, player, flags)
    if item == CollectibleType.COLLECTIBLE_VOID then
        player:GetData().BlockNecronomicon = true
        player:UseCard(Card.RUNE_BLACK, flags | UseFlag.USE_VOID)
        player:AnimateCollectible(CollectibleType.COLLECTIBLE_VOID, "UseItem")
        return true
    elseif item == CollectibleType.COLLECTIBLE_NECRONOMICON then
        local data = player:GetData()
        if data.BlockNecronomicon then
            data.BlockNecronomicon = false
            return true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.PreUseVoid)