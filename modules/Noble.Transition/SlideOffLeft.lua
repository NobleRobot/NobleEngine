--- The previous scene slides off the left side of the screen, revealing the next scene.
-- @see Noble.Transition.SlideOff
-- @submodule Noble.Transition

class("SlideOffLeft", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffLeft
transition.name = "Slide Off (Left)"

function transition:setProperties(__arguments)
	transition.super.setProperties(self, __arguments)
	self.x = -400
	self.y = 0
end