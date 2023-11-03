--- The previous scene slides off the top of the screen, revealing the next scene.
-- @see Noble.Transition.SlideOff
-- @submodule Noble.Transition

class("SlideOffUp", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffUp
transition.name = "Slide Off (Up)"

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 0
	self.y = -240
end