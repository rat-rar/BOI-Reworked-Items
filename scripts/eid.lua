local mod = ISAACREBALANCED

if not EID then return end

mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()

    local ItemDescriptionsEnglish = {
        [CollectibleType.COLLECTIBLE_TELEPORT] = "Teleports Isaac into a random room on the map#Direction of the teleport can be influenced with the movement keys",
    }

    local CardDescriptionsEnglish = {
       [Card.CARD_REVERSE_WORLD] = "{{ErrorRoom}} Teleports Isaac to the Error Room",
        --[Card.CARD_SOUL_AZAZEL] = "{{Collectible441}} Fires a Mega Blast beam for 15 seconds",
    }

    local PillDescriptionsEnglish = {
        [PillEffect.PILLEFFECT_HORF] = "{{Collectible149}} Gives Ipecac for the room"
    }

    local HorsePillDescriptionsEnglish = {
        [PillEffect.PILLEFFECT_HORF] = "{{Collectible149}} Gives Ipecac for the room"
    }



    if FiendFolio then
        --CardDescriptionsEnglish[Card.RUNE_BERKANO] = "Summons 6-10 blue flies, 6-10 blue spiders, and 6-10 blue scuzz"
    end

    EID:addCollectible(CollectibleType.COLLECTIBLE_TELEPORT, "Teleports Isaac into a random room on the map#Direction of the teleport can be influenced with the movement keys")
    --EID:addCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE, "Replaces Isaac's tears with one giant controllable tear#Pressing the drop button ({{ButtonRT}}) causes the tear to burst and spawns a new one")
    EID:addCard(Card.CARD_REVERSE_WORLD, "{{ErrorRoom}} Teleports Isaac to the Error Room")
    EID:addPill(PillEffect.PILLEFFECT_HORF, "{{Collectible149}} Gives Ipecac for the room", "Horf!")
    EID:addHorsePill(PillEffect.PILLEFFECT_HORF, "{{Collectible149}} Gives Ipecac for the room", "Horf!")


    --EID.descriptions["en_us"].CharacterInfo[3] = {"Judas", "Cards that spawn have a 10% chance to be a Devil Card"}
    --EID.descriptions["en_us"].CharacterInfo[5] = {"Eve", "Eve has a +6.25% chance for heart drops to be {{SoulHeart}} Soul Hearts"}
    --EID.descriptions["en_us"].CharacterInfo[6] = {"Samson", "Samson deals 24 contact damage per second"}
    --EID.descriptions["en_us"].CharacterInfo[23] = {"Tainted Cain", "Touching an item pedestal turns it into a variety of pickups#Gain collectibles by crafting 8 pickups together in the Bag of Crafting#The Bag's contents can be shifted with {{ButtonRT}} to replace specific pickups when full#The Bag's swing deals 3x Isaac's damage"}


    --for id, desc in pairs(CardDescriptionsEnglish) do
    --end

    --for id, desc in pairs(PillDescriptionsEnglish) do
    --  EID:addPill(id, desc)
    --end

    for id, desc in pairs(HorsePillDescriptionsEnglish) do
        --EID:addCard(id, desc)
    end

    --EID.ItemReminderDescriptionModifier["5.100.44"] = {}

end)