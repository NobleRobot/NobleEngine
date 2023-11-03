--- The previous scene slides off the right side of the screen, revealing the next scene.
-- @see Noble.Transition.SlideOff
-- @submodule Noble.Transition

class("SlideOffRight", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffRight
transition.name = "Slide Off (Right)"

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 400
	self.y = 0
end