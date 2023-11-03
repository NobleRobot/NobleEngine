---
-- @submodule Noble.Transition

class("SlideOffDown", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffDown
transition.name = "Slide Off (Down)"

--- The previous scene slides off the bottom of the screen, revealing the next scene.
-- NOTE: The `x`, `y`, and `rotation` properties are locked.
-- @see Noble.Transition.SlideOff.defaultProperties
-- @table Noble.Transition.SlideOffDown.defaultProperties

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 0
	self.y = 240
	self.rotation = 0
end