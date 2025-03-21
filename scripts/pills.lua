local mod = ISAACREBALANCED
local game = Game()

local itemConfig = Isaac.GetItemConfig()
local ipecacConfig = itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_IPECAC)
itemConfig:GetPillEffect(PillEffect.PILLEFFECT_HORF).MimicCharge = 3

---@param player EntityPlayer
---@param item CollectibleType
local function GetInnateCollectibleNum(player, item)
    return player:GetCollectibleNum(item) - player:GetCollectibleNum(item, false, true)
end

---@param player EntityPlayer
---@param useflag UseFlag
function mod:UseHorfIpecac(_, pillColor, player, useflag)
    if pillColor & PillColor.PILL_GIANT_FLAG > 0 then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_IPECAC, true, 2)
        mod:TrySayAnnouncerLine(SoundEffect.SOUND_MEGA_HORF, useflag)
    else
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_IPECAC, true, 1)
        mod:TrySayAnnouncerLine(SoundEffect.SOUND_HORF, useflag)
    end

    player:AnimatePill(pillColor, "UseItem")
    game:GetHUD():ShowItemText("Horf!")
    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_PILL, mod.UseHorfIpecac, PillEffect.PILLEFFECT_HORF)

---@param player EntityPlayer
function mod:HorfPeffectUpdate(player)
    local effects = player:GetEffects()
    local count = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_IPECAC) - GetInnateCollectibleNum(player, CollectibleType.COLLECTIBLE_IPECAC)
    if count > 0 then
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_IPECAC, count)
    elseif count < 0 then
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_IPECAC, count)
        player:RemoveCostume(ipecacConfig)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.HorfPeffectUpdate)

---@param tear EntityTear
function mod:HorfFireTear(tear)
    if tear.SpawnerEntity and tear.SpawnerType == EntityType.ENTITY_PLAYER then
        local player = tear.SpawnerEntity:ToPlayer()
        if player and player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IPECAC) >= 2 then
            tear:GetData().DoubleIpecac = true
            tear:ClearTearFlags(TearFlags.TEAR_EXPLOSIVE)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.HorfFireTear)

---@param tear EntityTear
function mod:HorfTearSpawn(tear)
    if tear.SpawnerEntity and tear.SpawnerType == EntityType.ENTITY_PLAYER then
        local player = tear.SpawnerEntity:ToPlayer()
        if player and player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IPECAC) >= 2 then
            tear:GetData().DoubleIpecac = true
            tear:ClearTearFlags(TearFlags.TEAR_EXPLOSIVE)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, mod.HorfTearSpawn)

---@param tear EntityTear
function mod:HorfTearEffect(tear)
    if tear.SpawnerEntity and tear.SpawnerType == EntityType.ENTITY_PLAYER then
        local player = tear.SpawnerEntity:ToPlayer()
        local data = tear:GetData()
        if player and data.DoubleIpecac then
            game:BombExplosionEffects(tear.Position, tear.CollisionDamage, TearFlags.TEAR_POISON, Color.TearIpecac)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, mod.HorfTearEffect)