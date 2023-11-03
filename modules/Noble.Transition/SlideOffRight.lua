---
-- @submodule Noble.Transition

class("SlideOffRight", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffRight
transition.name = "Slide Off (Right)"

--- The previous scene slides off the right side of the screen, revealing the next scene.
-- NOTE: The `x`, `y`, and `rotation` properties are locked.
-- @see Noble.Transition.SlideOff.defaultProperties
-- @table Noble.Transition.SlideOffRight.defaultProperties

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 400
	self.y = 0
	self.rotation = 0
end