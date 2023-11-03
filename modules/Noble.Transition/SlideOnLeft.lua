---
-- @submodule Noble.Transition

class("SlideOnLeft", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnLeft
transition.name = "Slide On (Left)"

--- The next scene slides onto the screen right-to-left, covering up the previous scene.
-- NOTE: The `x`, `y`, and `rotation` properties are locked.
-- @see Noble.Transition.SlideOn.defaultProperties
-- @table Noble.Transition.SlideOnLeft.defaultProperties

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 400
	self.y = 0
	self.rotation = 0
end