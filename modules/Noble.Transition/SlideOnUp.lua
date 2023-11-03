---
-- @submodule Noble.Transition

class("SlideOnUp", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnUp
transition.name = "Slide On (Up)"

--- The next scene slides onto the screen from the bottom, covering up the previous scene.
-- NOTE: The `x`, `y`, and `rotation` properties are locked.
-- @see Noble.Transition.SlideOn.defaultProperties
-- @table Noble.Transition.SlideOnUp.defaultProperties

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 0
	self.y = 240
	self.rotation = 0
end