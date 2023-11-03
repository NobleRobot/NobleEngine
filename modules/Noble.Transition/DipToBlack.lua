---
-- @submodule Noble.Transition

class("DipToBlack", nil, Noble.Transition).extends(Noble.Transition.Dip)
local transition = Noble.Transition.DipToBlack
transition.name = "Dip to Black"

--- Fade to black, then to the next scene.
-- NOTE: The `panelImage` property is locked.
-- @see Noble.Transition.Dip.defaultProperties
-- @table Noble.Transition.DipToBlack.defaultProperties

transition.panelImage = Graphics.image.new(400, 240, Graphics.kColorBlack)

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.x = 0
	self.y = 0
end