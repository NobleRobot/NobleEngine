---
-- @submodule Noble.Transition

class("SlideOffUp", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffUp
transition.name = "Slide Off (Up)"

--- The previous scene slides off the top of the screen, revealing the next scene.
-- NOTE: The `x`, `y`, and `rotation` properties are locked.
-- @see Noble.Transition.SlideOff.defaultProperties
-- @table Noble.Transition.SlideOffUp.defaultProperties

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 0
	self.y = -240
	self.rotation = 0
end