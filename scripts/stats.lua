local mod = ISAACREBALANCED

local function TearsUp(firedelay, val)
    local currentTears = 30 / (firedelay + 1)
    local newTears = currentTears + val
    return math.max((30 / newTears) - 1, -0.99)
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
    local data = player:GetData()
    local savedata = mod.GetPlayerData(player)
    local effects = player:GetEffects()

    if cacheFlag & CacheFlag.CACHE_DAMAGE > 0 then
        local mult = mod:GetPlayerDamageMult(player)
        local feathercount = player:GetTrinketMultiplier(TrinketType.TRINKET_BLACK_FEATHER)

    elseif cacheFlag & CacheFlag.CACHE_FIREDELAY > 0 then
        local mult = mod:GetPlayerTearsMult(player)

        if player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE, false, true) then
            player.MaxFireDelay = TearsUp(player.MaxFireDelay, 1.5 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_NUMBER_ONE, false, true) * mult)
        end

        if player:GetPlayerType() == PlayerType.PLAYER_APOLLYON then
            player.MaxFireDelay = TearsUp(player.MaxFireDelay, -0.5 * mult)
        end

    elseif cacheFlag & CacheFlag.CACHE_SHOTSPEED > 0 then
        local mult = mod:GetPlayerShotSpeedMult(player)

    elseif cacheFlag & CacheFlag.CACHE_RANGE > 0 then
        local mult = mod:GetPlayerRangeMult(player)

        if player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE, false, true) then
            player.TearRange = player.TearRange - (2.5 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_NUMBER_ONE, false, true) * mult)
        end

        if effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_TELEPATHY_BOOK) then
            player.TearRange = player.TearRange + (3 * (effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_TELEPATHY_BOOK) - 1) * mult)
        end

    elseif cacheFlag & CacheFlag.CACHE_SPEED > 0 then
        local mult = player:GetD8SpeedModifier()

    elseif cacheFlag & CacheFlag.CACHE_TEARFLAG > 0 then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) and player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_EXPLOSIVE
        end

    elseif cacheFlag & CacheFlag.CACHE_TEARCOLOR > 0 then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE, false, true) then
            player.TearColor = Color.TearNumberOne
        end

    elseif cacheFlag & CacheFlag.CACHE_LUCK > 0 then

    end
end)

---@param player EntityPlayer
---@param cacheFlag CacheFlag
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, function(_, player, cacheFlag)
    local data = player:GetData()
    local effects = player:GetEffects()

    if cacheFlag & CacheFlag.CACHE_DAMAGE > 0 then

    elseif cacheFlag & CacheFlag.CACHE_FIREDELAY > 0 then

    elseif cacheFlag & CacheFlag.CACHE_RANGE > 0 then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE, false, true) then
            player.TearRange = player.TearRange * 0.8
        end
    end
end)

local PlayerDamageModifiers = {
    [PlayerType.PLAYER_CAIN] = 1.2,
    [PlayerType.PLAYER_JUDAS] = 1.35,
    [PlayerType.PLAYER_BLACKJUDAS] = 2,
    [PlayerType.PLAYER_BLUEBABY] = 1.05,
    [PlayerType.PLAYER_AZAZEL] = 1.5,
    [PlayerType.PLAYER_LAZARUS2] = 1.4,
    [PlayerType.PLAYER_KEEPER] = 1.5,
    [PlayerType.PLAYER_THEFORGOTTEN] = 1.5,

    [PlayerType.PLAYER_MAGDALENE_B] = 0.75,
    [PlayerType.PLAYER_CAIN_B] = 1.35,
    [PlayerType.PLAYER_EVE_B] = 1.2,
    [PlayerType.PLAYER_AZAZEL_B] = 1.5,
    [PlayerType.PLAYER_LAZARUS2_B] = 1.5,
    [PlayerType.PLAYER_THELOST_B] = 1.3,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
}

