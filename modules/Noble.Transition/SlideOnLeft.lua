--- The next scene slides onto the screen right-to-left, covering up the previous scene.
-- @see Noble.Transition.SlideOn
-- @submodule Noble.Transition

class("SlideOnLeft", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnLeft
transition.name = "Slide On (Left)"

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 400
	self.y = 0
end