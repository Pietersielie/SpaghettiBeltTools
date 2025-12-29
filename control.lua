local beltGraph = require("scripts/belt-graph")

local VERBOSE = 0

-- Table containing list of pipelike items to remove when removing pipes.
local pipeSelectionTypeFilter = {}
pipeSelectionTypeFilter["pipe"] = true
pipeSelectionTypeFilter["pipe-to-ground"] = true
pipeSelectionTypeFilter["pump"] = true
pipeSelectionTypeFilter["offshore-pump"] = true
pipeSelectionTypeFilter["storage-tank"] = true

-- Table containing list of belt tiers, with each tier having its belt, underground belt, splitter. If applicable mods are loaded, a 1x1 loader and 1x2 loader are included as well.
local BigTableOfBelts = {}

-- Base game
BigTableOfBelts["transport-belt"] = {["transport-belt"] = "transport-belt", ["underground-belt"] = "underground-belt", ["splitter"] = "splitter"} -- yellow
BigTableOfBelts["fast-transport-belt"] = {["transport-belt"] = "fast-transport-belt", ["underground-belt"] = "fast-underground-belt", ["splitter"] = "fast-splitter"} -- red
BigTableOfBelts["express-transport-belt"] = {["transport-belt"] = "express-transport-belt", ["underground-belt"] = "express-underground-belt", ["splitter"] = "express-splitter"} -- blue

-- Space Age
BigTableOfBelts["turbo-transport-belt"] = {["transport-belt"] = "turbo-transport-belt", ["underground-belt"] = "turbo-underground-belt", ["splitter"] = "turbo-splitter"} -- green

