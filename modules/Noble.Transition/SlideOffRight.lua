--- The existing scene slides off the right side of the screen, revealing the next scene.

class("SlideOffRight", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffRight

transition.name = "Slide Off (Right)"

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.x = 400
	self.y = 0
end