--- The next scene slides onto the screen from the bottom, covering up the previous scene.
-- @see Noble.Transition.SlideOn
-- @submodule Noble.Transition

class("SlideOnUp", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnUp
transition.name = "Slide On (Up)"

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 0
	self.y = 240
end