local VERBOSE = 0

local BigTableOfBelts = {}
-- Base game
BigTableOfBelts["transport-belt"] = {["transport-belt"] = "transport-belt", ["underground-belt"] = "underground-belt", ["splitter"] = "splitter"}
BigTableOfBelts["fast-transport-belt"] = {["transport-belt"] = "fast-transport-belt", ["underground-belt"] = "fast-underground-belt", ["splitter"] = "fast-splitter"}
BigTableOfBelts["express-transport-belt"] = {["transport-belt"] = "express-transport-belt", ["underground-belt"] = "express-underground-belt", ["splitter"] = "express-splitter"}

-- Space Age
BigTableOfBelts["turbo-transport-belt"] = {["transport-belt"] = "turbo-transport-belt", ["underground-belt"] = "turbo-underground-belt", ["splitter"] = "turbo-splitter"}

local findUpstreamNetwork, findDownstreamNetwork

-- Returns a table with truth values
-- ["ForceBuild"] 				Force build 
-- ["IncludeSplitters"] 		Include splitters
-- ["IncludeGhosts"]			Include ghosts of appropriate type
-- ["IncludeSideloadingBelts"]	Include upstream belts sideloading onto the belt thread in question.
-- ["DoSequentialUpgrades"] 	Upgrade entities multiple times as per default upgrade planner
local function buildBoolTable(playerSettings, force)
	returnTable = {}

	returnTable["ForceBuild"] = force or false
	returnTable["IncludeSplitters"] = playerSettings["PCPBU-bool-splitters-included-setting"].value
	returnTable["IncludeGhosts"] = playerSettings["PCPBU-bool-ghosts-included-setting"].value
	returnTable["IncludeSideloadingBelts"] = playerSettings["PCPBU-bool-sideloading-belts-included-setting"].value
	returnTable["DoSequentialUpgrades"] = playerSettings["PCPBU-bool-sequential-upgrades-allowed-setting"].value

	return returnTable
end

