--- The existing scene slides off the bottom of the screen, revealing the next scene.

class("SlideOffDown", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffDown

transition.name = "Slide Off (Down)"

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.x = 0
	self.y = 240
end