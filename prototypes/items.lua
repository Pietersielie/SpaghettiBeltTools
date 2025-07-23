local beltThreadUpgradeTool = table.deepcopy(data.raw["selection-tool"]["selection-tool"])
local beltThreadRemoveTool = table.deepcopy(data.raw["selection-tool"]["selection-tool"])
local selectionTypeFilter = {"splitter", "transport-belt", "underground-belt", "loader", "loader-1x1"}

if (mods['lane-splitters'] or mods['lane-balancers']) then
    table.insert(selectionTypeFilter, "lane-splitter")
end

beltThreadUpgradeTool.name = "beltThreadUpgrader-upgrade-tool"
beltThreadUpgradeTool.flags = {"only-in-cursor", "spawnable", "not-stackable"}
beltThreadUpgradeTool.subgroup = "tool"
beltThreadUpgradeTool.order = "c[automated-construction]-d[beltThreadUpgrader-upgrade-tool]"
beltThreadUpgradeTool.icon = "__BeltThreadUpgrades__/graphics/icons/beltThreadUpgrader-upgrade-tool-icon-x60.png"
beltThreadUpgradeTool.icon_size = 60

-- Default selection (Upgrade only connected belts of same tier)
beltThreadUpgradeTool.select.cursor_box_type = "entity"
beltThreadUpgradeTool.select.mode = "upgrade"
beltThreadUpgradeTool.select.entity_filter_mode = "whitelist"
beltThreadUpgradeTool.select.entity_type_filters = selectionTypeFilter
beltThreadUpgradeTool.select.border_color = {0, 0.8, 0}

-- Alternate selection (Upgrade all belts connected to starting entity)
beltThreadUpgradeTool.alt_select.cursor_box_type = "entity"
beltThreadUpgradeTool.alt_select.mode = "upgrade"
beltThreadUpgradeTool.alt_select.entity_filter_mode = "whitelist"
beltThreadUpgradeTool.select.entity_type_filters = selectionTypeFilter
beltThreadUpgradeTool.alt_select.border_color = {0, 0.8, 0.8}

-- Reverse selection (Downgrade connected belts of the same tier)
beltThreadUpgradeTool.reverse_select = table.deepcopy(beltThreadUpgradeTool.select)
beltThreadUpgradeTool.reverse_select.mode = "downgrade"
beltThreadUpgradeTool.reverse_select.border_color = {1, 0, 0}

-- Alternate reverse selection (Downgrade all belts connected to starting entity)
beltThreadUpgradeTool.alt_reverse_select = table.deepcopy(beltThreadUpgradeTool.reverse_select)
beltThreadUpgradeTool.alt_reverse_select.border_color = {0.8, 0, 0.8}

-- Base for removal tool
beltThreadRemoveTool.name = "beltThreadUpgrader-remove-tool"
beltThreadRemoveTool.flags = {"only-in-cursor", "spawnable", "not-stackable"}
beltThreadRemoveTool.subgroup = "tool"
beltThreadRemoveTool.order = "c[automated-construction]-d[beltThreadUpgrader-remove-tool]"
beltThreadRemoveTool.icon = "__BeltThreadUpgrades__/graphics/icons/beltThreadUpgrader-remove-tool-icon-x60.png"
beltThreadRemoveTool.icon_size = 60

-- Default selection (Remove only connected belts of same tier)
beltThreadRemoveTool.select.cursor_box_type = "entity"
beltThreadRemoveTool.select.mode = {"deconstruct"}
beltThreadRemoveTool.select.entity_filter_mode = "whitelist"
beltThreadRemoveTool.select.entity_type_filters = selectionTypeFilter
beltThreadRemoveTool.select.border_color = {0, 0.8, 0}

-- Alternate selection (Remove all belts connected to starting entity)
beltThreadRemoveTool.alt_select.cursor_box_type = "entity"
beltThreadRemoveTool.alt_select.mode = "deconstruct"
beltThreadRemoveTool.alt_select.entity_filter_mode = "whitelist"
beltThreadRemoveTool.select.entity_type_filters = selectionTypeFilter
beltThreadRemoveTool.alt_select.border_color = {0, 0.8, 0.8}

-- Add to game
data:extend{beltThreadUpgradeTool, data.raw["shortcut"]["beltThreadUpgrader-give-belt-upgrade-tool-shortcut"]}
data:extend{beltThreadRemoveTool, data.raw["shortcut"]["beltThreadUpgrader-give-belt-remove-tool-shortcut"]}