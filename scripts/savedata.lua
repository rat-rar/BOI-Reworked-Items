--[[	The Binding of Isaac: Repentance mod save module, by KingBobson (updated by rat.rar)
	To use this in your mod, just add this line somewhere at the start (directly beneath registering your mod is a good idea):

include("save")(Mod)
	
	where Mod is whatever your RegisterMod() spat out -- if you named it differently obviously change it there too

	This adds the storage areas Mod.Data, Mod.Persistent, and Mod.Config
		Add data to these with Mod.Data.MyStuff = 5, or Mod.Persistent[7] = true, or whatever.
		Actually, try to avoid that second thing -- you would not believe how much the json module hates numerical indicies. Use a tostring()
		
		Mod.Data is used for per-run storage, i.e. most of what you'll want. Vanilla examples are Bloody Lust or if Greed has spawned this run.
		Mod.Persistent is used for across-run storage. Vanilla examples are unlocks, completion marks, or the Donation Machine total.
		Mod.Config is used for config settings. Vanilla examples are everything in the options menu.

	This also adds the functions Mod.GetPlayerData(player), Mod.SaveConfig(), and Mod.SetConfigDefaults()
		Use Mod.GetPlayerData(player) with Mod.GetPlayerData(player).DamageUps = 4, etc.
			Use this if the data might be different between different players on the same run, such as between Jacob and Esau.
			(the Bloody Lust example already mentioned would want to use this function; Greed spawning would not)
		Use Mod.SaveConfig() whenever a config setting has changed. With MCM put this at the end of each OnChange function.
		Use Mod.SetConfigDefaults() at the start of your mod, to set default values for config settings.
			There are two ways to use this function:
				Mod.SetConfigDefaults("FakeSetting",5) will set Mod.Config.FakeSetting to 5 by default.
				
				local ConfigDefault = {
					FakeSetting = 5,
					RealSetting = true,
					MetaSetting = {
						ThisIsFancy = 4,
						VeryFancy = "blah"
					}
				}
				Mod.SetConfigDefaults(ConfigDefault)
					
				The above code sets Mod.Config.FakeSetting to 5, Mod.Config.RealSetting to true, Mod.Config.MetaSetting to a table.
				It checks the values individually so if you just added e.g. VeryFancy, it would be added without changing what ThisIsFancy was set to.
				This is useful if you add a new config setting in an update to your mod.
				
			Both uses of this will not change a config value if it is already defined.
			Mod.SetConfigDefaults() should be called directly after including the module.
]]

return function(Mod)

local json = require("json")
local SaveDataDelayedCallback = false

-- Check what happens to the second player if the first has some data changing their stats on continuing?

-- These are here to prevent errors on starting the first run after launching the game. Hate it.
Mod.Data = {}
Mod.LastData = {}
Mod.Config = {}
Mod.Persistent = {}

-- Lua deep-copy function, copied off the internet. Needed for glowing hourglass support.
local function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Returns a table where you can put in data that's relevant for one player. Useful for tracking e.g. how many times this player has gotten a stat-up.
function Mod.GetPlayerData(player)
	local id = player:GetPlayerIndex() -- has to be a string because the json library HATES large numbers
	if not Mod.Data[id] then Mod.Data[id] = {} end
	return Mod.Data[id]
end

-- Reloads all player caches. It happens thrice here so might as well make it a function.
local function ReloadAllCache()
	for i=0,Game():GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
end

-- Saves current Data, Persistent, and Config to storage.
local function HardSaveStorage(_, shouldSave) -- 99% sure there's no harm in ignoring shouldsave as long as you blank out the data at the start of a run
	local saving = {
		Data = Mod.Data,
		Config = Mod.Config,
		Persistent = Mod.Persistent
	}
	if shouldSave then
		Mod:SaveData(json.encode(saving))
	else
		Mod.Data = {}
		Mod.LastData = {}
		Mod:SaveData(json.encode(saving))
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, HardSaveStorage)