--Stat Multiplier Helpers:
---@param player EntityPlayer
function mod:GetPlayerDamageMult(player)
	local effects = player:GetEffects()
    local type = player:GetPlayerType()
	local mult = 1.0

    if PlayerDamageModifiers[type] ~= nil then
        mult = mult * PlayerDamageModifiers[type]
    elseif type == PlayerType.PLAYER_EVE
    and effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) == 0 then
        mult = mult * 0.75
    end

	if effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_MEGA_MUSH) > 0 then
		mult = mult * 4.0
	end

	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_EVES_MASCARA) > 0 then
		mult = mult * 2.0
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_POLYPHEMUS) > 0 and
	   player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0
	then
		mult = mult * 2.0
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SACRED_HEART) > 0 then
		mult = mult * 2.3
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ALMOND_MILK) > 0 then
		mult = mult * 0.3
	elseif player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SOY_MILK) > 0 then
		mult = mult * 0.2
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IMMACULATE_HEART) > 0 then
		mult = mult * 1.2
	end

    if effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) > 0 then
		mult = mult * 2.0
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_HAEMOLACRIA) > 0 then
		mult = mult * 1.5
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) > 0 then
		mult = mult * 0.8
	end

	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CRICKETS_HEAD) > 0 or
	   player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) > 0 or
	   (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR) > 0 and
		effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) > 0)
	then
		mult = mult * 1.5
	end

    mult = mult * player:GetD8DamageModifier()
    mult = mult * (1 + player:GetDeadEyeCharge() / 8)

    local hallowedaura = 0
    local staraura = 0

    for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND)) do
        if effect.Parent
        and (effect.Parent.Type == EntityType.ENTITY_POOP
        or effect.Parent.Type == EntityType.ENTITY_FAMILIAR
        and effect.Parent.Variant == FamiliarVariant.DIP) then
            local scale = ((effect.SpriteScale.X + effect.SpriteScale.Y) * 70 / 2) + player.Size
            if player.Position:Distance(effect.Position) < scale then
                hallowedaura = hallowedaura + 1
            end
        elseif effect.Parent
        and effect.Parent.Type == EntityType.ENTITY_FAMILIAR
        and effect.Parent.Variant == FamiliarVariant.STAR_OF_BETHLEHEM then
            local scale = 70 + player.Size
            if player.Position:Distance(effect.Position) < scale then
                staraura = staraura + 1
            end
        end
    end

    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_LIQUID_POOP)) do
        local effect = ent:ToEffect()
		if effect then
			local scale = ((effect.SpriteScale.X + effect.SpriteScale.Y) * 36 / 2)
			if effect.State == 64 and player.Position:Distance(effect.Position) <= scale then
				hallowedaura = hallowedaura + 1
			end
		end
    end

    if staraura > 0 then
        mult = mult * 1.8
    end
    if hallowedaura > 0 then
        mult = mult * 1.2
    end

	for _, familiar in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SUCCUBUS)) do
		if (player.Position - familiar.Position):Length() < 100 then
			mult = mult * 1.5
		end
	end

    local crown = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
    if crown > 0 then
        if (player.Damage / (mult * crown)) > 3.5 then
            --mult = mult * crown
        end
    end

	return mult
end

