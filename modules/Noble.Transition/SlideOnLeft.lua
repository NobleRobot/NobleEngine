class("SlideOnLeft", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnLeft
transition.name = "Slide On (Left)"

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.x = 400
	self.y = 0
end