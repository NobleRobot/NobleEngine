---
-- @submodule Noble.Transition

class("SlideOnRight", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnRight
transition.name = "Slide On (Right)"

--- The next scene slides onto the screen left-to-right, covering up the previous scene.
-- NOTE: The `x`, `y`, and `rotation` properties are locked.
-- @see Noble.Transition.SlideOn.defaultProperties
-- @table Noble.Transition.SlideOnRight.defaultProperties

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = -400
	self.y = 0
	self.rotation = 0
end