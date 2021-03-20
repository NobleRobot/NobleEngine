--- Text and font handling.
-- @module Noble.Text
Noble.Text = {}
Noble.Text.system = Graphics.getSystemFont()
Noble.Text.small = Graphics.font.new("libraries/noble/assets/fonts/NobleSans")
Noble.Text.medium = Graphics.font.new("libraries/noble/assets/fonts/NobleSlab")
Noble.Text.large = Graphics.font.new("libraries/noble/assets/fonts/SatchelRoughed")
local currentFont = Noble.Text.system

Noble.Text.ALIGN_LEFT = kTextAlignment.left
Noble.Text.ALIGN_RIGHT = kTextAlignment.right
Noble.Text.ALIGN_CENTER = kTextAlignment.center

function Noble.Text.getCurrentFont() return currentFont end
function Noble.Text.setFont(__font, __variant)
	currentFont = __font
	local variant = __variant or Graphics.font.kVariantNormal
	Graphics.setFont(__font, variant)
end

function Noble.Text.draw(__string, __x, __y, __alignment, __localized, __font)
	if (__alignment == nil) then __alignment = kTextAlignment.left end
	if (__localized == nil) then __localized = false end
	if (__font ~= nil) then Graphics.setFont(__font) end -- Temporary font
	if (__localized) then
		Graphics.drawLocalizedTextAligned(__string, __x, __y, __alignment)
	else
		Graphics.drawTextAligned(__string, __x, __y, __alignment)
	end
	if (__font ~= nil) then Graphics.setFont(currentFont) end	-- Reset
end
