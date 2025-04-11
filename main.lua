ISAACREBALANCED = RegisterMod("Isaac Rebalanced", 1)
local mod = ISAACREBALANCED
local game = Game()
mod.Version = "0.1.0"

include("scripts.savedata")(mod)

local scripts = {
    "helpers",
    "stats",

    "items.teleport",
    --"items.ludovico",
    --"items.void",

    --"characters.apollyon",
    "characters.eve",

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


local StopVoidPortal = false

mod:AddCallback(ModCallbacks.MC_PRE_MEGA_SATAN_ENDING, function()
    StopVoidPortal = true
    return true
end)

mod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_SPAWN, function(_, _, _, varData)
    if varData == 1 and StopVoidPortal then
        StopVoidPortal = false
        return false
    end
end, GridEntityType.GRID_TRAPDOOR)

if Game() then
    for _, player in pairs(PlayerManager.GetPlayers()) do
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    local room = Game():GetRoom()
    if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_LIBRARY then
        for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            pickup:ToPickup().OptionsPickupIndex = 1
        end
    end    
end)

local function OnRender()
    local room = Game():GetRoom()
    local descriptor = Game():GetLevel():GetCurrentRoomDesc()
    if descriptor.SurpriseMiniboss and descriptor.Data.Type == RoomType.ROOM_SECRET then
        for i = 0, DoorSlot.NUM_DOOR_SLOTS do
            local door = room:GetDoor(i)
            if door ~= nil and door:GetVariant() == DoorVariant.DOOR_LOCKED_BARRED then
                door:SetVariant(DoorVariant.DOOR_LOCKED_DOUBLE)
                door:TryUnlock(Isaac.GetPlayer(0), true)
                SFXManager():Stop(SoundEffect.SOUND_UNLOCK00)
                door:SetLocked(true)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, OnRender)

--"stolen" from im_tem thanks bro
function mod:BossRushRoomClear()
	if game:GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DOOR_SPAWNED) then
		game.BossRushParTime = 30 * 60 * 60 * 24	--is 24 hours enough?............
	end
	if game:GetStateFlag(GameStateFlag.STATE_BLUEWOMB_DOOR_SPAWNED) then
		game.BlueWombParTime = 30 * 60 * 60 * 24	--24 hours here too
	end
end

function mod:BossRushStart(iscontinued)
	if not iscontinued then
		game.BlueWombParTime = 54000		--i hate this game sometimes :)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.BossRushRoomClear)
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.BossRushStart)

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    player:BlockCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE)
end)

print("Isaac Rebalanced v"..mod.Version.." Loaded!")

--[[
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local level = game:GetLevel()
    if level:GetStage() == LevelStage.STAGE4_2 and level:GetStageType() >= StageType.STAGETYPE_REPENTANCE then
        local room = level:GetCurrentRoom()
        if level:GetCurrentRoomIndex() == GridRooms.ROOM_SECRET_EXIT_IDX and room:IsClear() then
            room:RemoveDoor(DoorSlot.LEFT0)
            room:RemoveDoor(DoorSlot.RIGHT0)

            for idx = 150, 225 do
                if (idx + 1) % 15 ~= 0 and (idx) % 15 ~= 0 then
                    local grid = room:GetGridEntity(idx)
                    if grid and grid.Desc and grid:GetType() == GridEntityType.GRID_WALL then
                        room:RemoveGridEntityImmediate(idx, 0, false)
                    end
                end
            end
        end
    end
end)
            ]]