--- Build groups of transport belts, undergrounds and splitters
local transport_belts = data.raw["transport-belt"]
local splitters = data.raw["splitter"]

local belt_groups = {}

for _, belt in pairs(transport_belts) do
	belt_groups[belt.name] = belt_groups[belt.name] or {}
	local group = belt_groups[belt.name]
	group.u = belt.related_underground_belt
end

for _, belt in pairs(splitters) do
	belt_groups[belt.related_transport_belt] = belt_groups[belt.related_transport_belt] or {}
	local group = belt_groups[belt.related_transport_belt]
	group.s = belt.name
end

local data_string = serpent.dump(belt_groups)

local data_container_bp = table.deepcopy(data.raw["virtual-signal"]["signal-0"])
data_container_bp.hidden = true
data_container_bp.name = "belt-upgrades-data"

--- Allow control to access the data
local blocks = {}
for i = 1, #data_string, 200 do -- order string length is limited to 200
	local block = table.deepcopy(data_container_bp)
	block.name = block.name .. #blocks + 1
	block.order = data_string:sub(i, i + 200 - 1)
	table.insert(blocks, block)
end

data:extend(blocks)
