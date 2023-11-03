--- The next scene slides onto the screen left-to-right, covering up the previous scene.
-- @see Noble.Transition.SlideOn
-- @submodule Noble.Transition

class("SlideOnRight", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnRight
transition.name = "Slide On (Right)"

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = -400
	self.y = 0
end