-- Lignumis (https://mods.factorio.com/mod/lignumis)
BigTableOfBelts["wood-transport-belt"] = {["transport-belt"] = "wood-transport-belt", ["underground-belt"] = "wood-underground-belt", ["splitter"] = "wood-splitter"} -- brown

-- Advanced Belts (https://mods.factorio.com/mod/AdvancedBeltsSA/)
BigTableOfBelts["advanced-transport-belt"] = {["transport-belt"] = "extreme-belt", ["underground-belt"] = "extreme-underground", ["splitter"] = "extreme-splitter"} -- cyan
BigTableOfBelts["elite-transport-belt"] = {["transport-belt"] = "ultimate-belt", ["underground-belt"] = "ultimate-underground", ["splitter"] = "ultimate-splitter"} -- orange
BigTableOfBelts["hyper-transport-belt"] = {["transport-belt"] = "high-speed-belt", ["underground-belt"] = "high-speed-underground", ["splitter"] = "high-speed-splitter"} -- purple

-- Ultimate Belts (https://mods.factorio.com/mod/UltimateBeltsSpaceAge)
BigTableOfBelts["ultra-fast-transport-belt"] = {["transport-belt"] = "ultra-fast-belt", ["underground-belt"] = "ultra-fast-underground-belt", ["splitter"] = "ultra-fast-splitter"} -- dark green
BigTableOfBelts["extreme-fast-transport-belt"] = {["transport-belt"] = "extreme-fast-belt", ["underground-belt"] = "extreme-fast-underground-belt", ["splitter"] = "extreme-fast-splitter"} -- dark red
BigTableOfBelts["ultra-express-transport-belt"] = {["transport-belt"] = "ultra-express-belt", ["underground-belt"] = "ultra-express-underground-belt", ["splitter"] = "ultra-express-splitter"} -- dark purple
BigTableOfBelts["extreme-express-transport-belt"] = {["transport-belt"] = "extreme-express-belt", ["underground-belt"] = "extreme-express-underground-belt", ["splitter"] = "extreme-express-splitter"} -- dark blue
BigTableOfBelts["ultimate-transport-belt"] = {["transport-belt"] = "ultimate-belt", ["underground-belt"] = "original-ultimate-underground-belt", ["splitter"] = "original-ultimate-splitter"} -- dark cyan

-- 5Dim - New Transport (https://mods.factorio.com/mod/5dim_transport)
BigTableOfBelts["5d-transport-belt-mk4"] = {["transport-belt"] = "5d-transport-belt-04", ["underground-belt"] = "5d-underground-belt-04", ["splitter"] = "5d-splitter-04", ["loader1x1"] = "5d-loader-1x1-04", ["loader1x2"] = "5d-loader-04"} -- pink
BigTableOfBelts["5d-transport-belt-mk5"] = {["transport-belt"] = "5d-transport-belt-05", ["underground-belt"] = "5d-underground-belt-05", ["splitter"] = "5d-splitter-05", ["loader1x1"] = "5d-loader-1x1-05", ["loader1x2"] = "5d-loader-05"} -- green
BigTableOfBelts["5d-transport-belt-mk6"] = {["transport-belt"] = "5d-transport-belt-06", ["underground-belt"] = "5d-underground-belt-06", ["splitter"] = "5d-splitter-06", ["loader1x1"] = "5d-loader-1x1-06", ["loader1x2"] = "5d-loader-06"} -- brown
BigTableOfBelts["5d-transport-belt-mk7"] = {["transport-belt"] = "5d-transport-belt-07", ["underground-belt"] = "5d-underground-belt-07", ["splitter"] = "5d-splitter-07", ["loader1x1"] = "5d-loader-1x1-07", ["loader1x2"] = "5d-loader-07"} -- purple
BigTableOfBelts["5d-transport-belt-mk8"] = {["transport-belt"] = "5d-transport-belt-08", ["underground-belt"] = "5d-underground-belt-08", ["splitter"] = "5d-splitter-08", ["loader1x1"] = "5d-loader-1x1-08", ["loader1x2"] = "5d-loader-08"} -- white
BigTableOfBelts["5d-transport-belt-mk9"] = {["transport-belt"] = "5d-transport-belt-09", ["underground-belt"] = "5d-underground-belt-09", ["splitter"] = "5d-splitter-09", ["loader1x1"] = "5d-loader-1x1-09", ["loader1x2"] = "5d-loader-09"} -- orange
BigTableOfBelts["5d-transport-belt-mk10"] = {["transport-belt"] = "5d-transport-belt-10", ["underground-belt"] = "5d-underground-belt-10", ["splitter"] = "5d-splitter-10", ["loader1x1"] = "5d-loader-1x1-10", ["loader1x2"] = "5d-loader-10"} -- dark blue

-- Krastorio2 (https://mods.factorio.com/mod/Krastorio2)
BigTableOfBelts["kr-advanced-transport-belt"] = {["transport-belt"] = "kr-advanced-transport-belt", ["underground-belt"] = "kr-advanced-underground-belt", ["splitter"] = "kr-advanced-splitter", ["loader1x1"] = "kr-advanced-loader"} -- green
BigTableOfBelts["kr-superior-transport-belt"] = {["transport-belt"] = "kr-superior-transport-belt", ["underground-belt"] = "kr-superior-underground-belt", ["splitter"] = "kr-superior-splitter", ["loader1x1"] = "kr-superior-loader"} -- purple

-- Quantum Belts (https://mods.factorio.com/mod/quantum-belts)
BigTableOfBelts["quantum-transport-belt"] = {["transport-belt"] = "quantum-belt", ["underground-belt"] = "quantum-underground", ["splitter"] = "quantum-splitter"} -- magenta

-- Factorio+ (https://mods.factorio.com/mod/factorioplus)
BigTableOfBelts["basic-transport-belt"] = {["transport-belt"] = "basic-transport-belt", ["underground-belt"] = "basic-underground-belt", ["splitter"] = "basic-splitter", ["loader1x2"] = "basic-loader"} -- white/grey
BigTableOfBelts["supersonic-transport-belt"] = {["transport-belt"] = "supersonic-transport-belt", ["underground-belt"] = "supersonic-underground-belt", ["splitter"] = "supersonic-splitter", ["loader1x2"] = "supersonic-loader"} -- pink

-- Planetaris Unbounded: Arig (https://mods.factorio.com/mod/planetaris-unbounded)
BigTableOfBelts["planetaris-hyper-belt"] = {["transport-belt"] = "planetaris-hyper-transport-belt", ["underground-belt"] = "planetaris-hyper-underground-belt", ["splitter"] = "planetaris-hyper-splitter"} -- white

-- More Belts (https://mods.factorio.com/mod/more-belts)
BigTableOfBelts["more-belts-mk4"] = {["transport-belt"] = "ddi-transport-belt-mk4", ["underground-belt"] = "ddi-underground-belt-mk4", ["splitter"] = "ddi-splitter-mk4", ["laneSplit"] = "mk4-lane-splitter"} -- green
BigTableOfBelts["more-belts-mk5"] = {["transport-belt"] = "ddi-transport-belt-mk5", ["underground-belt"] = "ddi-underground-belt-mk5", ["splitter"] = "ddi-splitter-mk5", ["laneSplit"] = "mk5-lane-splitter"} -- dark blue
BigTableOfBelts["more-belts-mk6"] = {["transport-belt"] = "ddi-transport-belt-mk6", ["underground-belt"] = "ddi-underground-belt-mk6", ["splitter"] = "ddi-splitter-mk6", ["laneSplit"] = "mk6-lane-splitter"} -- red
BigTableOfBelts["more-belts-mk7"] = {["transport-belt"] = "ddi-transport-belt-mk7", ["underground-belt"] = "ddi-underground-belt-mk7", ["splitter"] = "ddi-splitter-mk7", ["laneSplit"] = "mk7-lane-splitter"} -- purple
BigTableOfBelts["more-belts-mk8"] = {["transport-belt"] = "ddi-transport-belt-mk8", ["underground-belt"] = "ddi-underground-belt-mk8", ["splitter"] = "ddi-splitter-mk8", ["laneSplit"] = "mk8-lane-splitter"} -- magenta

-- Space Exploration (https://mods.factorio.com/mod/space-exploration)
BigTableOfBelts["se-space-transport-belt"] = {["transport-belt"] = "se-space-transport-belt", ["underground-belt"] = "se-space-underground-belt", ["splitter"] = "se-space-splitter"} -- white
BigTableOfBelts["se-deep-space-transport-belt-black"] = {["transport-belt"] = "se-deep-space-transport-belt-black", ["underground-belt"] = "se-deep-space-underground-belt-black", ["splitter"] = "se-deep-space-splitter-black"} -- black
BigTableOfBelts["se-deep-space-transport-belt-blue"] = {["transport-belt"] = "se-deep-space-transport-belt-blue", ["underground-belt"] = "se-deep-space-underground-belt-blue", ["splitter"] = "se-deep-space-splitter-blue"} -- blue
BigTableOfBelts["se-deep-space-transport-belt-cyan"] = {["transport-belt"] = "se-deep-space-transport-belt-cyan", ["underground-belt"] = "se-deep-space-underground-belt-cyan", ["splitter"] = "se-deep-space-splitter-cyan"} -- cyan
BigTableOfBelts["se-deep-space-transport-belt-green"] = {["transport-belt"] = "se-deep-space-transport-belt-green", ["underground-belt"] = "se-deep-space-underground-belt-green", ["splitter"] = "se-deep-space-splitter-green"} -- green
BigTableOfBelts["se-deep-space-transport-belt-magenta"] = {["transport-belt"] = "se-deep-space-transport-belt-magenta", ["underground-belt"] = "se-deep-space-underground-belt-magenta", ["splitter"] = "se-deep-space-splitter-magenta"} -- magenta
BigTableOfBelts["se-deep-space-transport-belt-red"] = {["transport-belt"] = "se-deep-space-transport-belt-red", ["underground-belt"] = "se-deep-space-underground-belt-red", ["splitter"] = "se-deep-space-splitter-red"} -- red
BigTableOfBelts["se-deep-space-transport-belt-white"] = {["transport-belt"] = "se-deep-space-transport-belt-white", ["underground-belt"] = "se-deep-space-underground-belt-white", ["splitter"] = "se-deep-space-splitter-white"} -- white
BigTableOfBelts["se-deep-space-transport-belt-yellow"] = {["transport-belt"] = "se-deep-space-transport-belt-yellow", ["underground-belt"] = "se-deep-space-underground-belt-yellow", ["splitter"] = "se-deep-space-splitter-yellow"} -- yellow

-- Bob's Logistics (https://mods.factorio.com/mod/boblogistics)
BigTableOfBelts["bob-basic-transport-belt"] = {["transport-belt"] = "bob-basic-transport-belt", ["underground-belt"] = "bob-basic-underground-belt", ["splitter"] = "bob-basic-splitter"} -- grey
BigTableOfBelts["bob-turbo-transport-belt"] = {["transport-belt"] = "bob-turbo-transport-belt", ["underground-belt"] = "bob-turbo-underground-belt", ["splitter"] = "bob-turbo-splitter"} -- purple
BigTableOfBelts["bob-ultimate-transport-belt"] = {["transport-belt"] = "bob-ultimate-transport-belt", ["underground-belt"] = "bob-ultimate-underground-belt", ["splitter"] = "bob-ultimate-splitter"} -- green

-- AAI Loaders ()
if (script.active_mods['aai-loaders']) then
	BigTableOfBelts["transport-belt"]["loader1x1"] = "aai-loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x1"] = "aai-fast-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x1"] = "aai-express-loader"
	BigTableOfBelts["turbo-transport-belt"]["loader1x1"] = "aai-turbo-loader"

	BigTableOfBelts["se-space-transport-belt"]["loader1x1"] = "aai-se-space-loader"
	BigTableOfBelts["se-deep-space-transport-belt-black"]["loader1x1"] = "aai-se-deep-space-black-loader"
	BigTableOfBelts["se-deep-space-transport-belt-blue"]["loader1x1"] = "aai-se-deep-space-blue-loader"
	BigTableOfBelts["se-deep-space-transport-belt-cyan"]["loader1x1"] = "aai-se-deep-space-cyan-loader"
	BigTableOfBelts["se-deep-space-transport-belt-green"]["loader1x1"] = "aai-se-deep-space-green-loader"
	BigTableOfBelts["se-deep-space-transport-belt-magenta"]["loader1x1"] = "aai-se-deep-space-magenta-loader"
	BigTableOfBelts["se-deep-space-transport-belt-red"]["loader1x1"] = "aai-se-deep-space-red-loader"
	BigTableOfBelts["se-deep-space-transport-belt-white"]["loader1x1"] = "aai-se-deep-space-white-loader"
	BigTableOfBelts["se-deep-space-transport-belt-yellow"]["loader1x1"] = "aai-se-deep-space-yellow-loader"
	if (script.active_mods['boblogistics']) then
		BigTableOfBelts["turbo-transport-belt"]["loader1x1"] = nil
		BigTableOfBelts["bob-basic-transport-belt"]["loader1x1"] = "aai-basic-loader"
		BigTableOfBelts["bob-turbo-transport-belt"]["loader1x1"] = "aai-turbo-loader"
		BigTableOfBelts["bob-ultimate-transport-belt"]["loader1x1"] = "aai-ultimate-loader"
	end
end

-- Krastorio2 loaders (https://mods.factorio.com/mod/Krastorio2)
if (script.active_mods['Krastorio2'] or script.active_mods['Krastorio2-spaced-out']) then
	BigTableOfBelts["transport-belt"]["loader1x1"] = "kr-loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x1"] = "kr-fast-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x1"] = "kr-express-loader"
end

-- 5Dim - New Transport loaders (https://mods.factorio.com/mod/5dim_transport)
if (script.active_mods['5dim_transport']) then
	BigTableOfBelts["transport-belt"]["loader1x1"] = "5d-loader-1x1-01"
	BigTableOfBelts["fast-transport-belt"]["loader1x1"] = "5d-loader-1x1-02"
	BigTableOfBelts["express-transport-belt"]["loader1x1"] = "5d-loader-1x1-03"
	BigTableOfBelts["transport-belt"]["loader1x2"] = "loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x2"] = "fast-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x2"] = "express-loader"
end

-- Loaders Modernized (https://mods.factorio.com/mod/loaders-modernized)
if (script.active_mods['loaders-modernized']) then
	BigTableOfBelts["transport-belt"]["loader1x1"] = "mdrn-loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x1"] = "fast-mdrn-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x1"] = "express-mdrn-loader"
	BigTableOfBelts["turbo-transport-belt"]["loader1x1"] = "turbo-mdrn-loader"

	BigTableOfBelts["ultra-fast-transport-belt"]["loader1x1"] = "ultra-fast-mdrn-loader"
	BigTableOfBelts["extreme-fast-transport-belt"]["loader1x1"] = "extreme-fast-mdrn-loader"
	BigTableOfBelts["ultra-express-transport-belt"]["loader1x1"] = "ultra-express-mdrn-loader"
	BigTableOfBelts["extreme-express-transport-belt"]["loader1x1"] = "extreme-express-mdrn-loader"
	BigTableOfBelts["ultimate-transport-belt"]["loader1x1"] = "original-ultimate-mdrn-loader"
end

-- Factorio+ loaders (https://mods.factorio.com/mod/factorioplus)
if (script.active_mods['factorioplus']) then
	BigTableOfBelts["transport-belt"]["loader1x2"] = "loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x2"] = "fast-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x2"] = "express-loader"
	BigTableOfBelts["turbo-transport-belt"]["loader1x2"] = "turbo-loader"
end

-- Lane balancers and splitters (https://mods.factorio.com/mod/lane-balancers, https://mods.factorio.com/mods/lane-splitters)
if (script.active_mods['lane-balancers'] or script.active_mods['lane-splitters'] or script.active_mods['more-belts']) then
	BigTableOfBelts["transport-belt"]["laneSplit"] = "lane-splitter"
	BigTableOfBelts["fast-transport-belt"]["laneSplit"] = "fast-lane-splitter"
	BigTableOfBelts["express-transport-belt"]["laneSplit"] = "express-lane-splitter"
	BigTableOfBelts["turbo-transport-belt"]["laneSplit"] = "turbo-lane-splitter"
end

-- Comfortable Loader (https://mods.factorio.com/mod/comfortable-loader, https://mods.factorio.com/mod/ComfortableLoader-MoreBelts)
if (script.active_mods['comfortable-loader'] or script.active_mods['ComfortableLoader-MoreBelts']) then
	BigTableOfBelts["transport-belt"]["loader1x1"] = "comfortable-loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x1"] = "fast-comfortable-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x1"] = "express-comfortable-loader"
	BigTableOfBelts["turbo-transport-belt"]["loader1x1"] = "turbo-comfortable-loader"
	
	BigTableOfBelts["more-belts-mk4"]['loader1x1'] = 'comfortable-loader-mk4'
	BigTableOfBelts["more-belts-mk5"]['loader1x1'] = 'comfortable-loader-mk5'
	BigTableOfBelts["more-belts-mk6"]['loader1x1'] = 'comfortable-loader-mk6'
	BigTableOfBelts["more-belts-mk7"]['loader1x1'] = 'comfortable-loader-mk7'
	BigTableOfBelts["more-belts-mk8"]['loader1x1'] = 'comfortable-loader-mk8'
end

-- More Belts Loaders
if (script.active_mods['more-belts-loaders']) then
	BigTableOfBelts["transport-belt"]["loader1x1"] = "ddi-loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x1"] = "ddi-fast-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x1"] = "ddi-express-loader"
	
	BigTableOfBelts["more-belts-mk4"]['loader1x1'] = 'ddi-loader-mk4'
	BigTableOfBelts["more-belts-mk5"]['loader1x1'] = 'ddi-loader-mk5'
	BigTableOfBelts["more-belts-mk6"]['loader1x1'] = 'ddi-loader-mk6'
	BigTableOfBelts["more-belts-mk7"]['loader1x1'] = 'ddi-loader-mk7'
	BigTableOfBelts["more-belts-mk8"]['loader1x1'] = 'ddi-loader-mk8'
end

---Returns a table with truth values, with the following keys:
--- - ["ForceBuild"] 				Force build.
--- - ["IncludeSplitters"] 		Include splitters when upgrading a belt section.
--- - ["IncludeSideloadingBelts"]	Include upstream belts sideloading onto the belt thread in question.
--- - ["DoSequentialUpgrades"] 	Upgrade entities multiple times as per default upgrade planner.
--- - ["IncludeAllEntities"]		Include all entities in the selection when starting a belt thread upgrade.
---@param playerSettings LuaCustomTable<string, ModSetting>
---@param force boolean True if user wants to include all connected belts regardless of tier, i.e., alternate selection occurred.
---@return table<string, boolean> returnTable The table built from user settings.
local function buildBoolTable(playerSettings, force)
	returnTable = {}

	returnTable["ForceBuild"] = force or false
	returnTable["IncludeSplitters"] = playerSettings["PCPBU-bool-splitters-included-setting"].value
	returnTable["IncludeSideloadingBelts"] = playerSettings["PCPBU-bool-sideloading-belts-included-setting"].value
	returnTable["IncludeAllEntities"] = playerSettings["PCPBU-bool-upgrade-all-selected-threads-setting"].value
	returnTable["DoSequentialUpgrades"] = playerSettings["PCPBU-bool-sequential-upgrades-allowed-setting"].value

	return returnTable
end

-- Builds a table consisting of the relevant belt tier.

---Builds a table consisting of the relevant belt tier.
---@param beltEntity LuaEntity The belt entity to determine the tier of.
---@return table<string, string>? tier The table containing all transport belt entity names of that tier, or nil if not supported.
local function buildBeltTierTable(beltEntity)
	local LuaEntityPrototype prototype = beltEntity.prototype
	if beltEntity.to_be_upgraded() then
		prototype = beltEntity.get_upgrade_target()
	end
	local beltName = prototype.name
	if (beltGraph.isGhost(beltEntity)) then
		beltName = beltEntity.ghost_name
	end
	for _, tier in pairs(BigTableOfBelts) do
		for _, val in pairs(tier) do
			if (val == beltName) then
				if (VERBOSE > 1) then
					local outString = "Working with tier: ["
					for key, name in pairs(tier) do
						outString = outString .. ", " .. name
					end
					outString = outString .. "]"
					game.print({"", outString})
					log({"", outString})
				end
				return tier
			end
		end
	end
	game.print({"", "Belts of type \"", beltName, "\" are not yet supported for tier-based upgrades. Please contact the Belt Thread Upgrades mod author."})
	log({"", "Belt of type ", beltName, " not supported."})
	return nil
end

---Recursively finds the set of transport belt connectables connected to `belt`.
---@param belt LuaEntity The TransportBeltConnectablePrototype from which to start the search.
---@param beltEntitiesToReturn table<int, LuaEntity> Usually initialised to {}, but can be used to append `belt`'s network onto another set of TransportBeltConnectablePrototypes.
---@param truthTable table<string, boolean> Table of boolean values as produced by `buildBoolTable()`, used for configuration of the function.
---@return table<int, LuaEntity> beltEntitiesToReturn Table of each entity of typ TransportBeltConnectablePrototype in the network of `belt`, as bound by user settings.
local function findAllConnectedBelts(belt, beltEntitiesToReturn, truthTable)
	-- Initialise return table if it doesn't exist
	beltEntitiesToReturn = beltEntitiesToReturn or {}

	if (VERBOSE > 1) then
		game.print({"", "Starting search for connected belts at ", serpent.block(belt)})
		log({"", "Starting search for connected belts at ", serpent.block(belt)})
	end
	-- Determine the tier of the belt to search on.
	local relBeltTier = buildBeltTierTable(belt)
	if relBeltTier == nil then
		return {}
	end
	if (VERBOSE > 2) then
		log({"", "Belt tier table:"})
		for key, val in pairs(relBeltTier) do
			log({"", key, ": ", val})
		end
	end

	beltEntitiesToReturn[belt.unit_number] = belt
	
	-- Build upstream network
	beltEntitiesToReturn = beltGraph.findUpstreamNetwork(belt, beltEntitiesToReturn, relBeltTier, truthTable)
	local up = 0
	if (VERBOSE > 2) then
		up = table_size(beltEntitiesToReturn) - 1
		game.print({"", "Found ", up, " upstream belt connections."})
		log({"", "Found ", up, " upstream belt connections."})
	end
	
	-- Build downstream network
	beltEntitiesToReturn = beltGraph.findDownstreamNetwork(belt, beltEntitiesToReturn, relBeltTier, truthTable)
	if beltGraph.getType(belt) == "underground-belt" and belt.neighbours ~= nil then
		beltEntitiesToReturn = beltGraph.findDownstreamNetwork(belt.neighbours, beltEntitiesToReturn, relBeltTier, truthTable)
	end
	if (VERBOSE > 2) then
		local down = table_size(beltEntitiesToReturn) - up
		game.print({"", "Found ", down, " downstream belt connections."})
		log({"", "Found ", down, " downstream belt connections."})
	end
	return beltEntitiesToReturn;
end

---Find the downgrade target for an entity, if one exists.
---@param entityPrototype LuaEntity The entity in question.
---@return LuaEntityPrototype? val Nil or the prototype that upgrades to `entityPrototype`.
local function findDownGradeTarget(entityPrototype)
	local eType = entityPrototype.type
	local eName = entityPrototype.name
	if (beltGraph.isGhost(entityPrototype)) then
		eType = entityPrototype.ghost_type
		eName = entityPrototype.ghost_name
	end
	local options = prototypes.get_entity_filtered{{filter="type", type = eType}}
	for _, val in pairs(options) do
		if (VERBOSE > 2) then
			log({"", "Checking ", val, " of type ", eType, " for downgrade targets."})
		end
		if (val.next_upgrade~= nil and val.next_upgrade.name == eName) then
			return val
		end
	end
	return nil
end

---Builds a belt network and upgrades the entities in the network.
---@param event LuaEventType The game event that raised this function, used for player values.
---@param truthTable table<string, boolean> A table containing various boolean settings, used to control building the belt network.
local function UpgradeBeltNetwork(event, truthTable)
	local thisPlayer = game.players[event.player_index]
	local transportBeltEntitiesToUpgrade = {}
	if thisPlayer.connected and table_size(event.entities) > 0 and thisPlayer.controller_type ~= defines.controllers.ghost then
        if (truthTable["IncludeAllEntities"] and table_size(event.entities) > 1) then
			if (VERBOSE > 0) then
				game.print({"", "Selection has the following entities:", serpent.block(event.entities)})
				log({"", "Selection has the following entities:", serpent.block(event.entities)})
			end
			for _, entity in pairs(event.entities) do
				local beltPrototype = entity.prototype
				if (beltGraph.isGhost(entity)) then
					beltPrototype = entity.ghost_prototype
				end
				if (beltPrototype.next_upgrade ~= nil or truthTable["ForceBuild"]) then
					transportBeltEntitiesToUpgrade = findAllConnectedBelts(entity, transportBeltEntitiesToUpgrade, truthTable)
				end
			end
			if (VERBOSE > 1) then
				game.print({"", table_size(transportBeltEntitiesToUpgrade), " entities to upgrade."})
				log({"", table_size(transportBeltEntitiesToUpgrade), " entities to upgrade."})
				log({"", "These entities are:"})
				for key, val in pairs(transportBeltEntitiesToUpgrade) do
					log({"", serpent.block(key), ": ", serpent.block(val)})
				end
			end
		else
			local initialBelt = event.entities[1]
			if (VERBOSE > 2) then
				game.print({"", "Selection has the following items:"})
				log({"", "Selection has the following items:"})
				for key, value in pairs(event.entities) do
					game.print({"", key, " : ", value})
					log({"", key, " : ", value})
				end
			end
			local beltName = initialBelt.name
			local beltType = initialBelt.type
			local beltPrototype = initialBelt.prototype
			if (beltGraph.isGhost(initialBelt)) then
				beltName = initialBelt.ghost_name
				beltType = initialBelt.ghost_type
				beltPrototype = initialBelt.ghost_prototype
			end

			if (beltPrototype.next_upgrade == nil) then
				if (VERBOSE > 2) then
					game.print({"", "Selected item has prototype ", beltName})
					game.print({"", "Selected item has no specified next upgrade."})
					log({"", "Selected item has prototype ", beltName})
					log({"", "Selected item has no specified next upgrade."})
				end
				return
			end
			if (VERBOSE > 2) then
				game.print({"", "Selected item has prototype name ", beltName})
				game.print({"", "Selected item has type name ", beltType})
				game.print({"", "Selected item has next upgrade ", beltPrototype.next_upgrade.name})
				log({"", "Selected item has prototype ", beltName})
				log({"", "Selected item has type name ", beltType})
				log({"", "Selected item has next upgrade ", beltPrototype.next_upgrade.name})
			end

			transportBeltEntitiesToUpgrade = findAllConnectedBelts(initialBelt, {}, truthTable)

			if (VERBOSE > 1) then
				game.print({"", table_size(transportBeltEntitiesToUpgrade), " entities to upgrade."})
				log({"", table_size(transportBeltEntitiesToUpgrade), " entities to upgrade."})
				log({"", "These entities are:"})
				for _, val in pairs(transportBeltEntitiesToUpgrade) do
					log(serpent.block(val))
				end
			end
			if (table_size(transportBeltEntitiesToUpgrade) > 2000 and not truthTable["ForceBuild"]) then
				game.print("Gammro says: \"Have you considered using trains?\"")
			end
		end

		for _, belt in pairs(transportBeltEntitiesToUpgrade) do
			if (VERBOSE > 2) then
				log({"", "Upgrading the following entity:"})
				log(serpent.block(belt))
			end
			local nextUpgrade
			if (beltGraph.isGhost(belt)) then
				nextUpgrade = belt.ghost_prototype.next_upgrade
			else
				nextUpgrade = belt.prototype.next_upgrade
				if (belt.to_be_upgraded()) then
					nextUpgrade = belt.get_upgrade_target().next_upgrade
				end
			end
			if (nextUpgrade ~= nil) then
				belt.order_upgrade({target=nextUpgrade, force=thisPlayer.force_index, player=thisPlayer, item_index=1})
			end
		end
	end
end

---Builds a belt network and downgrades the entities in the network.
---@param event LuaEventType The game event that raised this function, used for player values.
---@param truthTable table<string, boolean>ble A table containing various boolean settings, used to control building the belt network.
local function DowngradeBeltNetwork(event, truthTable)
	local thisPlayer = game.players[event.player_index]
	local transportBeltEntitiesToDowngrade = {}
    if thisPlayer.connected and table_size(event.entities) > 0 and thisPlayer.controller_type ~= defines.controllers.ghost then
        if (truthTable["IncludeAllEntities"] and table_size(event.entities) > 1) then
			for _, entity in pairs(event.entities) do
				transportBeltEntitiesToDowngrade = findAllConnectedBelts(entity, transportBeltEntitiesToDowngrade, truthTable)
			end
		else
			local initialBelt = event.entities[1]
			if (VERBOSE > 2) then
				game.print({"", "Selection has the following items:"})
				log({"", "Selection has the following items:"})
				for key, value in pairs(event.entities) do
					game.print({"", key, " : ", value})
					log({"", key, " : ", value})
				end
			end
			
			if (VERBOSE > 2) then
				game.print({"", "Selected item has prototype name ", initialBelt.name})
				game.print({"", "Selected item has type name ", initialBelt.type})
				if (initialBelt.prototype.next_upgrade ~= nil) then
					game.print({"", "Selected item has next upgrade ", initialBelt.prototype.next_upgrade.name})
				end
				log({"", "Selected item has prototype ", initialBelt.name})
				log({"", "Selected item has type name ", initialBelt.type})
				if (initialBelt.prototype.next_upgrade ~= nil) then
					log({"", "Selected item has next upgrade ", initialBelt.prototype.next_upgrade.name})
				end
			end
			
			transportBeltEntitiesToDowngrade = findAllConnectedBelts(initialBelt, {}, truthTable)
			if (VERBOSE > 1) then
				game.print({"", table_size(transportBeltEntitiesToDowngrade), " entities to downgrade."})
				log({"", table_size(transportBeltEntitiesToDowngrade), " entities to downgrade."})
				log({"", "These entities are:"})
				for _, val in pairs(transportBeltEntitiesToDowngrade) do
					log(serpent.block(val))
				end
			end
			if (table_size(transportBeltEntitiesToDowngrade) > 2000 and not truthTable["ForceBuild"]) then
				game.print("Gammro says: \"Have you considered using trains?\"")
			end
		end
		
		local downgradeCache = {}
		for _, belt in pairs(transportBeltEntitiesToDowngrade) do
			if (VERBOSE > 2) then
				log({"", "Downgrading the following entity:"})
				log(serpent.block(belt))
			end
			local nextDowngrade
			local beltName = belt.name
			local beltFilter = belt
			if (belt.to_be_upgraded()) then
				beltName = belt.get_upgrade_target().name
				beltFilter = belt.get_upgrade_target()
			end
			if (downgradeCache[beltName] == nil) then
				nextDowngrade = findDownGradeTarget(beltFilter)
			else
				nextDowngrade = downgradeCache[beltName]
			end
			if (nextDowngrade ~= nil) then
				belt.order_upgrade({target=nextDowngrade, force=thisPlayer.force_index, player=thisPlayer, item_index=1})
			end
		end
	end
end

---Builds a network of belts to remove.
---@param event LuaEventType The game event that raised this function, used for player values.
---@param ForceBuild boolean True if belts connected to the selection is to be removed, or if only belts made redundant by the removal of the selection is to be removed.
local function RemoveBeltNetwork(event, ForceBuild)
	local thisPlayer = game.players[event.player_index]
	local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), ForceBuild)
	local transportBeltEntitiesToRemove = {}

    if thisPlayer.connected and table_size(event.entities) > 0 and thisPlayer.controller_type ~= defines.controllers.ghost then
        
		-- Case: collecting the entire network
		if (ForceBuild) then
			if (truthTable["IncludeAllEntities"]) then
				for _, entity in pairs(event.entities) do
					transportBeltEntitiesToRemove = findAllConnectedBelts(entity, transportBeltEntitiesToRemove, truthTable)
				end
			else
				local initialBelt = event.entities[1]
				transportBeltEntitiesToRemove = findAllConnectedBelts(initialBelt, {}, truthTable)
			end

		-- Case: collecting only redundant belts if initial belt is 
		else
			local belts = {}
			if (truthTable["IncludeAllEntities"]) then
				belts = event.entities
				
			else
				belts = {event.entities[1]}
			end

			for _, entity in pairs(belts) do
				local relBeltTier = buildBeltTierTable(entity)
				if relBeltTier == nil then
					return
				end

				local beltType = entity.type
				if (beltGraph.isGhost(entity)) then
					beltType = entity.ghost_type
				end

				transportBeltEntitiesToRemove[entity.unit_number] = entity
				-- Check in the downstream direction
				for _, conBelt in pairs(entity.belt_neighbours["outputs"]) do
					transportBeltEntitiesToRemove = beltGraph.findRedundantNetwork(conBelt, transportBeltEntitiesToRemove, relBeltTier, true)
				end

				-- Check in the upstream direction
				for _, conBelt in pairs(entity.belt_neighbours["inputs"]) do
					transportBeltEntitiesToRemove = beltGraph.findRedundantNetwork(conBelt, transportBeltEntitiesToRemove, relBeltTier, false)
				end

				if beltType == "underground-belt" then
					-- Determine direction of neighbour:
					if entity.neighbours ~= nil then
						local outLocal = table_size(entity.belt_neighbours["outputs"])
						local outNeighbour = table_size(entity.neighbours.belt_neighbours["outputs"])

						-- Case: Flow is from local to neighbour
						if (outNeighbour > 0 and not (outLocal > 0)) then
							-- Search downstream from neighbour
							transportBeltEntitiesToRemove = beltGraph.findRedundantNetwork(entity.neighbours, transportBeltEntitiesToRemove, relBeltTier, true)

						-- Case: Flow is from neighbour to local
						elseif (outLocal > 0 and not (outNeighbour > 0)) then
							-- Search upstream from neighbour
							transportBeltEntitiesToRemove = beltGraph.findRedundantNetwork(entity.neighbours, transportBeltEntitiesToRemove, relBeltTier, false)
						-- Case: No flow between neighbours.
						-- else
							-- do nothing
						end
					end
				end
			end
		end
		
		if (VERBOSE > 2) then
			game.print({"", "Player with force_index ", thisPlayer.force_index, " removing " , table_size(transportBeltEntitiesToRemove), " belts."})
			log({"", "Player with force_index ", thisPlayer.force_index, " removing " , table_size(transportBeltEntitiesToRemove), " belts."})
		end	

		-- For each belt in graph, order deconstruction
		for _, belt in pairs(transportBeltEntitiesToRemove) do
			if (VERBOSE > 2) then
				log({"", "Removing the following entity:"})
				log(serpent.block(belt))
			end
			belt.order_deconstruction(thisPlayer.force_index, thisPlayer)
		end
	end
