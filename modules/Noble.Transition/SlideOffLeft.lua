---
-- @submodule Noble.Transition

class("SlideOffLeft", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffLeft
transition.name = "Slide Off (Left)"

--- The previous scene slides off the left side of the screen, revealing the next scene.
-- NOTE: The `x`, `y`, and `rotation` properties are locked.
-- @see Noble.Transition.SlideOff.defaultProperties
-- @table Noble.Transition.SlideOffLeft.defaultProperties

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = -400
	self.y = 0
	self.rotation = 0
end