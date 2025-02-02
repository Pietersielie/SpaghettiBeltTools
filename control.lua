local VERBOSE = 0

local findUpstreamNetwork, findDownstreamNetwork

-- Returns a table with truth values
-- ["ForceBuild"] 		Force build 
-- ["IncludeSplitters"] Include splitters
local function buildBoolTable(playerSettings, force)
	returnTable = {}

	returnTable["ForceBuild"] = force or false
	returnTable["IncludeSplitters"] = playerSettings["PCPBU-bool-splitters-included-setting"].value

	return returnTable
end

-- Recursively finds the set of transport belts and underground belts connected upstream of belt.
-- @param belt The belt from which to start the search.
-- 	    :@type LuaEntity
-- @param beltEntitiesToReturn The table of entities collected and returned at the end.
-- 	    :@type LuaEntity
-- @param relUGBeltName The name of the initial selection's related_underground_belt, used to determine belt tier.
-- 	    :@type string
-- @param truthTable Table of boolean values as produced by buildBoolTable(), used for configuration of the function.
-- 	    :@type LuaTable
-- @return Table of each transportBeltConnectable in the network of belt, as bound by 
--      :@type {LuaEntity}
findUpstreamNetwork = function(belt, beltEntitiesToReturn, relUGBeltName, truthTable)
	-- Default value for forceDisregardTier is false
	local forceDisregardTier = truthTable["ForceBuild"] or false
	
	local connectedBelts = {}
	-- Add upstream belt neighbours to list to check
	for _, val in pairs(belt.belt_neighbours["inputs"]) do
		connectedBelts[val.unit_number] = val
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
				beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relUGBeltName, truthTable)
				
				-- Splitters can have multiple outputs, so traverse that direction as well -- only one extraneous check
				if (conBelt.type == "splitter") then
					beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relUGBeltName, truthTable)
				end

			-- Case: conBelt is underground-belt and same type/tier, add to list and continue recursion
			elseif (conBelt.type == "underground-belt" and conBeltName == relUGBeltName) then
				beltEntitiesToReturn[cBUnitNumber] = conBelt
				beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relUGBeltName, truthTable)
			
			-- Case: conBelt has related_underground_belt same as relUGBeltName
			else
				-- Case: conBelt is splitter, check setting, add if true, end recursion
				if (conBelt.type == "splitter") then
					if (truthTable["IncludeSplitters"] == true) then
						beltEntitiesToReturn[cBUnitNumber] = conBelt
					end
			
				-- Case: conBelt is transport-belt or something else, add, continue recursion
				else
					beltEntitiesToReturn[cBUnitNumber] = conBelt
					beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relUGBeltName, truthTable)
				end
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
-- @param relUGBeltName The name of the initial selection's related_underground_belt, used to determine belt tier.
-- 	    :@type string
-- @param truthTable Table of boolean values as produced by buildBoolTable(), used for configuration of the function.
-- 	    :@type LuaTable
-- @return Table of each transportBeltConnectable in the network of belt, as bound by 
--      :@type {LuaEntity}
findDownstreamNetwork = function(belt, beltEntitiesToReturn, relUGBeltName, truthTable)
	-- Default value for forceDisregardTier is false
	local forceDisregardTier = truthTable["ForceBuild"] or false
	
	local connectedBelts = {}
	-- Add upstream belt neighbours to list to check
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
				beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relUGBeltName, truthTable)
				
				-- Splitters can have multiple inputs, so traverse that direction as well -- only one extraneous check
				if (conBelt.type == "splitter") then
					beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relUGBeltName, truthTable)
				end

			-- Case: conBelt is underground-belt and same type/tier, add to list and continue recursion
			elseif (conBelt.type == "underground-belt" and conBeltName == relUGBeltName) then
				beltEntitiesToReturn[cBUnitNumber] = conBelt
				beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relUGBeltName, truthTable)
			
			-- Case: conBelt has related_underground_belt same as relUGBeltName
			else
				-- Case: conBelt is splitter, check setting, add if true, end recursion
				if (conBelt.type == "splitter") then
					if (truthTable["IncludeSplitters"] == true) then
						beltEntitiesToReturn[cBUnitNumber] = conBelt
					end
			
				-- Case: conBelt is transport-belt or something else, add, continue recursion
				else
					beltEntitiesToReturn[cBUnitNumber] = conBelt
					beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relUGBeltName, truthTable)
				end
			end
		
		-- else, conBelt has been traversed before, ignore.
		end
	end
	
	return beltEntitiesToReturn
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

	-- Determine what the name of the tier's underground belt is.
	local relUGBelt
	if (belt.type == "underground-belt") then
		relUGBelt = belt.name
	else
		relUGBelt = belt.prototype.related_underground_belt.name
	end
	
	if (VERBOSE > 0) then
		game.print({"", "Starting search for at ", serpent.block(belt)})
		log({"", "Starting search for at ", serpent.block(belt)})
	end
	
	beltEntitiesToReturn[belt.unit_number] = belt
	
	if (VERBOSE > 0) then
		local up = 0
		local down = 0
	end
	
	-- Build upstream network
	beltEntitiesToReturn = findUpstreamNetwork(belt, beltEntitiesToReturn, relUGBelt, truthTable)
	if (VERBOSE > 0) then
		up = table_size(beltEntitiesToReturn) - 1
		game.print({"", "Found ", up, " upstream belt connections."})
		log({"", "Found ", up, " upstream belt connections."})
	end
	
	-- Build downstream network
	beltEntitiesToReturn = findDownstreamNetwork(belt, beltEntitiesToReturn, relUGBelt, truthTable)
	if (VERBOSE > 0) then
		down = table_size(beltEntitiesToReturn) - up
		game.print({"", "Found ", down, " downstream belt connections."})
		log({"", "Found ", down, " downstream belt connections."})
	end
	return beltEntitiesToReturn;
end

local function UpgradeSameTierConnectedBelts(event)
    local thisPlayer = game.players[event.player_index]
	local truthTable = buildBoolTable(settings.get_player_settings(event.player_index), false)
	local transportBeltEntitiesToUpgrade = {}
    if thisPlayer.connected and thisPlayer.selected and thisPlayer.controller_type ~= defines.controllers.ghost then
        local initialBelt = thisPlayer.selected
		if (initialBelt.type ~= "transport-belt" and initialBelt.type ~= "underground-belt") then
			if (VERBOSE > 0) then
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
			if (belt.prototype.next_upgrade ~= nil) then
				belt.order_upgrade({target=belt.prototype.next_upgrade, force=thisPlayer.force_index, player=thisPlayer, item_index=1})
			end
		end
	end
	return
end

local function UpgradeAllConnectedBelts(event)
    local thisPlayer = game.players[event.player_index]
	local truthTable = buildBoolTable(thisPlayer.mod_settings, true)
	local transportBeltEntitiesToUpgrade = {}
    if thisPlayer.connected and thisPlayer.selected and thisPlayer.controller_type ~= defines.controllers.ghost then
        local initialBelt = thisPlayer.selected
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
			if (belt.prototype.next_upgrade ~= nil) then
				belt.order_upgrade({target=belt.prototype.next_upgrade, force=thisPlayer.force_index, player=thisPlayer, item_index=1})
			end
		end
	end
	return
end

script.on_event('BeltUpgrader_BeltUpgradeHoldAll', UpgradeSameTierConnectedBelts)
script.on_event('BeltUpgrader_BeltUpgradeForceAll', UpgradeAllConnectedBelts)