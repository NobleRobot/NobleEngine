--- A menu object.
-- @classmod NobleMenu
--
NobleMenu = {}
class("NobleMenu").extends(Object)

--- Create a new menu object
-- @param __menuItems This is a table of strings, either menu item names, or localization keys.
-- @param __localized Set to true to localize __menuItems. Default: false
-- @param __color Graphics.kColorBlack or Graphics.kColorWhite. Default: Graphics.kColorBlack
-- @param __padding Cell padding for menu items.
-- @param __horizontalPadding Use this to override horizontal padding, useful for certain fonts. If nil, uses __padding.
-- @param __font If nil, uses current set font.
-- @param __crankControlled any
-- @param __dPadControlled any
-- @param __selectedOutlineThickness Sets the outline thickness for selected items. Default: 2
-- @return A new menu
function NobleMenu.new(__menuItems, __localized, __color, __padding, __horizontalPadding, __font, __crankControlled, __dPadControlled, __selectedOutlineThickness)
	local font = __font or Noble.Text.getCurrentFont()
	local localized = __localized or false
	local padding = __padding or 2
	local horizontalPadding = __horizontalPadding or padding
	local selectedOutlineThickness = __selectedOutlineThickness or 2
	local crankControlled = __crankControlled or false
	local dPadControlled = __dPadControlled or true

	-- Colors
	local color = __color or Graphics.kColorBlack		-- TO-DO allow for copy fill mode instead of color.
	local fillMode = Graphics.kDrawModeFillBlack
	local otherColor = Graphics.kColorWhite
	local otherFillMode = Graphics.kDrawModeFillWhite
	if (color == Graphics.kColorWhite) then
		fillMode = Graphics.kDrawModeFillWhite
		otherColor = Graphics.kColorBlack
		otherFillMode = Graphics.kDrawModeFillBlack
	end

	local textHeight = font:getHeight()

	-- Create gridview object
	local menu = UI.gridview.new(0, textHeight+padding)

	menu.textHeight = textHeight
	menu.padding = padding

	-- Gridview properties
	menu:setNumberOfColumns(1)
	menu:setNumberOfRows(#__menuItems)
	menu:setCellPadding(0, 0, 0, 0)
	menu.changeRowOnColumnWrap = false

	-- New properties
	menu.items = __menuItems
	menu.clickHandlers = {}
	menu.itemWidths = {}
	for i = 1, #menu.items, 1 do
		menu.clickHandlers[menu.items[i]] = function() print("Menu item " .. menu.items[i] .. " clicked!") end
		menu.itemWidths[i] = font:getTextWidth(menu.items[i])
		print(menu.itemWidths[i])
	end
	menu.currentMenuItemNumber = 1
	menu.currentMenuItemName = menu.items[1]

	-- Methods
	--
	function menu:activate()
		self:setSelectedRow(self.currentMenuItemNumber)
	end
	function menu:deactivate()
		self:setSelectedRow(0)
	end
	function menu:selectPrevious()
		self:selectPreviousRow(true, false, false)
		local _, row, _ = self:getSelection()
		self.currentMenuItemNumber = row
		self.currentMenuItemName = self.items[row]
	end
	function menu:selectNext()
		self:selectNextRow(true, false, false)
		local _, row, _ = self:getSelection()
		self.currentMenuItemNumber = row
		self.currentMenuItemName = self.items[row]
	end
	function menu:click()
		self.clickHandlers[self.currentMenuItemName]()
	end

	-- Drawing
	--
	function menu:drawMenuItem(__x, __y, __item)
		Graphics.setImageDrawMode(fillMode)
		Noble.Text.draw(self.items[__item], __x + horizontalPadding/2, __y + padding/2, kTextAlignment.left, localized, font)	-- TO-DO allow for centered/right-aligned text.
	end
	function menu:drawSelectedMenuItem(__x, __y, __item)
		Graphics.setColor(color)
		Graphics.fillRoundRect(__x, __y, self.itemWidths[__item]+horizontalPadding, textHeight+padding, textHeight/4)
		Graphics.setColor(otherColor)
		Graphics.setLineWidth(selectedOutlineThickness)
		Graphics.drawRoundRect(__x, __y, self.itemWidths[__item]+horizontalPadding, textHeight+padding, textHeight/4)
		Graphics.setImageDrawMode(otherFillMode)
		Noble.Text.draw(self.items[__item], __x+horizontalPadding/2, __y+padding/2, kTextAlignment.left, localized, font)
	end
	function menu:drawCell(_, row, _, selected, x, y, width, height)
		if selected then
			self:drawSelectedMenuItem(x, y, row)
		else
			self:drawMenuItem(x, y, row)
		end
	end

	return menu
end

function Noble.Menu:draw(__x, __y)
	self:drawInRect(__x, __y, 200, (self.textHeight + self.padding) * #self.items)
end