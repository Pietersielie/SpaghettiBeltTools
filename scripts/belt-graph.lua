local VERBOSE = 0

local findUpstreamNetwork
local findDownstreamNetwork
local isGhost
local isRelBelt
local findRedundantNetwork
local getType

---Checks if an entity is a ghost, simple shorthand function.
---@param entity LuaEntity The entity to check.
---@return boolean val True if `entity` is a ghost, false if not.
isGhost = function (entity)
	return entity.name == "entity-ghost"
end

---Simple shorthand function to determine the type of an entity
---@param entity LuaEntity An entity whose type is to be determined.
---@return string type The type (string name) of the entity.
getType = function (entity)
	if isGhost(entity) then
		return entity.ghost_type
	else
		return entity.type
	end
end

---Checks if a prototype name is in the specified table. Intended for use with the related Belt tier table.
---@param prototypeName string The name of the prototype to check if it is included.
---@param relBeltTable table<string, string> The table to go through to check for the prototype name.
---@return boolean val True if `prototypeName` is in `relBeltTable`, false if not.
isRelBelt = function (prototypeName, relBeltTable)
	for _, value in pairs(relBeltTable) do
		if (value == prototypeName) then
			return true
		end
	end
	return false
end

---Recursively finds the set of transport belts and underground belts connected upstream of `belt`.
---@param belt LuaEntity The belt from which to start the search.
---@param beltEntitiesToReturn table<int, LuaEntity> The table of entities collected and returned at the end.
---@param relBeltTable table<string, string> A table with the names of the items that make up a belt tier.
---@param truthTable table<string, boolean> A table of boolean values as produced by `buildBoolTable()`, used for configuration of the function.
---@return table<int, LuaEntity> beltEntitiesToReturn The table of each TransportConnectable entity in the network of `belt`, as bound by the user settings.
findUpstreamNetwork = function(belt, beltEntitiesToReturn, relBeltTable, truthTable)
	-- Default value for forceDisregardTier is false
	local forceDisregardTier = truthTable["ForceBuild"] or false

	local beltType = belt.type
    if (isGhost(belt)) then
        beltType = belt.ghost_type
    end
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
    if (forceDisregardTier) then
		local outputs = belt.belt_neighbours["outputs"]
		for _, val in pairs(outputs) do
			connectedBelts[val.unit_number] = val
		end
	end

	-- If underground-belt, add other end if it exists
	if (beltType == "underground-belt") then
		local UGBeltEnd = belt.neighbours
		if (UGBeltEnd ~= nil) then
            if (VERBOSE > 2) then
                game.print({"", "Underground belt has a neighbour."})
            end
			connectedBelts[UGBeltEnd.unit_number] = UGBeltEnd
		end
	end

	-- If we have no upstream neighbours of either belt or undergrounds, i.e., connectedBelts is empty, return.
	if (table_size(connectedBelts) == 0) then
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
            conBeltType = conBelt.type
            if (isGhost(conBelt)) then
                conBeltName = conBelt.ghost_name
                conBeltType = conBelt.ghost_type
			elseif (conBelt.to_be_upgraded() and truthTable["DoSequentialUpgrades"] == true) then
				conBeltName = conBelt.get_upgrade_target().name
			end
			-- Case: we're force collecting everything in the network
			if (forceDisregardTier) then
				beltEntitiesToReturn[cBUnitNumber] = conBelt
				beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)

				-- Splitters can have multiple outputs, so traverse that direction as well -- only one extraneous check
				if (conBeltType == "splitter") then
					beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
				end

				if truthTable["AllBeltsOfTier"] then
					if not isRelBelt(conBeltName, relBeltTable) then
						beltEntitiesToReturn[cBUnitNumber] = nil
					end
				end

			-- Case: Building network on one tier only, specified in relBeltTable
			else
				-- Case: conBelt is marked for upgrade
				if (conBelt.to_be_upgraded() and truthTable["DoSequentialUpgrades"] == true) then
					local targetName = conBelt.get_upgrade_target().name
					if (conBeltType == "splitter"  or conBeltType == "lane-splitter") then
						if (truthTable["IncludeSplitters"] == true and isRelBelt(targetName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: conBelt is underground-belt, if of the right tier, add, continue recursion
					elseif (conBeltType == "underground-belt") then
						if (isRelBelt(targetName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt is transport-belt, if of the right tier, add, continue recursion
					elseif (conBeltType == "transport-belt") then
						if (isRelBelt(targetName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt is a loader, if of the right tier, add
					elseif (conBeltType == "loader-1x1" or conBeltType == "loader") then
						if (isRelBelt(targetName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: not transport belt, underground, or splitter... oops!
					else
						game.print("Something has gone wrong with building the belt graph, please contact the mod author.")
						game.print("Troublesome entity is of type " .. conBeltType .. " with name " .. targetName .. ".")
					end

				-- Case: conBelt is not marked for upgrade
				else
					if (conBeltType == "splitter" or conBeltType == "lane-splitter") then
						if (isRelBelt(conBeltName, relBeltTable) == true and truthTable["IncludeSplitters"] == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: conBelt is underground-belt, if of the right tier, add, continue recursion
					elseif (conBeltType == "underground-belt") then
						if (isRelBelt(conBeltName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt
					elseif (conBeltType == "transport-belt") then
						if (isRelBelt(conBeltName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					elseif (conBeltType == "loader-1x1" or conBeltType == "loader") then
						if (isRelBelt(conBeltName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: not transport belt, underground, splitter, or one of the loaders... oops!
					else
						game.print("Something has gone wrong with building the belt graph, please contact the mod author.")
						game.print("Troublesome entity is of type " .. conBeltType .. " with name " .. targetName .. ".")
					end
				end

			-- Case: conBelt is not of same tier and not marked to upgrade, ignore.
			end

		-- else, conBelt has been traversed before, ignore.
		end
	end

	return beltEntitiesToReturn
end

---Recursively finds the set of transport belts and underground belts connected downstream of `belt`.
---@param belt LuaEntity The belt from which to start the search.
---@param beltEntitiesToReturn table<int, LuaEntity> The table of entities collected and returned at the end, indexed by the entity unit numbers.
---@param relBeltTable table<string, string> A table with the names of the items that make up a belt tier.
---@param truthTable table<string, boolean> A table of boolean values as produced by `buildBoolTable()`, used for configuration of the function.
---@return table<int, LuaEntity> beltEntitiesToReturn The table of each TransportConnectable entity in the network of `belt`, as bound by the user settings.
findDownstreamNetwork = function(belt, beltEntitiesToReturn, relBeltTable, truthTable)
	-- Default value for forceDisregardTier is false
	local forceDisregardTier = truthTable["ForceBuild"] or false

	local beltType = belt.type
	if (isGhost(belt)) then
		beltType = belt.ghost_type
	end

	local connectedBelts = {}
	-- Add downstream belt neighbours to list to check
	for _, val in pairs(belt.belt_neighbours["outputs"]) do
		connectedBelts[val.unit_number] = val
    end
	
    if (forceDisregardTier) then
		local inputs = belt.belt_neighbours["inputs"]
		for _, val in pairs(inputs) do
			connectedBelts[val.unit_number] = val
		end
	end
    -- If underground-belt, add other end if it exists
    if (beltType == "underground-belt") then
        local UGBeltEnd = belt.neighbours
        if (UGBeltEnd ~= nil) then
            if (VERBOSE > 2) then
                game.print({"", "Underground belt has a neighbour:", serpent.block(UGBeltEnd)})
                log({"", "Underground belt has a neighbour: ", serpent.block(UGBeltEnd)})
            end
            connectedBelts[UGBeltEnd.unit_number] = UGBeltEnd
        end
    end

	-- If we have no downstream neighbours of either belt or undergrounds, i.e., connectedBelts is empty, return.
	if (table_size(connectedBelts) == 0) then
		if (VERBOSE > 2) then
			game.print({"", "Selected item has no neighbours."})
			log({"", "Selected item has no neighbours."})
			log({"", "Returning itself to final list."})
			log({"", "These entities are:"})
			log(serpent.block(beltEntitiesToReturn))
		end
		return beltEntitiesToReturn
	end

    -- Testing validation
    if (VERBOSE > 2) then
        log({"", "Current belt graph:"})
        for key, value in pairs(beltEntitiesToReturn) do
            log({"", "\t", serpent.block(key), " : ", serpent.block(value)})
        end

        log({"", "Iterating over connected belts:"})
        for key, value in pairs(connectedBelts) do
            log({"", "\t", serpent.block(key), " : ", serpent.block(value)})
        end
    end

	-- Iterate over connectedBelts
	for cBUnitNumber, conBelt in pairs(connectedBelts) do
		-- If conBelt is not in final list already
		if (beltEntitiesToReturn[cBUnitNumber] == nil) then
			conBeltName = conBelt.name
            conBeltType = conBelt.type
            if (isGhost(conBelt)) then
                conBeltName = conBelt.ghost_name
                conBeltType = conBelt.ghost_type
			elseif (conBelt.to_be_upgraded() and truthTable["DoSequentialUpgrades"] == true) then
				conBeltName = conBelt.get_upgrade_target().name
            end
            -- Case: we're force collecting everything in the network
			if (forceDisregardTier) then
				beltEntitiesToReturn[cBUnitNumber] = conBelt
				beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)

				-- Splitters can have multiple inputs, so traverse that direction as well -- only one extraneous check
				if (conBeltType == "splitter") then
					beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
                end

				if truthTable["AllBeltsOfTier"] then
					if not isRelBelt(conBeltName, relBeltTable) then
						beltEntitiesToReturn[cBUnitNumber] = nil
					end
				end

			-- Case: Building network on one tier only, specified in relBeltTable
			-- 		 By default, this implies we only go to the next splitter.
			else
				-- Case: conBelt is marked for upgrade
				if (conBelt.to_be_upgraded() and truthTable["DoSequentialUpgrades"] == true) then
					local targetName = conBelt.get_upgrade_target().name
					
					-- Case: conBelt is splitter, if upgrade target of right tier and settings allow, add and end recursion
					if (conBeltType == "splitter" or conBeltType == "lane-splitter") then
						if (truthTable["IncludeSplitters"] == true and isRelBelt(targetName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: conBelt is underground-belt, if upgrade target of the right tier, add, continue recursion
					elseif (conBeltType == "underground-belt") then
						if (isRelBelt(targetName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt is transport-belt, if upgrade target of the right tier, add, continue recursion
					elseif (conBeltType == "transport-belt") then
						if (isRelBelt(targetName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt is a loader, if of the right tier, add
					elseif (conBeltType == "loader-1x1" or conBeltType == "loader") then
						if (isRelBelt(targetName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: not transport belt, underground, or splitter... oops!
					else
						game.print("Something has gone wrong with building the belt graph, please contact the mod author.")
						game.print("Troublesome entity is of type " .. conBeltType .. " with name " .. targetName .. ".")
					end

				-- Case: conBelt is not marked for upgrade
				else
					-- Case: conBelt is splitter, if of right tier and settings allow, add
					if (conBeltType == "splitter" or conBeltType == "lane-splitter") then
						if (VERBOSE > 2) then
							log({"", "Comparing ", relBeltTable["splitter"] , " and ", conBeltName})
						end
						if (isRelBelt(conBeltName, relBeltTable) == true and truthTable["IncludeSplitters"] == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: conBelt is underground-belt, if of the right tier, add, continue recursion
					elseif (conBeltType == "underground-belt") then
						if (VERBOSE > 2) then
							log({"", "Comparing ", relBeltTable["underground-belt"], " and ", conBeltName})
						end
						if (isRelBelt(conBeltName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt is transport-belt, if of the right tier, add, continue recursion
					elseif (conBeltType == "transport-belt") then
						if (VERBOSE > 2) then
							log({"", "Comparing ", relBeltTable["transport-belt"] , " and ", conBeltName})
						end
						if (isRelBelt(conBeltName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end
					elseif (conBeltType == "loader-1x1" or conBeltType == "loader") then
						if (isRelBelt(conBeltName, relBeltTable) == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end
					-- Case: not transport belt, underground, or splitter... oops!
					else
						game.print("Something has gone wrong with building the belt graph, please contact the mod author.")
						game.print("Troublesome entity is of type " .. conBeltType .. " with name " .. conBeltName .. ".")
					end
				end

			-- Case: conBelt is not of same tier and not marked to upgrade, ignore.
			end

		-- else, conBelt has been traversed before, ignore.
		end
	end

	return beltEntitiesToReturn
end

---Recursively finds the set of transport belt entities rendered redundant by removal of `belt`.
---@param belt LuaEntity The belt from which to start the search.
---@param beltEntitiesToReturn table<int, LuaEntity> The table of entities collected and returned at the end, indexed by the entity unit numbers.
---@param relBeltTable table<string, string> A table with the names of the items that make up a belt tier.
---@param UpDown boolean True if the search is downstream, false if the search is upstream.
---@return table<int, LuaEntity> beltEntitiesToReturn The table of redundant transport belt entities when `belt` is removed, indexed by the entity unit numbers.
findRedundantNetwork = function (belt, beltEntitiesToReturn, relBeltTable, UpDown)
	-- If we have visited this node before, return.
	if beltEntitiesToReturn[belt.unit_number] ~= nil then
		return beltEntitiesToReturn
	end

	-- Default value for forceDisregardTier is false
	
	local beltType = belt.type
	if (isGhost(belt)) then
		beltType = belt.ghost_type
	end

	-- case: Belt is transport belt
	if beltType == "transport-belt" then
		-- case: downstream
		if UpDown then
			local inputs = belt.belt_neighbours["inputs"] 
			-- 	case: >1 input
			if table_size(inputs) > 1 then
				for _, value in pairs(inputs) do
					-- case: not all inputs are in graph already
					if beltEntitiesToReturn[value.unit_number] == nil then
						-- ignore and return graph
						return beltEntitiesToReturn
					end
				end
				-- case: all inputs are in graph already
				-- add to graph
				-- continue recursion
				beltEntitiesToReturn[belt.unit_number] = belt

			-- case: 1 input
			else
				-- add to graph
				-- continue recursion
				beltEntitiesToReturn[belt.unit_number] = belt
			end

		-- case: upstream
		else
			-- 	add to graph
			-- 	continue recursion
			beltEntitiesToReturn[belt.unit_number] = belt
		end

	-- case: Belt is underground belt
	elseif beltType == "underground-belt" then
		-- case: downstream
		if UpDown then
			local inputs = belt.belt_neighbours["inputs"]
			-- 	case: 0 inputs (i.e., comes from neighour)
			if table_size(inputs) == 0 then
				-- 		add
				-- 		continue recursion
				beltEntitiesToReturn[belt.unit_number] = belt

			-- 	case: 1 input
			elseif table_size(inputs) == 1 then
				-- 		case: input and belt direction are the same, or neighbours == nil, or output == {}
				if (inputs[1].direction == belt.direction) or (belt.neighbours == nil) or (belt.belt_neighbours["outputs"] == {}) then
					-- add
					-- continue recursion
					beltEntitiesToReturn[belt.unit_number] = belt
				-- case: else
				else
					-- ignore and return graph
					return beltEntitiesToReturn
				end

			-- 	case: >1 input
			else
				-- ignore and return graph
				return beltEntitiesToReturn				
			end

		-- case: upstream
		else
			-- add to graph
			-- continue recursion
			beltEntitiesToReturn[belt.unit_number] = belt
		end

	-- case: Belt is splitter/lane-splitter
	elseif beltType == "splitter" or beltType == "lane-splitter" then
		-- case: downstream
		if UpDown then
			local inputs = belt.belt_neighbours["inputs"]
			-- 	case: >1 input
			if table_size(inputs) > 1 then
				for _, value in pairs(inputs) do
					-- case: not all inputs are in graph already
					if beltEntitiesToReturn[value.unit_number] == nil then
						-- ignore and return graph
						return beltEntitiesToReturn
					end
				end
				-- case: all inputs are in graph already
				-- add to graph
				-- continue recursion
				beltEntitiesToReturn[belt.unit_number] = belt
				
				-- case: 1 input
			else
				-- add to graph
				-- continue recursion
				beltEntitiesToReturn[belt.unit_number] = belt
			end

		-- case: upstream
		else
			local outputs = belt.belt_neighbours["outputs"]
			-- 	case: >1 output
			if table_size(outputs) > 1 then
				for _, value in pairs(outputs) do
					-- case: not all outputs are in graph already
					if beltEntitiesToReturn[value.unit_number] == nil then
						-- ignore and return graph
						return beltEntitiesToReturn
					end
				end
				-- case: all outputs are in graph already
				-- add to graph
				-- continue recursion
				beltEntitiesToReturn[belt.unit_number] = belt

			-- case: 1 output
			else
				-- add to graph
				-- continue recursion
				beltEntitiesToReturn[belt.unit_number] = belt
			end
		end

	-- case: Belt is loader
	elseif beltType == "loader-1x1" or beltType == "loader" then
		beltEntitiesToReturn[belt.unit_number] = belt
		return beltEntitiesToReturn
	end

	local connectedBelts = {}
	-- Add downstream belt neighbours to list to check
	for _, val in pairs(belt.belt_neighbours["outputs"]) do
		connectedBelts[val.unit_number] = val
    end

    local inputs = belt.belt_neighbours["inputs"]
	for _, val in pairs(inputs) do
		connectedBelts[val.unit_number] = val
	end

    -- If underground-belt, add other end if it exists
    if (beltType == "underground-belt") then
        local UGBeltEnd = belt.neighbours
        if (UGBeltEnd ~= nil) then
            connectedBelts[UGBeltEnd.unit_number] = UGBeltEnd
        end
    end

	-- If we have no neighbours of either belt or undergrounds, i.e., connectedBelts is empty, return.
	if (table_size(connectedBelts) == 0) then
		if (VERBOSE > 2) then
			game.print({"", "Selected item has no neighbours."})
			log({"", "Selected item has no neighbours."})
			log({"", "Returning itself to final list."})
			log({"", "These entities are:"})
			log(serpent.block(beltEntitiesToReturn))
		end
		return beltEntitiesToReturn
	end

	-- For each belt connected to this one, continue the recursion in the same direction (UpDown).
	for _, conBelt in pairs(connectedBelts) do
		beltEntitiesToReturn = findRedundantNetwork(conBelt, beltEntitiesToReturn, relBeltTable, UpDown)
	end

	return beltEntitiesToReturn
end

local beltGraph = {}
beltGraph["isGhost"] = isGhost
beltGraph["findUpstreamNetwork"] = findUpstreamNetwork
beltGraph["findDownstreamNetwork"] = findDownstreamNetwork
beltGraph["isRelBelt"] = isRelBelt
beltGraph["findRedundantNetwork"] = findRedundantNetwork
beltGraph["getType"] = getType
return beltGraph