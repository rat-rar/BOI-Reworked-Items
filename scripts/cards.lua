local mod = ISAACREBALANCED
local game = Game()
local level = game:GetLevel()
Isaac.GetItemConfig():GetCard(Card.CARD_REVERSE_WORLD).MimicCharge = 12

---@param player EntityPlayer
---@param useflag UseFlag
function mod:UseReverseWorldError(_, player, useflag)
    local crng = player:GetCardRNG(Card.CARD_REVERSE_WORLD)
    local roomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ERROR, false, crng)
    if not level:IsNextStageAvailable() then
        roomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_DEFAULT, false, crng)
    end
    level.LeaveDoor = -1
    game:StartRoomTransition(roomIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
    mod:TrySayAnnouncerLine(SoundEffect.SOUND_REVERSE_WORLD, useflag)
    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, mod.UseReverseWorldError, Card.CARD_REVERSE_WORLD)