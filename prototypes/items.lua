local beltThreadUpgradeTool = table.deepcopy(data.raw["selection-tool"]["selection-tool"])

beltThreadUpgradeTool.name = "beltThreadUpgrader-selection-tool"
beltThreadUpgradeTool.flags = {"only-in-cursor", "spawnable", "not-stackable"}
beltThreadUpgradeTool.subgroup = "tool"
beltThreadUpgradeTool.order = "c[automated-construction]-d[beltThreadUpgrader-selection-tool]"
beltThreadUpgradeTool.icon = "__BeltThreadUpgrades__/graphics/icons/beltThreadUpgrader-shortcut-x60.png"
beltThreadUpgradeTool.icon_size = 60

-- Default selection (Upgrade only connected belts of same tier)
beltThreadUpgradeTool.select.cursor_box_type = "entity"
beltThreadUpgradeTool.select.mode = {"upgrade"}
beltThreadUpgradeTool.select.entity_filter_mode = "whitelist"
beltThreadUpgradeTool.select.entity_type_filters = {"splitter", "transport-belt", "underground-belt", "loader", "loader-1x1"}
beltThreadUpgradeTool.select.border_color = {0, 0.8, 0}

-- Alternate selection (Upgrade all belts connected to starting entity)
beltThreadUpgradeTool.alt_select.cursor_box_type = "entity"
beltThreadUpgradeTool.alt_select.mode = "upgrade"
beltThreadUpgradeTool.alt_select.entity_filter_mode = "whitelist"
beltThreadUpgradeTool.select.entity_type_filters = {"splitter", "transport-belt", "underground-belt", "loader", "loader-1x1"}
beltThreadUpgradeTool.alt_select.border_color = {0, 0.8, 0.8}

-- Reverse selection (Downgrade connected belts of the same tier)
beltThreadUpgradeTool.reverse_select = table.deepcopy(beltThreadUpgradeTool.select)
beltThreadUpgradeTool.reverse_select.mode = "downgrade"
beltThreadUpgradeTool.reverse_select.border_color = {1, 0, 0}

-- Alternate reverse selection (Downgrade all belts connected to starting entity)
beltThreadUpgradeTool.alt_reverse_select = table.deepcopy(beltThreadUpgradeTool.reverse_select)
beltThreadUpgradeTool.alt_reverse_select.border_color = {0.8, 0, 0.8}

-- Add to game
data:extend{beltThreadUpgradeTool, data.raw["shortcut"]["beltThreadUpgrader-give-belt-upgrade-tool-shortcut"]}
