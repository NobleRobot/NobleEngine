---
-- @submodule Noble.Transition

class("SlideOnDown", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnDown
transition.name = "Slide On (Down)"

--- The next scene slides onto the screen from the top, covering up the previous scene.
-- NOTE: The `x`, `y`, and `rotation` properties are locked.
-- @see Noble.Transition.SlideOn.defaultProperties
-- @table Noble.Transition.SlideOnDown.defaultProperties

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 0
	self.y = -240
	self.rotation = 0
end