-- Recursively finds the set of transport belts and underground belts connected upstream of belt.
-- @param belt The belt from which to start the search.
-- 	    :@type LuaEntity
-- @param beltEntitiesToReturn The table of entities collected and returned at the end.
-- 	    :@type LuaEntity
-- @param relBeltTable The table consisting of the belt tier to add to the graph.
-- 	    :@type LuaTable
-- @param truthTable Table of boolean values as produced by buildBoolTable(), used for configuration of the function.
-- 	    :@type LuaTable
-- @return Table of each transportBeltConnectable in the network of belt, as bound by 
--      :@type {LuaEntity}
findUpstreamNetwork = function(belt, beltEntitiesToReturn, relBeltTable, truthTable)
	-- Default value for forceDisregardTier is false
	local forceDisregardTier = truthTable["ForceBuild"] or false
	
	local connectedBelts = {}
	-- Add upstream belt neighbours to list to check
	local inputs = belt.belt_neighbours["inputs"]
	for _, val in pairs(inputs) do
		if not (truthTable["IncludeSideloadingBelts"] or forceDisregardTier) and table_size(inputs) > 1 then
			if (belt.direction == val.direction) then
				connectedBelts[val.unit_number] = val
			end
		else
			connectedBelts[val.unit_number] = val
		end
	end
	
	-- If underground-belt, add other end if it exists
	if (belt.type == "underground-belt") then
		local UGBeltEnd = belt.neighbours
		if (UGBeltEnd ~= nil) then			
			connectedBelts[UGBeltEnd.unit_number] = UGBeltEnd
		end
	end
	
	-- If we have no upstream neighbours of either belt or undergrounds, i.e., connectedBelts is empty, return.
	if (table_size(connectedBelts) == 0) then
		if (VERBOSE > 2) then
			game.print({"", "Selected item has no neighbours."})
		end
		if (VERBOSE > 2) then
			log({"", "Selected item has no neighbours."})
			log({"", "Returning itself to final list."})
			log({"", "These entities are:"})
			log(serpent.block(beltEntitiesToReturn))
		end
		return beltEntitiesToReturn
	end
	
	-- Iterate over connectedBelts
	for cBUnitNumber, conBelt in pairs(connectedBelts) do
		-- If conBelt is not in final list already
		if (beltEntitiesToReturn[cBUnitNumber] == nil) then
			conBeltName = conBelt.name
			-- Case: we're force collecting everything in the network
			if (forceDisregardTier) then
				beltEntitiesToReturn[cBUnitNumber] = conBelt
				beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
				
				-- Splitters can have multiple outputs, so traverse that direction as well -- only one extraneous check
				if (conBelt.type == "splitter") then
					beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
				end

			-- Case: Building network on one tier only, specified in relBeltTable
			else
				-- Case: conBelt is marked for upgrade
				if (conBelt.to_be_upgraded() and truthTable["DoSequentialUpgrades"] == true) then
					local targetName = conBelt.get_upgrade_target().name
					if (conBelt.type == "splitter") then
						if (truthTable["IncludeSplitters"] == true and relBeltTable["splitter"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end
				
					-- Case: conBelt is underground-belt, if of the right tier, add, continue recursion
					elseif (conBelt.type == "underground-belt") then
						if (relBeltTable["underground-belt"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					
					-- Case: conBelt
					elseif (conBelt.type == "transport-belt") then
						if (relBeltTable["transport-belt"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					-- Case: not transport belt, underground, or splitter... oops!
					else
						game.print("Something has gone wrong with building the belt graph, please contact the mod author.")
					end
				
				-- Case: conBelt is not marked for upgrade
				else
					if (conBelt.type == "splitter") then
						if (relBeltTable["splitter"] == conBeltName and truthTable["IncludeSplitters"] == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end
				
					-- Case: conBelt is underground-belt, if of the right tier, add, continue recursion
					elseif (conBelt.type == "underground-belt") then
						if (relBeltTable["underground-belt"] == conBeltName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					
					-- Case: conBelt
					elseif (conBelt.type == "transport-belt") then
						if (relBeltTable["transport-belt"] == conBeltName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					-- Case: not transport belt, underground, or splitter... oops!
					else
						game.print("Something has gone wrong with building the belt graph, please contact the mod author.")
					end
				end
			
			-- Case: conBelt is not of same tier and not marked to upgrade, ignore.
			end
		
		-- else, conBelt has been traversed before, ignore.
		end
	end
	
	return beltEntitiesToReturn
end

-- Recursively finds the set of transport belts and underground belts connected upstream of belt.
-- @param belt The belt from which to start the search.
-- 	    :@type LuaEntity
-- @param beltEntitiesToReturn The table of entities collected and returned at the end.
-- 	    :@type LuaEntity
-- @param relBeltTable The table consisting of the belt tier to add to the graph.
-- 	    :@type LuaTable
-- @param truthTable Table of boolean values as produced by buildBoolTable(), used for configuration of the function.
-- 	    :@type LuaTable
-- @return Table of each transportBeltConnectable in the network of belt, as bound by 
--      :@type {LuaEntity}
findDownstreamNetwork = function(belt, beltEntitiesToReturn, relBeltTable, truthTable)
	-- Default value for forceDisregardTier is false
	local forceDisregardTier = truthTable["ForceBuild"] or false
	
	local connectedBelts = {}
	-- Add downstream belt neighbours to list to check
	for _, val in pairs(belt.belt_neighbours["outputs"]) do
		connectedBelts[val.unit_number] = val
	end
	
	-- If underground-belt, add other end if it exists
	if (belt.type == "underground-belt") then
		local UGBeltEnd = belt.neighbours
		if (UGBeltEnd ~= nil) then			
			connectedBelts[UGBeltEnd.unit_number] = UGBeltEnd
		end
	end
	
	-- If we have no downstream neighbours of either belt or undergrounds, i.e., connectedBelts is empty, return.
	if (table_size(connectedBelts) == 0) then
		if (VERBOSE > 2) then
			game.print({"", "Selected item has no neighbours."})
		end
		if (VERBOSE > 2) then
			log({"", "Selected item has no neighbours."})
			log({"", "Returning itself to final list."})
			log({"", "These entities are:"})
			log(serpent.block(beltEntitiesToReturn))
		end
		return beltEntitiesToReturn
	end
	
	-- Iterate over connectedBelts
	for cBUnitNumber, conBelt in pairs(connectedBelts) do
		-- If conBelt is not in final list already
		if (beltEntitiesToReturn[cBUnitNumber] == nil) then
			conBeltName = conBelt.name
			-- Case: we're force collecting everything in the network
			if (forceDisregardTier) then
				beltEntitiesToReturn[cBUnitNumber] = conBelt
				beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
				
				-- Splitters can have multiple inputs, so traverse that direction as well -- only one extraneous check
				if (conBelt.type == "splitter") then
					beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
				end

			-- Case: Building network on one tier only, specified in relBeltTable
			-- 		 By default, this implies we only go to the next splitter.
			else
				-- Case: conBelt is marked for upgrade
				if (conBelt.to_be_upgraded() and truthTable["DoSequentialUpgrades"] == true) then
					local targetName = conBelt.get_upgrade_target().name
					
					-- Case: conBelt is splitter, if upgrade target of right tier and settings allow, add
					if (conBelt.type == "splitter") then
						if (truthTable["IncludeSplitters"] == true and relBeltTable["splitter"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end
				
					-- Case: conBelt is underground-belt, if upgrade target of the right tier, add, continue recursion
					elseif (conBelt.type == "underground-belt") then
						if (relBeltTable["underground-belt"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					
					-- Case: conBelt is transport-belt, if upgrade target of the right tier, add, continue recursion
					elseif (conBelt.type == "transport-belt") then
						if (relBeltTable["transport-belt"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					-- Case: not transport belt, underground, or splitter... oops!
					else
						game.print("Something has gone wrong with building the belt graph, please contact the mod author.")
					end
				
				-- Case: conBelt is not marked for upgrade
				else
					-- Case: conBelt is splitter, if of right tier and settings allow, add
					if (conBelt.type == "splitter") then
						if (VERBOSE > 2) then
							log({"", "Comparing ", relBeltTable["splitter"] , " and ", conBeltName})
						end
						if (relBeltTable["splitter"] == conBeltName and truthTable["IncludeSplitters"] == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end
				
					-- Case: conBelt is underground-belt, if of the right tier, add, continue recursion
					elseif (conBelt.type == "underground-belt") then
						if (VERBOSE > 2) then
							log({"", "Comparing ", relBeltTable["underground-belt"], " and ", conBeltName})
						end
						if (relBeltTable["underground-belt"] == conBeltName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					
					-- Case: conBelt is transport-belt, if of the right tier, add, continue recursion
					elseif (conBelt.type == "transport-belt") then
						if (VERBOSE > 2) then
							log({"", "Comparing ", relBeltTable["transport-belt"] , " and ", conBeltName})
						end
						if (relBeltTable["transport-belt"] == conBeltName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					-- Case: not transport belt, underground, or splitter... oops!
					else
						game.print("Something has gone wrong with building the belt graph, please contact the mod author.")
					end
				end
			
			-- Case: conBelt is not of same tier and not marked to upgrade, ignore.
			end
		
		-- else, conBelt has been traversed before, ignore.
		end
	end
	
	return beltEntitiesToReturn
end

-- Builds a table consisting of the relevant belt tier.
local function buildBeltTierTable(beltEntity)
	if beltEntity.to_be_upgraded() then
		beltEntity = beltEntity.get_upgrade_target()
	end
	for _, value in pairs(BigTableOfBelts) do
		if (beltEntity.type == "splitter") then
			if (value["splitter"] == beltEntity.name) then
				if (VERBOSE == 1) then
					game.print({"", "Working with tier: [", value["transport-belt"], ", ", value["underground-belt"], ", ", value["splitter"], "]"})
					log({"", "Working with tier: [", value["transport-belt"], ", ", value["underground-belt"], ", ", value["splitter"], "]"})
				end
				return value
			end
		elseif (beltEntity.type == "transport-belt") then
			if (value["transport-belt"] == beltEntity.name) then
				if (VERBOSE == 1) then
					game.print({"", "Working with tier: [", value["transport-belt"], ", ", value["underground-belt"], ", ", value["splitter"], "]"})
					log({"", "Working with tier: [", value["transport-belt"], ", ", value["underground-belt"], ", ", value["splitter"], "]"})
				end
				return value
			end
		elseif (beltEntity.type == "underground-belt") then
			if (value["underground-belt"] == beltEntity.name) then
				if (VERBOSE == 1) then
					game.print({"", "Working with tier: [", value["transport-belt"], ", ", value["underground-belt"], ", ", value["splitter"], "]"})
					log({"", "Working with tier: [", value["transport-belt"], ", ", value["underground-belt"], ", ", value["splitter"], "]"})
				end
				return value
			end
		else
			game.print("Something has gone wrong with building the beltTierTable, please inform the mod author.")
		end
	end
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

	-- Determine the tier of the belt to search on.
	local relBeltTier = buildBeltTierTable(belt)
	if (VERBOSE > 2) then
		log({"", "Belt tier table:"})
		for key, val in pairs(relBeltTier) do
			log({"", key, ": ", val})
		end
	end
	
	if (VERBOSE > 1) then
		game.print({"", "Starting search for at ", serpent.block(belt)})
		log({"", "Starting search for at ", serpent.block(belt)})
	end
	
	beltEntitiesToReturn[belt.unit_number] = belt
	
	if (VERBOSE > 1) then
		local up = 0
		local down = 0
	end
	
	-- Build upstream network
	beltEntitiesToReturn = findUpstreamNetwork(belt, beltEntitiesToReturn, relBeltTier, truthTable)
	if (VERBOSE > 2) then
		up = table_size(beltEntitiesToReturn) - 1
		game.print({"", "Found ", up, " upstream belt connections."})
		log({"", "Found ", up, " upstream belt connections."})
	end
	
	-- Build downstream network
	beltEntitiesToReturn = findDownstreamNetwork(belt, beltEntitiesToReturn, relBeltTier, truthTable)
	if (VERBOSE > 2) then
		down = table_size(beltEntitiesToReturn) - up
		game.print({"", "Found ", down, " downstream belt connections."})
		log({"", "Found ", down, " downstream belt connections."})
	end
	return beltEntitiesToReturn;
end

local function findDownGradeTarget(entityPrototype)
	local options = prototypes.get_entity_filtered{{filter="type", type = entityPrototype.type}}
	for _, val in pairs(options) do
		if (VERBOSE > 2) then
			log({"", "Checking ", val, " of type ", entityPrototype.type, " for downgrade targets."})
		end
		if (val.next_upgrade~= nil and val.next_upgrade.name == entityPrototype.name) then
			return val
		end
	end
	return nil
end

local function UpgradeSameTierConnectedBelts(event)
    local thisPlayer = game.players[event.player_index]
	local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), false)
	local transportBeltEntitiesToUpgrade = {}
	if thisPlayer.connected and table_size(event.entities) > 0 and thisPlayer.controller_type ~= defines.controllers.ghost then
        local initialBelt = event.entities[1]
		if (VERBOSE > 2) then
			game.print({"", "Selection has the following items:"})
			log({"", "Selection has the following items:"})
			for key, value in pairs(event.entities) do
				game.print({"", key, " : ", value})
				log({"", key, " : ", value})
			end
		end
		if (initialBelt.type ~= "transport-belt" and initialBelt.type ~= "underground-belt" and initialBelt.type ~= "splitter") then
			if (VERBOSE > 2) then
				game.print({"", "Selected item has prototype ", initialBelt.name})
				game.print({"", "Selected item is not relevant for this upgrade mode."})
				log({"", "Selected item has prototype ", initialBelt.name})
				log({"", "Selected item is not relevant for this upgrade mode."})
			end
			return
		end
		
		if (initialBelt.prototype.next_upgrade == nil) then
			if (VERBOSE > 2) then
				game.print({"", "Selected item has prototype ", initialBelt.name})
				game.print({"", "Selected item has no specified next upgrade."})
				log({"", "Selected item has prototype ", initialBelt.name})
				log({"", "Selected item has no specified next upgrade."})
			end
			return
		end
		if (VERBOSE > 2) then
			game.print({"", "Selected item has prototype name ", initialBelt.name})
			game.print({"", "Selected item has type name ", initialBelt.type})
			game.print({"", "Selected item has next upgrade ", initialBelt.prototype.next_upgrade.name})
			log({"", "Selected item has prototype ", initialBelt.name})
			log({"", "Selected item has type name ", initialBelt.type})
			log({"", "Selected item has next upgrade ", initialBelt.prototype.next_upgrade.name})
		end
		
		transportBeltEntitiesToUpgrade = findAllConnectedBelts(initialBelt, {}, truthTable)
		
		if (VERBOSE > 1) then
			game.print({"", table_size(transportBeltEntitiesToUpgrade), " entities to upgrade."})
			log({"", table_size(transportBeltEntitiesToUpgrade), " entities to upgrade."})
			log({"", "These entities are:"})
			for key, val in pairs(transportBeltEntitiesToUpgrade) do
				log(serpent.block(val))
			end
		end
		if (table_size(transportBeltEntitiesToUpgrade) > 2000) then
			game.print("Gammro says: \"Have you considered using trains?\"")
		end
		for beltKey, belt in pairs(transportBeltEntitiesToUpgrade) do
			if (VERBOSE > 2) then
				log({"", "Upgrading the following entity:"})
				log(serpent.block(belt))
			end
			local nextUpgrade = belt.prototype.next_upgrade
			if (belt.to_be_upgraded()) then
				nextUpgrade = belt.get_upgrade_target().next_upgrade
			end
			if (nextUpgrade ~= nil) then
				belt.order_upgrade({target=nextUpgrade, force=thisPlayer.force_index, player=thisPlayer, item_index=1})
			end
		end
	end
end

local function UpgradeAllConnectedBelts(event)
    local thisPlayer = game.players[event.player_index]
	local truthTable = buildBoolTable(thisPlayer.mod_settings, true)
	local transportBeltEntitiesToUpgrade = {}
    if thisPlayer.connected and table_size(event.entities) > 0 and thisPlayer.controller_type ~= defines.controllers.ghost then
        local initialBelt = event.entities[1]
		if (VERBOSE > 2) then
			game.print({"", "Selection has the following items:"})
			log({"", "Selection has the following items:"})
			for key, value in pairs(event.entities) do
				game.print({"", key, " : ", value})
				log({"", key, " : ", value})
			end
		end
		local initType = initialBelt.type
		
		-- Must be of a belt type to build network
		if (initType ~= "transport-belt" and initType ~= "underground-belt" and initType ~= "splitter") then
			return
		end
				
		transportBeltEntitiesToUpgrade = findAllConnectedBelts(initialBelt, {}, truthTable)

		for beltKey, belt in pairs(transportBeltEntitiesToUpgrade) do
			if (VERBOSE > 2) then
				log({"", "Upgrading the following entity:"})
				log(serpent.block(belt))
			end
			local nextUpgrade = belt.prototype.next_upgrade
			if (belt.to_be_upgraded()) then
				nextUpgrade = belt.get_upgrade_target().next_upgrade
			end
			if (nextUpgrade ~= nil) then
				belt.order_upgrade({target=nextUpgrade, force=thisPlayer.force_index, player=thisPlayer, item_index=1})
			end
		end
	end
end

local function DowngradeSameTierConnectedBelts(event)
    local thisPlayer = game.players[event.player_index]
	local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), false)
	local transportBeltEntitiesToDowngrade = {}
    if thisPlayer.connected and table_size(event.entities) > 0 and thisPlayer.controller_type ~= defines.controllers.ghost then
        local initialBelt = event.entities[1]
		if (VERBOSE > 2) then
			game.print({"", "Selection has the following items:"})
			log({"", "Selection has the following items:"})
			for key, value in pairs(event.entities) do
				game.print({"", key, " : ", value})
				log({"", key, " : ", value})
			end
		end
		if (initialBelt.type ~= "transport-belt" and initialBelt.type ~= "underground-belt" and initialBelt.type ~= "splitter") then
			if (VERBOSE > 2) then
				game.print({"", "Selected item has prototype ", initialBelt.name})
				game.print({"", "Selected item is not relevant for this upgrade mode."})
				log({"", "Selected item has prototype ", initialBelt.name})
				log({"", "Selected item is not relevant for this upgrade mode."})
			end
			return
		end
		
		if (VERBOSE > 2) then
			game.print({"", "Selected item has prototype name ", initialBelt.name})
			game.print({"", "Selected item has type name ", initialBelt.type})
			game.print({"", "Selected item has next upgrade ", initialBelt.prototype.next_upgrade.name})
			log({"", "Selected item has prototype ", initialBelt.name})
			log({"", "Selected item has type name ", initialBelt.type})
			log({"", "Selected item has next upgrade ", initialBelt.prototype.next_upgrade.name})
		end
		
		transportBeltEntitiesToDowngrade = findAllConnectedBelts(initialBelt, {}, truthTable)
		
		if (VERBOSE > 1) then
			game.print({"", table_size(transportBeltEntitiesToDowngrade), " entities to upgrade."})
			log({"", table_size(transportBeltEntitiesToDowngrade), " entities to upgrade."})
			log({"", "These entities are:"})
			for _, val in pairs(transportBeltEntitiesToDowngrade) do
				log(serpent.block(val))
			end
		end
		if (table_size(transportBeltEntitiesToDowngrade) > 2000) then
			game.print("Gammro says: \"Have you considered using trains?\"")
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

local function DowngradeAllConnectedBelts(event)
    local thisPlayer = game.players[event.player_index]
	local truthTable = buildBoolTable(thisPlayer.mod_settings, true)
	local transportBeltEntitiesToDowngrade = {}
    if thisPlayer.connected and table_size(event.entities) > 0 and thisPlayer.controller_type ~= defines.controllers.ghost then
        local initialBelt = event.entities[1]
		if (VERBOSE > 2) then
			game.print({"", "Selection has the following items:"})
			log({"", "Selection has the following items:"})
			for key, value in pairs(event.entities) do
				game.print({"", key, " : ", value})
				log({"", key, " : ", value})
			end
		end
		local initType = initialBelt.type
		
		-- Must be of a belt type to build network
		if (initType ~= "transport-belt" and initType ~= "underground-belt" and initType ~= "splitter") then
			return
		end
				
		transportBeltEntitiesToDowngrade = findAllConnectedBelts(initialBelt, {}, truthTable)

		for beltKey, belt in pairs(transportBeltEntitiesToDowngrade) do
			if (VERBOSE > 2) then
				log({"", "Upgrading the following entity:"})
				log(serpent.block(belt))
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
end

script.on_event({defines.events.on_player_selected_area}, function(event)
    if event.item == 'beltThreadUpgrader-selection-tool' then
        UpgradeSameTierConnectedBelts(event)
    end
end)

script.on_event({defines.events.on_player_alt_selected_area}, function(event)
    if event.item == 'beltThreadUpgrader-selection-tool' then
        UpgradeAllConnectedBelts(event)
    end
end)

script.on_event({defines.events.on_player_reverse_selected_area}, function(event)
	if event.item == 'beltThreadUpgrader-selection-tool' then
		DowngradeSameTierConnectedBelts(event)
	end
end)

script.on_event({defines.events.on_player_alt_reverse_selected_area}, function(event)
	if event.item == 'beltThreadUpgrader-selection-tool' then
		DowngradeAllConnectedBelts(event)
	end
end)