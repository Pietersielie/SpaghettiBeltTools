local VERBOSE = 0

-- Recursively finds the set of transport belts and underground belts connected to belt.
-- @param belt The belt from which to start the search.
-- 	    :@type LuaEntity
-- @return The union of each transport-belt or underground-belt entity's belt_neighbours or neighbours.
--      :@type {LuaEntity}
local function findConnectedBelts(belt, beltEntitiesToReturn, initialBeltUGName)
	local beltNeighbours = belt.belt_neighbours
	local connectedBelts = {}
	
	-- Add the inputs to the list of belts to check
	for _, val in pairs(beltNeighbours["inputs"]) do
		connectedBelts[val.unit_number] = val
	end

	-- Add the outputs to the list of belts to check
	for _, val in pairs(beltNeighbours["outputs"]) do
		connectedBelts[val.unit_number] = val
	end
	
	if (VERBOSE > 1) then
		log({"", "Selected item has ", table_size(beltNeighbours["inputs"]), " inputs."})
		log({"", "Selected item's inputs are:"})
		log(serpent.block(beltNeighbours["inputs"]))
		log({"", "Selected item has ", table_size(beltNeighbours["outputs"]), " outputs."})
		log({"", "Selected item's outputs are:"})
		log(serpent.block(beltNeighbours["outputs"]))
	end
	if (belt.type == "underground-belt") then
		local UGBeltEnd = belt.neighbours
		if (UGBeltEnd ~= nil) then			
			connectedBelts[UGBeltEnd.unit_number] = UGBeltEnd
		end
	end
	
	local beltName = belt.name
	if (VERBOSE > 2) then
		game.print({"", "Selected item has ", table_size(connectedBelts), " neighbours."})
	end
	if (VERBOSE > 2) then
		log({"", "Selected item has ", table_size(connectedBelts), " neighbours."})
		log({"", "Selected item's neighbours are:"})
		log(serpent.block(connectedBelts))
	end
	
	-- Add belt to the final set
	beltEntitiesToReturn[belt.unit_number] = belt

	-- If we have no neighbours of either belt or undergrounds, i.e., connectedBelts contains only belt, return.
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
	
	for _, connectedBelt in pairs(connectedBelts) do
		if (VERBOSE > 1) then
			log({"", "Following key: ", connectedBelt, " , value: ", val, "."})
			log({"", "The final list at the moment is:"})
			log({"", "{"})
			for key, val in pairs(beltEntitiesToReturn) do
				log({"", key, " , ", val})
			end
			log({"", "}"})
		end
		if (beltEntitiesToReturn[connectedBelt.unit_number] == nil) then
			local conBeltName = connectedBelt.name
			local conBeltRelUGB = connectedBelt.prototype.related_underground_belt
			-- If the connected belt is of the same type, continue the recursion.
			if (conBeltName == beltName) then
				beltEntitiesToReturn = findConnectedBelts(connectedBelt, beltEntitiesToReturn, initialBeltUGName)
			-- if belt is the same as the initial belt's related underground belt, continue the recursion
			elseif (conBeltName == initialBeltUGName) then
				beltEntitiesToReturn = findConnectedBelts(connectedBelt, beltEntitiesToReturn, initialBeltUGName)
			-- if the connected belt has the same related_underground_belt as the initial belt, continue the recursion.
			elseif (conBeltRelUGB ~= nil) then
				-- If the connected belt is of the relevant underground belt type, continue the recursion.
				if (conBeltRelUGB.name == initialBeltUGName) then
					beltEntitiesToReturn = findConnectedBelts(connectedBelt, beltEntitiesToReturn, initialBeltUGName)
				end
			end
			-- else do nothing
		else
			if (VERBOSE > 1) then
				log({"", "Item ", connectedBelt, " already in final list."})
			end
		end
	end
	
	return beltEntitiesToReturn;
end

local function UpgradeBeltLine(event)
    local thisPlayer = game.players[event.player_index]
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
			if (VERBOSE > 0) then
				game.print({"", "Selected item has prototype ", initialBelt.name})
				game.print({"", "Selected item has no specified next upgrade."})
				log({"", "Selected item has prototype ", initialBelt.name})
				log({"", "Selected item has no specified next upgrade."})
			end
			return
		end
		if (VERBOSE > 0) then
			game.print({"", "Selected item has prototype name ", initialBelt.name})
			game.print({"", "Selected item has type name ", initialBelt.type})
			game.print({"", "Selected item has next upgrade ", initialBelt.prototype.next_upgrade.name})
			log({"", "Selected item has prototype ", initialBelt.name})
			log({"", "Selected item has type name ", initialBelt.type})
			log({"", "Selected item has next upgrade ", initialBelt.prototype.next_upgrade.name})
		end
		
		-- Determine what the name of the tier's underground belt is.
		local initBeltRelUGName
		if (initialBelt.type == "underground-belt") then
			initBeltRelUGName = initialBelt.name
		else
			initBeltRelUGName = initialBelt.prototype.related_underground_belt.name
		end
		
		transportBeltEntitiesToUpgrade = findConnectedBelts(initialBelt, {}, initBeltRelUGName)
		
		if (VERBOSE > 1) then
			game.print({"", table_size(transportBeltEntitiesToUpgrade), " entities to upgrade."})
			log({"", table_size(transportBeltEntitiesToUpgrade), " entities to upgrade."})
			log({"", "These entities are:"})
			for key, val in pairs(transportBeltEntitiesToUpgrade) do
				log(serpent.block(val))
			end
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

script.on_event('BeltUpgradeHoldAll', UpgradeBeltLine)