local VERBOSE = 0

local findUpstreamNetwork, findDownstreamNetwork, isGhost

isGhost = function (entity)
	return entity.name == "entity-ghost"
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
    local beltType = belt.type
    if (isGhost(belt)) then
        beltType = belt.ghost_type
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
            end
			-- Case: we're force collecting everything in the network
			if (forceDisregardTier) then
				beltEntitiesToReturn[cBUnitNumber] = conBelt
				beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)

				-- Splitters can have multiple outputs, so traverse that direction as well -- only one extraneous check
				if (conBeltType == "splitter") then
					beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
				end

			-- Case: Building network on one tier only, specified in relBeltTable
			else
				-- Case: conBelt is marked for upgrade
				if (conBelt.to_be_upgraded() and truthTable["DoSequentialUpgrades"] == true) then
					local targetName = conBelt.get_upgrade_target().name
					if (conBeltType == "splitter") then
						if (truthTable["IncludeSplitters"] == true and relBeltTable["splitter"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: conBelt is underground-belt, if of the right tier, add, continue recursion
					elseif (conBeltType == "underground-belt") then
						if (relBeltTable["underground-belt"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt
					elseif (conBeltType == "transport-belt") then
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
					if (conBeltType == "splitter") then
						if (relBeltTable["splitter"] == conBeltName and truthTable["IncludeSplitters"] == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: conBelt is underground-belt, if of the right tier, add, continue recursion
					elseif (conBeltType == "underground-belt") then
						if (relBeltTable["underground-belt"] == conBeltName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt
					elseif (conBeltType == "transport-belt") then
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
    local beltType = belt.type
    if (isGhost(belt)) then
        beltType = belt.ghost_type
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
            end
            -- Case: we're force collecting everything in the network
			if (forceDisregardTier) then
				beltEntitiesToReturn[cBUnitNumber] = conBelt
				beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)

				-- Splitters can have multiple inputs, so traverse that direction as well -- only one extraneous check
				if (conBeltType == "splitter") then
					beltEntitiesToReturn = findUpstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
                end

			-- Case: Building network on one tier only, specified in relBeltTable
			-- 		 By default, this implies we only go to the next splitter.
			else
				-- Case: conBelt is marked for upgrade
				if (conBelt.to_be_upgraded() and truthTable["DoSequentialUpgrades"] == true) then
					local targetName = conBelt.get_upgrade_target().name
					
					-- Case: conBelt is splitter, if upgrade target of right tier and settings allow, add and end recursion
					if (conBeltType == "splitter") then
						if (truthTable["IncludeSplitters"] == true and relBeltTable["splitter"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: conBelt is underground-belt, if upgrade target of the right tier, add, continue recursion
					elseif (conBeltType == "underground-belt") then
						if (relBeltTable["underground-belt"] == targetName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt is transport-belt, if upgrade target of the right tier, add, continue recursion
					elseif (conBeltType == "transport-belt") then
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
					if (conBeltType == "splitter") then
						if (VERBOSE > 2) then
							log({"", "Comparing ", relBeltTable["splitter"] , " and ", conBeltName})
						end
						if (relBeltTable["splitter"] == conBeltName and truthTable["IncludeSplitters"] == true) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
						end

					-- Case: conBelt is underground-belt, if of the right tier, add, continue recursion
					elseif (conBeltType == "underground-belt") then
						if (VERBOSE > 2) then
							log({"", "Comparing ", relBeltTable["underground-belt"], " and ", conBeltName})
						end
						if (relBeltTable["underground-belt"] == conBeltName) then
							beltEntitiesToReturn[cBUnitNumber] = conBelt
							beltEntitiesToReturn = findDownstreamNetwork(conBelt, beltEntitiesToReturn, relBeltTable, truthTable)
						end

					-- Case: conBelt is transport-belt, if of the right tier, add, continue recursion
					elseif (conBeltType == "transport-belt") then
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

local beltGraph = {}
beltGraph["isGhost"] = isGhost
beltGraph["findUpstreamNetwork"] = findUpstreamNetwork
beltGraph["findDownstreamNetwork"] = findDownstreamNetwork
return beltGraph