end

--- Recursively find all connected pipe-like entities connected to pipeEntity
---@param pipeEntity LuaEntity The belt from which to start the search.
---@param pipeEntitiesToReturn table<int, LuaEntity> The table of entities collected and returned at the end.
---@param ForceRemove boolean If true, remove all connected pipes, otherwise end recursion if a pipe has three or more connections.
local function findAllConnectedPipes(pipeEntity, pipeEntitiesToReturn, ForceRemove)
	-- If the pipe has been visited before, ignore and move on.
	if pipeEntitiesToReturn[pipeEntity.unit_number] ~= nil then
		return pipeEntitiesToReturn
	end

	local connectedPipelikes = pipeEntity.fluidbox.get_connections(1)
	if (table_size(connectedPipelikes) > 2 and not ForceRemove) then
		return pipeEntitiesToReturn
	end

	pipeEntitiesToReturn[pipeEntity.unit_number] = pipeEntity
	for _, fluidBox in pairs(connectedPipelikes) do
		local boxOwnerType = fluidBox.owner.type
		if beltGraph.isGhost(fluidBox.owner) then
			boxOwnerType = fluidBox.owner.ghost_type
		end
		if pipeSelectionTypeFilter[boxOwnerType] then
			if pipeEntitiesToReturn[fluidBox.owner.unit_number] == nil then
				pipeEntitiesToReturn = findAllConnectedPipes(fluidBox.owner, pipeEntitiesToReturn, ForceRemove)
			end
		end
	end

	return pipeEntitiesToReturn