-- Saves current Data, Persistent, and Config to storage.
local function SaveStorage(_, shouldSave) -- 99% sure there's no harm in ignoring shouldsave as long as you blank out the data at the start of a run
	local saving = {
		Data = Mod.Data,
		Config = Mod.Config,
		Persistent = Mod.Persistent
	}
	Mod:SaveData(json.encode(saving))
end

-- Loads up Data, LastData, Persistent, and Config when continuing a run; only loads up Persistent and Config when starting a new one
local function LoadStorage(_,savestate)
	if savestate then
		if Mod:HasData() then
			local loaded = json.decode(Mod:LoadData())
			Mod.Data = loaded.Data
			Mod.LastData = DeepCopy(loaded.Data) -- glowing hourglass forgets things when you save/continue
			Mod.Config = loaded.Config
			Mod.Persistent = loaded.Persistent
			-- And reload all player caches, in case the mod changed stats.
			--Game():Update()?
			ReloadAllCache()
		else
			-- continuing an existing run right after getting the mod. Pretty bad idea, hypothetical player doing this, but it shouldn't crash maybe
			Mod.Data = {}
			Mod.LastData = {}
			Mod.Config = {}
			Mod.Persistent = {}
		end
	else
		-- fresh run, clear out the data, but load the config and persistent
		if Mod:HasData() then
			local loaded = json.decode(Mod:LoadData())
			Mod.Data = {}
			Mod.LastData = {}
			Mod.Config = loaded.Config
			Mod.Persistent = loaded.Persistent
			ReloadAllCache() -- should not matter, but I SWEAR I had a bug related to it once so let's be safe
		else
			-- continuing an existing run right after getting the mod. Pretty bad idea, hypothetical player doing this, but it shouldn't crash maybe
			Mod.Data = {}
			Mod.LastData = {}
			Mod.Config = {}
			Mod.Persistent = {}
		end
	end
end
Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.EARLY, LoadStorage)

-- Sets LastData to what Data was at the end of the previous room
local function DataToLastData()
	Mod.LastData = DeepCopy(Mod.Data)
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DataToLastData)

-- Makes Glowing Hourglass work. The death of many modders before you, since none of this is automatic.
-- Thank the heavens you can't chain hourglass uses. Being able to go up floors is bad enough.
local function GlowingHourglassCompatability()
	Mod.Data = DeepCopy(Mod.LastData)
	ReloadAllCache() -- in case it changed stats or something
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, GlowingHourglassCompatability, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

-- Saves config changes without saving current data with it -- keeps mod data in sync with game data.
-- THIS IS NOT A CALLBACK -- you'll need to manually insert this in your MCM OnChange function.
function Mod.SaveConfig()
	local saving = {
		Data = {},
		Config = Mod.Config,
		Persistent = {}
	}
	if Mod:HasData() then
		local loaded = json.decode(Mod:LoadData())
		saving.Data = loaded.Data
		saving.Persistent = loaded.Persistent
	end
	Mod:SaveData(json.encode(saving))
end

-- Sets default config settings if none are present. Really only does anything on first launch of mod, or the first launch after adding a new setting.
function Mod.SetConfigDefaults(defaults, setting, layer)
	if not layer then layer = Mod.Config end
	if type(defaults) == "table" then
		-- a table's being fed in for the defaults
		for k,v in pairs(defaults) do
			Mod.SetConfigDefaults(k, v)
		end
	elseif type(setting) == "table" then
		if layer[defaults] == nil then layer[defaults] = {} end
		for k,v in pairs(setting) do
			Mod.SetConfigDefaults(k, v, layer[defaults])
		end
	else
		if layer[defaults] == nil then layer[defaults] = setting end
	end
end

-- This should remain at the bottom, so any changes to Data your mod makes at the start of a new floor will be saved.
local function DelayAddingThisCallback()
	SaveStorage() -- just throwing this in here because you need to save after starting a new run, or else you can kinda carry data over runs in niche ways
	if SaveDataDelayedCallback then return end
	Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SaveStorage)
	SaveDataDelayedCallback = true
end
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, DelayAddingThisCallback)
-- (this callback is needed because the game autosaves at this time too. In case of a crash, this keeps your mod in sync with the game)

LoadStorage(_,true) -- without this you're in big trouble
Mod.SaveModuleVersion = 1

end