--- An extended implementation of `playdate.ui.gridview`, meant for 1-dimensional, single-screen text menus.
-- @module Noble.Menu
--
Noble.Menu = {}

--- Setup
-- @section setup

--- Create a new menu object.
-- @bool[opt=true] __activate @{activate|Activate} this menu upon creation.
-- @param[opt=Noble.Text.ALIGN_LEFT] __alignment The text alignment of menu items.
-- @bool[opt=false] __localized If true, menu item names are localization keys rather than display names.
-- @param[opt=Graphics.kColorBlack] __color The color of menu item text. The selected highlight will be the inverse color.
-- @int[opt=2] __padding Cell padding for menu items.
-- @int[opt] __horizontalPadding Use this to override horizontal padding, useful for certain fonts. If nil, uses __padding.
-- @int[opt=2] __margin Spacing between menu items.
-- @param[opt=Noble.Text.getCurrentFont()] __font If nil, uses current set font.
-- @int[opt=__font:getHeight()/4] __selectedCornerRadius Sets rounded corners for a selected menu item.
-- @int[opt=1] __selectedOutlineThickness Sets the outline thickness for selected items.
-- @return `menu`, a new menu item.
-- @usage
--	local menu = Noble.Menu.new(
--		true,
--		Noble.Text.ALIGN_CENTER,
--		false,
--		Graphics.kColorWhite,
--		4, 6,
--		Noble.Text.large,
--		nil, 3
--	)
--	menu:addItem("Play Game", function() TitleScreen:playGame() end)
--	menu:addItem("Options", function() Noble.transition(OptionsScreen) end)
--	menu:addItem("Credits", function() Noble.transition(CreditsScreen) end)
-- @see addItem
function Noble.Menu.new(__activate, __alignment, __localized, __color, __padding, __horizontalPadding, __margin, __font, __selectedCornerRadius, __selectedOutlineThickness)

	-- Prep for creating the gridview object
	local paddingLocal = __padding or 2
	local fontLocal = __font or Noble.Text.getCurrentFont()
	local textHeightLocal = fontLocal:getHeight()

	-- Create gridview object
	local menu = UI.gridview.new(0, textHeightLocal + paddingLocal)

	--- Properties
	--@section properties

	menu.alignment = __alignment or Noble.Text.ALIGN_LEFT

	--- @bool[opt=false] _ Indicates whether this menu's item names are treated as localization keys.
	menu.localized = Utilities.handleOptionalBoolean(__localized, false)
	menu.textHeight = textHeightLocal
	menu.padding = paddingLocal
	menu.horizontalPadding = __horizontalPadding or menu.padding
	menu.margin = __margin or 2
	menu.font = fontLocal
	menu.selectedCornerRadius = __selectedCornerRadius or textHeightLocal/4
	menu.selectedOutlineThickness = __selectedOutlineThickness or 1

	-- Local cleanup. We don't need these anymore.
	paddingLocal = nil
	fontLocal = nil
	textHeightLocal = nil

	-- Colors
	menu.color = __color or Graphics.kColorBlack -- TO-DO allow for copy fill mode instead of color.
	menu.fillMode = Graphics.kDrawModeFillBlack
	menu.otherColor = Graphics.kColorWhite
	menu.otherFillMode = Graphics.kDrawModeFillWhite
	if (menu.color == Graphics.kColorWhite) then
		menu.fillMode = Graphics.kDrawModeFillWhite
		menu.otherColor = Graphics.kColorBlack
		menu.otherFillMode = Graphics.kDrawModeFillBlack
	end

	-- Gridview properties
	menu:setNumberOfColumns(1)
	menu:setCellPadding(0, 0, 0, 0)
	menu.changeRowOnColumnWrap = false

	--- Tables
	--@section tables

	--- A string "array" of menu item strings/keys.
	-- <strong>You cannot add or remove menu items by modifying this table</strong>.
	-- It is meant as a <strong>read-only</strong> table, provided for convenience when iterating, etc. Modifying its values may break other methods.
	-- @usage
	--	for i = 1, #menu.items, 1 do
	--		menu.clickHandlers[menu.items[i]]	= nil -- Clears all click handlers, for some reason.
	--	end
	-- @see addItem
	menu.itemNames = {}

	-- This is an internal table. Modifying its may break other methods.
	menu.displayNames = {}

	-- This is an internal table. Modifying its may break other methods.
	menu.displayNamesAreLocalized = {}

	--- A table of functions associated with menu items. Items are a defined when calling @{addItem|addItem}, but their associated functions may be modified afterward.
	--
	-- <strong>You cannot add or remove menu items by modifying this table</strong>.
	-- @usage
	--	local menu = Noble.Menu.new(true)
	--	menu.addItem("Play Game")
	--	menu.addItem("Options")
	--
	--	menu.clickHandlers["Play Game"] = function() TitleScreen:playGame() end
	--	menu.clickHandlers["Options"] = function() Noble.transition(OptionsScreen) end
	-- @usage
	--	local menu = Noble.Menu.new(true)
	--	menu.addItem("Play Game")
	--	menu.addItem("Options")
	--
	--	menu.clickHandlers = {
	--		["Play Game"] = function TitleScreen:playGame() end,
	--		["Options"] = function() Noble.transition(OptionsScreen) end
	--	}
	-- @see addItem
	-- @see removeItem
	menu.clickHandlers = {}

	--- A key/value table of menu item indices.
	--
	-- This is meant as a <strong>read-only</strong> table, provided for convenience. Modifying its values will break other methods.
	-- @usage
	--	menu.itemPositions["Play Game"]	-- 1
	--	menu.itemPositions["Options"]	-- 2
	menu.itemPositions = {}

	--- A key/value table of pixel widths for each menu item, based on its text. Useful for animation, layout, etc.
	--
	-- This is meant as a <strong>read-only</strong> table, provided for convenience. Modifying its values will break other methods.
	-- @usage local playGameMenuItemWidth = menu.itemWidths["Play Game"]
	menu.itemWidths = {}

	--- Properties
	-- @section properties

	--- @int _
	-- The current menu item's index.
	--
	-- This is meant as a <strong>read-only</strong> value. Do not modify it directly.
	-- @see select
	menu.currentItemNumber = 1

	--- @string _
	-- The current menu item's name.
	--
	-- This is meant as a <strong>read-only</strong> value. Do not modify it directly.
	-- @see select
	menu.currentItemName = menu.itemNames[1]


	--- @int _
	-- The width of the widest menu item plus the menu's horizontal padding.
	--
	-- This is meant as a <strong>read-only</strong> value. Do not modify it directly.
	menu.width = 0

	--- Setup
	-- @section setup

	--- Adds a item to this menu.
	-- @string __nameOrKey The name of this menu item. It can be a display name or a localization key. <strong>Must be unique.</strong>
	-- @tparam[opt] function __clickHandler The function that runs when this menu item is "clicked."
	-- @int[opt] __position Insert the item at a specific position. If not set, adds to the end of the list.
	-- @string[opt] __displayName You can create an optional, separate display name for this item. You can add or change this at runtime via @{setItemDisplayName|setItemDisplayName}.
	-- @bool[opt=false] __displayNameIsALocalizationKey If true, will treat the `__displayName` as a localization key. This is separate from this menu's @{localized|localized} value.
	-- @see new
	-- @see removeItem
	-- @see setItemDisplayName
	function menu:addItem(__nameOrKey, __clickHandler, __position, __displayName, __displayNameIsALocalizationKey)
		local clickHandler = __clickHandler or function () print("Menu item \"" .. __nameOrKey .. "\" clicked!") end
		if (__position ~= nil) then
			if (__position <= 0 or __position > #self.itemNames) then error("BONK: Menu item out of range.", 3) return end
			table.insert(self.itemNames, __position, __nameOrKey)
			for key, value in pairs(self.itemPositions) do
				if (value >= __position) then
					self.itemPositions[key] = self.itemPositions[key] + 1
				end
			end
			self.itemPositions[__nameOrKey] = __position
		else
			table.insert(self.itemNames, __nameOrKey)
			self.itemPositions[__nameOrKey] = #self.itemNames
		end

		self.clickHandlers[__nameOrKey] = clickHandler

		-- Item name
		local nameOrKey
		if (self.localized) then
			nameOrKey = Graphics.getLocalizedText(__nameOrKey)
		else
			nameOrKey = __nameOrKey
		end

		-- Display name
		local displayName = nil
		if (__displayName ~= nil) then
			if (__displayNameIsALocalizationKey == true) then
				displayName = Graphics.getLocalizedText(__displayName)
			else
				displayName = __displayName
			end
			self.displayNames[__nameOrKey] = displayName
		end

		if (displayName == nil) then
			self:updateWidths(__nameOrKey, nameOrKey)
		else
			self:updateWidths(__nameOrKey, displayName)
		end

		self:setNumberOfRows(#self.itemNames)

	end

	-- Internal method.
	function menu:updateWidths(__nameOrKey, __string)

		if (__string == nil) then
			__string = __nameOrKey
		end

		-- Item width
		self.itemWidths[__nameOrKey] = self.font:getTextWidth(__string)

		-- Menu width
		local width = 0
		for _, value in pairs(self.itemWidths) do
			if value > width then width = value end
		end
		self.width =  width + (self.horizontalPadding * 2) + (self.selectedOutlineThickness * 2)
	end

	--- Removes a item from this menu.
	-- @tparam[opt=#menu.itemNames] int|string __menuItem The menu item to remove. You can enter either the item's name/key or it's position. If left blank, removes the last item.
	-- @see addItem
	function menu:removeItem(__menuItem)
		local itemString = nil
		local itemPosition = nil

		if (__menuItem == nil) then
			__menuItem = #self.itemNames
		end

		if (type(__menuItem) == "number") then
			if (__menuItem <= 0 or __menuItem > #self.itemNames) then error("BONK: Menu item out of range.", 3) return end
			itemString = self.itemNames[__menuItem]
			itemPosition = __menuItem
		elseif (type(__menuItem) == "string") then
			itemString = __menuItem
			itemPosition = self.itemPositions[__menuItem]
			if (itemPosition == nil) then error("BONK: Menu item not found.", 3) return end
		end

		for key, value in pairs(self.itemPositions) do
			if (value > itemPosition) then
				self.itemPositions[key] = self.itemPositions[key] - 1
			end
		end

		table.remove(self.itemNames, itemPosition)
		self.itemPositions[itemString] = nil
		self.clickHandlers[itemString] = nil
		self.itemWidths[itemString] = nil
		self.displayNames[itemString] = nil
		self.displayNamesAreLocalized[itemString] = nil

		-- In case the current item is selected.
		if (self.currentItemNumber == itemPosition and self.currentItemNumber ~= 1) then
			self:select(self.currentItemNumber - 1, true)
			if (self.isActive() == false) then
				self:setSelectedRow(0)
			end
		end

		self:setNumberOfRows(#self.itemNames)

		-- Update width
		local width = 0
		for _, value in pairs(self.itemWidths) do
			if value > width then width = value end
		end
		self.width =  width + (self.horizontalPadding * 2) + (self.selectedOutlineThickness * 2)

	end

	--

	local active = Utilities.handleOptionalBoolean(__activate, true)
	if (active) then
		menu.currentItemNumber = 1
		menu.currentItemName = menu.itemNames[1]
		menu:setSelectedRow(1)
	else
		menu:setSelectedRow(0)
	end

	--- Methods
	--@section methods

	--- Activate this menu.
	-- This selects the most recently selected menu item (or the first item if none have been previously selected), and enables this menu's @{selectPrevious|selectPrevious}, @{selectNext|selectNext}, and @{click|click} methods.
	-- @usage
	--	local menu = Noble.Menu.new(false)
	--	menu:activate()
	function menu:activate()
		self:select(self.currentItemNumber)
		active = true
	end
	--- Deactivate this menu.
	-- This deselects all menu items, and disables this menu's @{selectPrevious|selectPrevious}, @{selectNext|selectNext}, and @{click|click} methods.
	-- @usage
	--	local menu = Noble.Menu.new(true)
	--	menu:deactivate()
	function menu:deactivate()
		self:setSelectedRow(0)
		active = false
	end
	--- Check to see if this menu is currently active.
	-- @treturn bool
	function menu:isActive()
		return active
	end

	--- Selects the previous item in this menu. <strong>This menu must be active.</strong>
	-- @bool[opt=false] __force Force this method to run, even if this menu is not active.
	-- @bool[opt=true] __wrapSelection Selects the final menu item if the first menu item is currently selected.
	-- @see activate
	-- @usage
	--	TitleScreen.inputHandler.upButtonDown = function()
	--		menu:selectPrevious()
	--	end
	function menu:selectPrevious(__force, __wrapSelection)
		if (self:isActive() or __force) then
			local wrapSelection = Utilities.handleOptionalBoolean(__wrapSelection, true)
			self:selectPreviousRow(wrapSelection, false, false)
			local _, row, _ = self:getSelection()
			self.currentItemNumber = row
			self.currentItemName = self.itemNames[row]
		end
	end
	--- Selects the next previous item in this menu. <strong>This menu must be active.</strong>
	-- @bool[opt=false] __force Force this method to run, even if this menu is not active.
	-- @bool[opt=true] __wrapSelection Selects the first menu item if the final menu item is currently selected.
	-- @see activate
	-- @usage
	--	TitleScreen.inputHandler.downButtonDown = function()
	--		menu:selectNext()
	--	end
	function menu:selectNext(__force, __wrapSelection)
		if (self:isActive() or __force) then
			local wrapSelection = Utilities.handleOptionalBoolean(__wrapSelection, true)
			self:selectNextRow(wrapSelection, false, false)
			local _, row, _ = self:getSelection()
			self.currentItemNumber = row
			self.currentItemName = self.itemNames[row]
		end
	end

	--- Selects a specific item in this menu, either by it's index, or it's name. <strong>This menu must be active.</strong>
	-- @tparam int|string __menuItem The menu item to select. You can enter the item's number or it's name/key.
	-- @bool[opt=false] __force Force this method to run, even if this menu is not active.
	-- @see activate
	-- @usage
	--	function resetMenu()
	--		menu:select(1, true)
	--		menu:deactivate()
	--	end
	-- @usage
	--	function resetMenu()
	--		menu:select("Play Game", true)
	--		menu:deactivate()
	--	end
    function menu:select(__menuItem, __force)
		if (self:isActive() or __force) then
			if (type(__menuItem) == 'number') then
				if (__menuItem < 1) then
					error("BONK: _menuItem must be a number greater than 0 (or a string).")
				end
				self:setSelectedRow(__menuItem)
			elseif (type(__menuItem) == 'string') then
				self:setSelectedRow(self.itemPositions[__menuItem])
			else
				error("BONK: _menuItem must be a number or string, silly.")
			end
			local _, row, _ = self:getSelection()
			self.currentItemNumber = row
			self.currentItemName = self.itemNames[row]
		end
	end

	--- Runs the function associated with the currently selected menu item. <strong>This menu must be active.</strong>
	-- @bool[opt=false] __force Force this method to run, even if this menu is not active.
	-- @see activate
	-- @usage
	--	TitleScreen.inputHandler.AButtonDown = function()
	--		menu:click()
	--	end
	function menu:click(__force)
		if ((self:isActive() or __force) and self.clickHandlers[self.currentItemName] ~= nil) then
			self.clickHandlers[self.currentItemName]()
		end
	end

	--- Gets the display name of a menu item.
	--
	-- If a menu item does not have a display name, then the `__nameOrKey` (or its localized string) will be returned instead. This method is used internally when @{draw|draw} is called.
	--
	-- If this menu's `localized` value is true, a returned `__nameOrKey` will always be localized, but a returned display name is only localized if the `__displayNameIsALocalizationKey` argument was set to `true` when the display name was added.
	-- @string __itemName The menu item you want the display name of.
	-- @treturn string
	-- @see addItem
	-- @see setItemDisplayName
	function menu:getItemDisplayName(__itemName)
		if (self.displayNames[__itemName] == nil) then
			-- No display name.
			if (self.localized) then
				return Graphics.getLocalizedText(__itemName)
			else
				return __itemName
			end
		else
			-- Has display name.
			if (self.displayNamesAreLocalized[__itemName] == true) then
				return Graphics.getLocalizedText(self.displayNames[__itemName])
			else
				return self.displayNames[__itemName]
			end
		end
	end

	--- When you add a menu item, you can give it a display name that's different from it's actual name. This method adds or changes the display name of a menu item.
	-- @string __itemName The menu item name (or key if this menu uses localization keys).
	-- @string __displayName The display name.
	-- @bool[opt=false] __displayNameIsALocalizationKey Set to use to indicate that this display name is a localization key. This setting is separate from @{localized|localized}
	-- @usage
	--	function changeDifficultyLevel(__level)
	--		menu:setItemDisplayName("Difficulty", "Difficulty: " .. __level)
	--	end
	function menu:setItemDisplayName(__itemName, __displayName, __displayNameIsALocalizationKey)
		self.displayNames[__itemName] = __displayName
		self.displayNamesAreLocalized[__itemName] = Utilities.handleOptionalBoolean(__displayNameIsALocalizationKey, false)

		local displayName
		if (__displayNameIsALocalizationKey == true) then
			displayName = Graphics.getLocalizedText(__displayName)
		else
			displayName = __displayName
		end

		-- If we're "resetting" the display name by setting it to nil, then use __nameOrKey instead (checking for localization before calling updateWidths)
		if (displayName == nil) then
			if (self.localized) then
				displayName = Graphics.getLocalizedText(__itemName)
			else
				displayName = __itemName
			end
		end

		self:updateWidths(__itemName, displayName)
	end

	--- Drawing
	--@section drawing

	--- Draw's this menu to the screen. You may call this manually, but ideally, you will put it in in your scene's @{NobleScene:update|update} or @{NobleScene:drawBackground|drawBackground} method.
	-- @usage
	--	function YourScene:update()
	--		YourScene.super.update(self)
	--		menu:draw(50, 100)
	--	end
	function menu:draw(__x, __y)
		local xAdjustment = 0
		if (self.alignment == Noble.Text.ALIGN_CENTER) then
			xAdjustment = self.width/2
		elseif (self.alignment == Noble.Text.ALIGN_RIGHT) then
			xAdjustment = self.width
		end
		self:drawInRect(__x - xAdjustment, __y, self.width, ((self.textHeight + self.padding + self.margin) * #self.itemNames) + (self.selectedOutlineThickness * 2) - self.margin)
	end

	--- This method is called for every <strong>non-selected</strong> item when @{draw|draw} is called. You shouldn't call this directly, but you may re-implement it if you wish.
	-- @usage
	-- -- This is the default implementation for this method.
	-- function menu:drawItem(__x, __y, __itemIndex)
	-- 	Graphics.setImageDrawMode(self.fillMode)
	-- 	local xAdjustment = 0
	-- 	if (self.alignment == Noble.Text.ALIGN_CENTER) then
	-- 		xAdjustment = self.width/2 - self.horizontalPadding/2
	-- 	elseif (self.alignment == Noble.Text.ALIGN_RIGHT) then
	-- 		xAdjustment = self.width - self.horizontalPadding
	-- 	end
	-- 	Noble.Text.draw(self.itemNames[__itemIndex], __x + self.horizontalPadding/2 + xAdjustment, __y + self.padding/2, self.alignment, self.localized, self.font)
	-- end
	-- @see Noble.Text.draw
	function menu:drawItem(__x, __y, __itemIndex)
		Graphics.setImageDrawMode(self.fillMode)
		local xAdjustment = self.selectedOutlineThickness
		if (self.alignment == Noble.Text.ALIGN_CENTER) then
			xAdjustment = self.width/2 - self.horizontalPadding/2
		elseif (self.alignment == Noble.Text.ALIGN_RIGHT) then
			xAdjustment = self.width - self.horizontalPadding - self.selectedOutlineThickness
		end
		Noble.Text.draw(
			self:getItemDisplayName(self.itemNames[__itemIndex]),
			__x + self.horizontalPadding/2 + xAdjustment, __y + self.padding/2 + self.selectedOutlineThickness + (self.margin * (__itemIndex -1)),
			self.alignment, false, self.font
		)
	end

	--- This method is called for every <strong>selected</strong> item when @{draw|draw} is called. You shouldn't call this directly, but you may re-implement it if you wish.
	-- @usage
	-- -- This is the default implementation for this method.
	-- function menu:drawSelectedItem(__x, __y, __itemIndex)
	-- 	local xAdjustmentText = 0
	-- 	local xAdjustmentRect = 0
	-- 	if (self.alignment == Noble.Text.ALIGN_CENTER) then
	-- 		xAdjustmentText = self.width/2 - self.horizontalPadding/2
	--		xAdjustmentRect = self.width/2 - self.itemWidths[self.itemNames[__itemIndex]]/2 - self.horizontalPadding/2
	-- 	elseif (self.alignment == Noble.Text.ALIGN_RIGHT) then
	-- 		xAdjustmentText = self.width - self.horizontalPadding
	-- 		xAdjustmentRect = self.width - self.itemWidths[self.itemNames[__itemIndex]] - self.horizontalPadding
	-- 	end
	-- 	Graphics.setColor(self.color)
	-- 	Graphics.fillRoundRect(__x + xAdjustmentRect, __y, self.itemWidths[self.itemNames[__itemIndex]]+self.horizontalPadding, self.textHeight+self.padding, self.selectedCornerRadius)
	-- 	Graphics.setColor(self.otherColor)
	-- 	Graphics.setLineWidth(self.selectedOutlineThickness)
	-- 	Graphics.drawRoundRect(__x + xAdjustmentRect, __y, self.itemWidths[self.itemNames[__itemIndex]]+self.horizontalPadding, self.textHeight+self.padding, self.selectedCornerRadius)
	-- 	Graphics.setImageDrawMode(self.otherFillMode)
	-- 	Noble.Text.draw(self.itemNames[__itemIndex], __x + self.horizontalPadding/2 + xAdjustmentText, __y+self.padding/2, self.alignment, self.localized, self.font)
	-- end
	-- @see Noble.Text.draw
	function menu:drawSelectedItem(__x, __y, __itemIndex)
		local xAdjustmentText = self.selectedOutlineThickness
		local xAdjustmentRect = self.selectedOutlineThickness
		if (self.alignment == Noble.Text.ALIGN_CENTER) then
			xAdjustmentText = self.width/2 - self.horizontalPadding/2
			xAdjustmentRect = self.width/2 - self.itemWidths[self.itemNames[__itemIndex]]/2 - self.horizontalPadding/2
		elseif (self.alignment == Noble.Text.ALIGN_RIGHT) then
			xAdjustmentText = self.width - self.horizontalPadding - self.selectedOutlineThickness
			xAdjustmentRect = self.width - self.itemWidths[self.itemNames[__itemIndex]] - self.horizontalPadding - self.selectedOutlineThickness
		end
		Graphics.setColor(self.color)
		Graphics.fillRoundRect(__x + xAdjustmentRect, __y + self.selectedOutlineThickness + (self.margin * (__itemIndex -1)), self.itemWidths[self.itemNames[__itemIndex]]+self.horizontalPadding, self.textHeight+self.padding, self.selectedCornerRadius)
		Graphics.setColor(self.otherColor)
		Graphics.setLineWidth(self.selectedOutlineThickness)
		Graphics.drawRoundRect(__x + xAdjustmentRect, __y + self.selectedOutlineThickness + (self.margin * (__itemIndex -1)), self.itemWidths[self.itemNames[__itemIndex]]+self.horizontalPadding, self.textHeight+self.padding, self.selectedCornerRadius)
		Graphics.setImageDrawMode(self.otherFillMode)
		Noble.Text.draw(
			self:getItemDisplayName(self.itemNames[__itemIndex]),
			__x + self.horizontalPadding/2 + xAdjustmentText, __y + self.padding/2 + self.selectedOutlineThickness + (self.margin * (__itemIndex -1)),
			self.alignment, false, self.font
		)
	end

	-- Don't call or modify this function.
	function menu:drawCell(_, row, _, selected, x, y, width, height)
		if selected then
			self:drawSelectedItem(x, y, row)
		else
			self:drawItem(x, y, row)
		end
	end

	return menu
end