end

--- Finds all pipelike entities connected to the selected pipes and marks them for deconstruction.
---@param event LuaEventType The game event that raised this function, used for player values.
---@param ForceBuild boolean True if all lines connected to the selection is to be removed, or if only lines made redundant by the removal of the selection is to be removed.
local function RemovePipes(event, ForceBuild)
	local thisPlayer = game.players[event.player_index]
	local pipeEntitiesToRemove = {}
	if thisPlayer.connected and table_size(event.entities) > 0 and thisPlayer.controller_type ~= defines.controllers.ghost then
		local pipeEntities = event.entities
		for _, entity in pairs(pipeEntities) do
			pipeEntitiesToRemove = findAllConnectedPipes(entity, pipeEntitiesToRemove, ForceBuild)
		end

		if VERBOSE > 1 then
			log({"", "Found ", table_size(pipeEntitiesToRemove), " pipe-like entities to remove."})
			game.print({"", "Found ", table_size(pipeEntitiesToRemove), " pipe-like entities to remove."})
		end

		-- For each pipe in graph, order deconstruction
		for _, pipeEntity in pairs(pipeEntitiesToRemove) do
			if (VERBOSE > 2) then
				log({"", "Removing the following entity:"})
				log(serpent.block(pipeEntity))
			end
			pipeEntity.order_deconstruction(thisPlayer.force_index, thisPlayer)
		end
	end
