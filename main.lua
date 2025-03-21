ISAACREBALANCED = RegisterMod("Isaac Rebalanced", 1)
local mod = ISAACREBALANCED
mod.Version = "0.1.0"

include("scripts.savedata")(mod)

local scripts = {
    "helpers",
    "stats",

    "items.teleport",
    --"items.ludovico",

    "cards",
    "pills",

    "eid",
}

for _, script in ipairs(scripts) do
    include("scripts."..script)
end

local players = PlayerManager.GetPlayers()
if players then
    for _, player in pairs(players) do
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    end
end

local spoofedCollectibles = {
    CollectibleType.COLLECTIBLE_NUMBER_ONE,
}

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    player:BlockCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE)
end)

if Game() then
    for _, player in pairs(PlayerManager.GetPlayers()) do
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    end
end

print("Isaac Rebalanced "..mod.Version.." Initialized")