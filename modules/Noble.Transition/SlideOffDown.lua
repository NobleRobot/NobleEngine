--- The previous scene slides off the bottom of the screen, revealing the next scene.
-- @see Noble.Transition.SlideOff
-- @submodule Noble.Transition

class("SlideOffDown", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffDown
transition.name = "Slide Off (Down)"

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = 0
	self.y = 240
end