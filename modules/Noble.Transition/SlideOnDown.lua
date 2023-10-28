class("SlideOnDown", nil, Noble.Transition).extends(Noble.Transition.SlideOn)
local transition = Noble.Transition.SlideOnDown
transition.name = "Slide On (Down)"

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.x = 0
	self.y = -240
end