end

script.on_event({defines.events.on_player_selected_area}, function(event)
    if event.item == 'beltThreadUpgrader-upgrade-tool' then
		local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), false)
        UpgradeBeltNetwork(event, truthTable)
	elseif event.item == 'beltThreadUpgrader-remove-tool' then
		RemoveBeltNetwork(event, false)
	end
end)

script.on_event({defines.events.on_player_alt_selected_area}, function(event)
    if event.item == 'beltThreadUpgrader-upgrade-tool' then
        local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), true)
        UpgradeBeltNetwork(event, truthTable)
	elseif event.item == 'beltThreadUpgrader-remove-tool' then
		RemoveBeltNetwork(event, true)
	end
end)

script.on_event({defines.events.on_player_reverse_selected_area}, function(event)
	if event.item == 'beltThreadUpgrader-upgrade-tool' then
        local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), false)
		DowngradeBeltNetwork(event, truthTable)
	elseif event.item == 'beltThreadUpgrader-remove-tool' then
		RemovePipes(event, false)
	end
end)

script.on_event({defines.events.on_player_alt_reverse_selected_area}, function(event)
	if event.item == 'beltThreadUpgrader-upgrade-tool' then
        local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), true)
		DowngradeBeltNetwork(event, truthTable)
	elseif event.item == 'beltThreadUpgrader-remove-tool' then
		RemovePipes(event, true)
	end
end)