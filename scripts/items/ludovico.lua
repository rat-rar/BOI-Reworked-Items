local mod = ISAACREBALANCED
local game = Game()

---@param player EntityPlayer
function mod:LudovicoTearPop(player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) and Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
            local tear = ent:ToTear()
            if tear and tear.TearFlags & TearFlags.TEAR_LUDOVICO and tear.SpawnerEntity then
                local tearPlayer = tear.SpawnerEntity:ToPlayer()
                if tearPlayer and tearPlayer.ControllerIndex == player.ControllerIndex then
                    tear:ClearTearFlags(TearFlags.TEAR_LUDOVICO | TearFlags.TEAR_HYDROBOUNCE)
                    tear.FallingAcceleration = 2
                    tear.FallingSpeed = 0
                    player:SetShootingCooldown(30)
                end
            end
        end

        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
            local laser = ent:ToLaser()
            if laser and laser.TearFlags & TearFlags.TEAR_LUDOVICO and laser.SpawnerEntity then
                local tearPlayer = laser.SpawnerEntity:ToPlayer()
                if tearPlayer and tearPlayer.ControllerIndex == player.ControllerIndex then
                    laser:Remove()
                    player:SetShootingCooldown(30)
                end
            end
        end

        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_KNIFE)) do
            local knife = ent:ToKnife()
            if knife and knife.TearFlags & TearFlags.TEAR_LUDOVICO and knife.SpawnerEntity then
                local tearPlayer = knife.SpawnerEntity:ToPlayer()
                if tearPlayer and tearPlayer.ControllerIndex == player.ControllerIndex then
                    knife:Remove()
                    player:SetShootingCooldown(30)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.LudovicoTearPop)