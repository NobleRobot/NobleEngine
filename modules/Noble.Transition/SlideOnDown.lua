--- The next scene slides onto the screen from the top, covering up the previous scene.
-- @see Noble.Transition.SlideOn
-- @submodule Noble.Transition

class("SlideOnDown", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnDown
transition.name = "Slide On (Down)"

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 0
	self.y = -240
end