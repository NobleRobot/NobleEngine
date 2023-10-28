--- The existing scene slides off the left side of the screen, revealing the next scene.

class("SlideOffLeft", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffLeft

transition.name = "Slide Off (Left)"

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.x = -400
	self.y = 0
end