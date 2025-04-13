---
-- @submodule Noble.Transition

class("DipToWhite", nil, Noble.Transition).extends(Noble.Transition.DipTile)
local transition = Noble.Transition.DipToWhite
transition.name = "Dip to White"

--- Fade to white, then to the next scene.
-- NOTE: The `tilePattern` property is locked.
-- @see Noble.Transition.Dip.defaultProperties
-- @table Noble.Transition.DipToWhite.defaultProperties

transition.tilePattern = Graphics.image.new(8, 8, Graphics.kColorWhite)

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.x = 0
	self.y = 0
end