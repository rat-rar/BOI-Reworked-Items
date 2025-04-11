local mod = ISAACREBALANCED
local game = Game()

---@param player EntityPlayer
function mod:ApollyonSpawn(player)
    local rng = RNG()
    rng:SetSeed(game:GetSeeds():GetStartSeed() + player:GetPlayerIndex())

    local trinket = rng:RandomInt(TrinketType.TRINKET_LOCUST_OF_WRATH, TrinketType.TRINKET_LOCUST_OF_CONQUEST)
    --player:AddTrinket(trinket)

    player:RemoveCollectible(CollectibleType.COLLECTIBLE_VOID)
end
mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, mod.ApollyonSpawn, PlayerType.PLAYER_APOLLYON)

---@param player EntityPlayer
function mod:ApollyonUpdate(player)
    local data = player:GetData()
    local room = game:GetRoom()
    data.ApollyonCounter = data.ApollyonCounter or 0

    local flyCount = 0
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 100)) do
        local fly = ent:ToFamiliar()
        if fly and fly.Parent == player then
            flyCount = flyCount + 1
        end
    end

    if not room:IsClear() and player:GetShootingJoystick():Length() > 0 and flyCount < 3 then
        data.ApollyonCounter = data.ApollyonCounter + 1
        if data.ApollyonCounter == 60 then
            local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 100, player.Position, Vector.Zero, player)
            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            data.ApollyonCounter = 0
        end
    else
        data.ApollyonCounter = 0
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.ApollyonUpdate, PlayerType.PLAYER_APOLLYON)