--- The existing scene slides off the top of the screen, revealing the next scene.

class("SlideOffUp", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffUp
transition.name = "Slide Off (Up)"

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.x = 0
	self.y = -240
end