local beltGraph = require("scripts/belt-graph")

local VERBOSE = 0

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
BigTableOfBelts["advanced-transport-belt"] = {["transport-belt"] = "kr-advanced-transport-belt", ["underground-belt"] = "kr-advanced-underground-belt", ["splitter"] = "kr-advanced-splitter", ["loader1x1"] = "kr-advanced-loader"} -- green
BigTableOfBelts["superior-transport-belt"] = {["transport-belt"] = "kr-superior-transport-belt", ["underground-belt"] = "kr-superior-underground-belt", ["splitter"] = "kr-superior-splitter", ["loader1x1"] = "kr-superior-loader"} -- purple

-- Quantum Belts (https://mods.factorio.com/mod/quantum-belts)
BigTableOfBelts["quantum-transport-belt"] = {["transport-belt"] = "quantum-belt", ["underground-belt"] = "quantum-underground", ["splitter"] = "quantum-splitter"} -- magenta

if (script.active_mods['aai-loaders']) then
	BigTableOfBelts["transport-belt"]["loader1x1"] = "aai-loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x1"] = "aai-fast-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x1"] = "aai-express-loader"
	BigTableOfBelts["turbo-transport-belt"]["loader1x1"] = "aai-turbo-loader"
end

if (script.active_mods['Krastorio2'] or script.active_mods['Krastorio2-spaced-out']) then
	BigTableOfBelts["transport-belt"]["loader1x1"] = "kr-loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x1"] = "kr-fast-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x1"] = "kr-express-loader"
end

if (script.active_mods['5dim_transport']) then
	BigTableOfBelts["transport-belt"]["loader1x1"] = "5d-loader-1x1-01"
	BigTableOfBelts["fast-transport-belt"]["loader1x1"] = "5d-loader-1x1-02"
	BigTableOfBelts["express-transport-belt"]["loader1x1"] = "5d-loader-1x1-03"
	BigTableOfBelts["transport-belt"]["loader1x2"] = "loader"
	BigTableOfBelts["fast-transport-belt"]["loader1x2"] = "fast-loader"
	BigTableOfBelts["express-transport-belt"]["loader1x2"] = "express-loader"
end

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

-- Returns a table with truth values
-- ["ForceBuild"] 				Force build 
-- ["IncludeSplitters"] 		Include splitters when upgrading a belt section
-- ["IncludeSideloadingBelts"]	Include upstream belts sideloading onto the belt thread in question.
-- ["DoSequentialUpgrades"] 	Upgrade entities multiple times as per default upgrade planner
-- ["IncludeAllEntities"]		Include all entities in the selection when starting a belt thread upgrade
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
local function buildBeltTierTable(beltEntity)
	if beltEntity.to_be_upgraded() then
		beltEntity = beltEntity.get_upgrade_target()
	end
	local beltName = beltEntity.name
	if (beltGraph.isGhost(beltEntity)) then
		beltName = beltEntity.ghost_name
	end
	for _, value in pairs(BigTableOfBelts) do
		for _, val in pairs(value) do
			if (val == beltName) then
				if (VERBOSE > 1) then
					game.print({"", "Working with tier: [", value["transport-belt"], ", ", value["underground-belt"], ", ", value["splitter"], ", ", value["loader1x1"],", ", value["loader1x2"], "]"})
					log({"", "Working with tier: [", value["transport-belt"], ", ", value["underground-belt"], ", ", value["splitter"], ", ", value["loader1x1"],", ", value["loader1x2"], "]"})
				end
				return value
			end
		end
	end
	game.print({"", "Belts of type \"", beltName, "\" are not yet supported for tier-based upgrades. Please contact the Belt Thread Upgrades mod author."})
	log({"", "Belt of type ", beltName, " not supported."})
	return nil
end

-- Recursively finds the set of transport belts and underground belts connected to belt.
-- @param belt The belt from which to start the search.
-- 	    :@type LuaEntity
-- @param truthTable Table of boolean values as produced by buildBoolTable(), used for configuration of the function.
-- 	    :@type LuaTable
-- @return Table of each transportBeltConnectable in the network of belt, as bound by 
--      :@type {LuaEntity}
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
	if (VERBOSE > 2) then
		local down = table_size(beltEntitiesToReturn) - up
		game.print({"", "Found ", down, " downstream belt connections."})
		log({"", "Found ", down, " downstream belt connections."})
	end
	return beltEntitiesToReturn;
end

-- Find the downgrade target for an entity, if one exists.
-- @param entityPrototype The entity in question
--		:type LuaEntity
-- @return Nil or the prototype that upgrades to entityPrototype
--		:type LuaEntityPrototype
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

-- Builds a belt network and upgrades the entities in the network
-- @param event The game event that raised this function, used for player values.
--		:type defines.events
-- @param truthTable A table containing various boolean settings, used to control building the belt network
--		:type LuaTable
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

-- Builds a belt network and downgrades the entities in the network
-- @param event The game event that raised this function, used for player values.
--		:type defines.events
-- @param truthTable A table containing various boolean settings, used to control building the belt network
--		:type LuaTable
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

script.on_event({defines.events.on_player_selected_area}, function(event)
    if event.item == 'beltThreadUpgrader-selection-tool' then
		local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), false)
        UpgradeBeltNetwork(event, truthTable)
    end
end)

script.on_event({defines.events.on_player_alt_selected_area}, function(event)
    if event.item == 'beltThreadUpgrader-selection-tool' then
        local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), true)
        UpgradeBeltNetwork(event, truthTable)
    end
end)

script.on_event({defines.events.on_player_reverse_selected_area}, function(event)
	if event.item == 'beltThreadUpgrader-selection-tool' then
        local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), false)
		DowngradeBeltNetwork(event, truthTable)
		
	end
end)

script.on_event({defines.events.on_player_alt_reverse_selected_area}, function(event)
	if event.item == 'beltThreadUpgrader-selection-tool' then
        local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), true)
		DowngradeBeltNetwork(event, truthTable)
	end
end)