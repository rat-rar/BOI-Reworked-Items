local mod = ISAACREBALANCED
local game = Game()

---@param name string
---@return {Type: integer, Variant: integer, SubType: integer}
function mod:GetTypeVarSub(name)
	return {
		Type    = Isaac.GetEntityTypeByName(name),
		Variant = Isaac.GetEntityVariantByName(name),
		SubType = Isaac.GetEntitySubTypeByName(name),
	}
end

---@param player EntityPlayer
---@param poopVariant EntityPoopVariant
function mod:TryHoldPoop(player, poopVariant)
    local poop = Isaac.Spawn(EntityType.ENTITY_POOP, poopVariant, 0, player.Position, Vector.Zero, player)
    for i = 1, 20 do
        poop:Update()
    end
    player:TryHoldEntity(poop)
    SFXManager():Play(SoundEffect.SOUND_POOPITEM_HOLD)
end

---@param sfxid SoundEffect
---@param useflags UseFlag
function mod:TrySayAnnouncerLine(sfxid, useflags)
	if not (useflags & UseFlag.USE_NOANNOUNCER > 0) then
		local mode = Options.AnnouncerVoiceMode
		if mode == 2 or (mode == 0 and math.random(2) == 1) then
			SFXManager():Play(sfxid, 2, 60, false, 1)
		end
	end
end

---@param bomb EntityBomb
---@return number
function mod:GetBombExplosionRadius(bomb)
	local damage = bomb.ExplosionDamage
	local radiusMult = bomb.RadiusMultiplier
	local radius

	if damage >= 175.0 then
		radius = 105.0
	else
		if damage <= 140.0 then
			radius = 75.0
		else
			radius = 90.0
		end
	end

	return radius * radiusMult
end

--[[
---@param grid GridEntity
function mod:RerollGrid(grid)
    if BlocksThatReroll[grid:GetType()] then
        grid:SetType(GridEntityType.GRID_ROCK)
        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, grid.Position, Vector.Zero, nil):ToTear()
        tear:AddTearFlags(TearFlags.TEAR_REROLL_ROCK_WISP)
        tear:Update()
        tear:Remove()

        print(grid:GetType())
        if grid:GetType() ~= GridEntityType.GRID_POOP then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, grid.Position, Vector.Zero, nil)
        end
    end


end
]]