---@param player EntityPlayer
function mod:GetPlayerTearsMult(player)
	local effects = player:GetEffects()
    local mult = 1.0

    --Brimstone
    if player:HasWeaponType(2) then
        if player:GetPlayerType() == PlayerType.PLAYER_AZAZEL and
        player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE) == 0 then
            mult = mult * 0.267
        else
            mult = mult * 0.33
        end
    end

    --Dr. Fetus
    if player:HasWeaponType(5) then
        mult = mult * 0.4
    end

    --Lung
    if player:HasWeaponType(7) then
        mult = mult * 0.23
    end

    --Tech X
    if player:HasWeaponType(9) then
        if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) > 0 then
            mult = mult * 0.32
        else
            mult = mult
        end
    end

    --Forgotten etc
    if player:HasWeaponType(10) then
        mult = mult * 0.5
    end

    --C section, Knife, Epic Fetus, Technology, Ludo and Sword doesn't change it?
    --Please report any unknown or forgotten synergy

    --Ipecac
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IPECAC) > 0 then
        if not player:HasWeaponType(2) and
        not player:HasWeaponType(4) and
        not player:HasWeaponType(5) and
        not player:HasWeaponType(6) and
        not player:HasWeaponType(8) and
        not player:HasWeaponType(9) and
        not player:HasWeaponType(10) and
        not player:HasWeaponType(13) and
        not player:HasWeaponType(14) then
            mult = mult * 0.33
        end
    end

    --Almond/Soy Milk
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ALMOND_MILK) > 0 then
        mult = mult * 4
    elseif player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SOY_MILK) > 0 then
        mult = mult * 5.5
    end

    if player:GetPlayerType() == PlayerType.PLAYER_EVE_B then
      mult = mult * 0.66
    end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_EVES_MASCARA) > 0 then
        mult = mult * 0.66
    end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) > 0 then
        mult = mult * 0.66
    end

	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_EYE_DROPS) > 0 then
		mult = mult * 1.2
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE) > 0 and
    player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0 then
        mult = mult * 0.51
    elseif player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_HANGED_MAN) and
    player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0 then
        mult = mult * 0.51
    elseif player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) > 0 and
    player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0 then
        mult = mult * 0.42
    elseif player:GetCollectibleNum(CollectibleType.COLLECTIBLE_POLYPHEMUS) > 0 and
    player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0 and
    not player:HasWeaponType(14) then
        mult = mult * 0.42
    end

	if effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) then
		mult = mult * 0.5
	end

    --Cards
    if effects:HasNullEffect(NullItemID.ID_REVERSE_CHARIOT) then
        mult = mult * 4
    end

    --Misc
    if player:GetPlayerType() == PlayerType.PLAYER_JUDAS and
    player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT) > 0 and
    effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_DECAP_ATTACK) then
        mult = mult * 3
    end

    local epiphora = player:GetEpiphoraCharge()

    if epiphora >= 270 then
        mult = mult * 2
    elseif epiphora >= 180 then
        mult = mult * (5/3)
    elseif epiphora >= 90 then
        mult = mult * (4/3)
    end

    mult = mult * player:GetD8FireDelayModifier()

    local aura = 0

    for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND)) do
        if effect.Parent
        and (effect.Parent.Type == EntityType.ENTITY_POOP
        or effect.Parent.Type == EntityType.ENTITY_FAMILIAR
        and effect.Parent.Variant == FamiliarVariant.DIP) then
            local scale = ((effect.SpriteScale.X + effect.SpriteScale.Y) * 70 / 2) + player.Size
            if player.Position:Distance(effect.Position) < scale then
                aura = aura + 1
            end
        elseif effect.Parent
        and effect.Parent.Type == EntityType.ENTITY_FAMILIAR
        and effect.Parent.Variant == FamiliarVariant.STAR_OF_BETHLEHEM then
            local scale = 70 + player.Size
            if player.Position:Distance(effect.Position) < scale then
                aura = aura + 1
            end
        end
    end

	local creepaura = 0

    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_LIQUID_POOP)) do
        local effect = ent:ToEffect()
		if effect then
			local scale = ((effect.SpriteScale.X + effect.SpriteScale.Y) * 36 / 2)
			if effect.State == 64 and player.Position:Distance(effect.Position) <= scale then
				creepaura = creepaura + 1
			end
		end
    end

	if creepaura > 0 then
		mult = mult * 3
   elseif aura > 0 then
        mult = mult * 2.5
    end

    return mult
end

---@param player EntityPlayer
function mod:GetPlayerRangeMult(player)
    local mult = 40

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_NUMBER_ONE) > 0 then
        mult = mult * 0.8
    end
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CRICKETS_BODY) > 0
	or player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IPECAC) > 0 
	or player:GetCollectibleNum(CollectibleType.COLLECTIBLE_HAEMOLACRIA) > 0 then
        mult = mult * 0.8
    end
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MY_REFLECTION) > 0 then
        mult = mult * 2
    end
    
	mult = mult * player:GetD8RangeModifier()

    local crown = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
    if crown > 0 then
        if (player.TearRange / (40 * mult * crown)) > 6.5 then
            --multi = multi * crown
        end
    end

    return mult
end

---@param player EntityPlayer
function mod:GetPlayerShotSpeedMult(player)
    local mult = 1

	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IPECAC) > 0 then
		mult = mult * 0.8
	end
	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MY_REFLECTION) > 0 then
		mult = mult * 1.6
	end

    local crown = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
    if crown > 0 then
        if (player.ShotSpeed / (mult * crown)) > 1 then
            --multi = multi * crown
        end
    end

    return mult
end