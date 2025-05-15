local beltLineUpgradeTool = table.deepcopy(data.raw["selection-tool"]["selection-tool"])

beltLineUpgradeTool.name = "beltLineUpgrade-selection-tool"
beltLineUpgradeTool.flags = {"only-in-cursor", "spawnable", "not-stackable"}
beltLineUpgradeTool.subgroup = "tool"
beltLineUpgradeTool.order = "c[automated-construction]-d[beltLineUpgrade-selection-tool]"
--beltLineUpgradeTool.icon = ""

-- Default selection (Upgrade only connected belts of same tier)
beltLineUpgradeTool.select.cursor_box_type = "entity"
beltLineUpgradeTool.select.mode = {"upgrade"}
beltLineUpgradeTool.select.entity_filter_mode = "whitelist"
beltLineUpgradeTool.select.entity_type_filters = {"splitter", "transport-belt", "underground-belt", "loader", "loader-1x1"}
beltLineUpgradeTool.select.border_color = {0, 0.8, 0}

-- Alternate selection (Upgrade all belts connected to starting entity)
beltLineUpgradeTool.alt_select.cursor_box_type = "entity"
beltLineUpgradeTool.alt_select.mode = "upgrade"
beltLineUpgradeTool.alt_select.entity_filter_mode = "whitelist"
beltLineUpgradeTool.select.entity_type_filters = {"splitter", "transport-belt", "underground-belt", "loader", "loader-1x1"}
beltLineUpgradeTool.alt_select.border_color = {0, 0.8, 0.8}

-- Reverse selection (Downgrade connected belts of the same tier)
beltLineUpgradeTool.reverse_select = table.deepcopy(beltLineUpgradeTool.select)
beltLineUpgradeTool.reverse_select.mode = "downgrade"
beltLineUpgradeTool.reverse_select.border_color = {1, 0, 0}

-- Alternate reverse selection (Downgrade all belts connected to starting entity)
beltLineUpgradeTool.alt_reverse_select = table.deepcopy(beltLineUpgradeTool.reverse_select)
beltLineUpgradeTool.alt_reverse_select.border_color = {0.8, 0, 0.8}

local beltLineUpgradeShortcut = table.deepcopy(data.raw["shortcut"]["give-blueprint"])
beltLineUpgradeShortcut.name = "beltLineUpgrade-shortcut"
beltLineUpgradeShortcut.technology_to_unlock = nil
beltLineUpgradeShortcut.associated_control_input = "beltUpgrader-give-belt-upgrade-tool"
beltLineUpgradeShortcut.item_to_spawn = "beltLineUpgrade-selection-tool"
beltLineUpgradeShortcut.style = "green"
--beltLineUpgradeShortcut.icon = ""

-- Add to game
data:extend{beltLineUpgradeTool, beltLineUpgradeShortcut}
