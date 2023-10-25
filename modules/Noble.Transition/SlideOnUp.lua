class("SlideOnUp", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SlideOnUp

transition.name = "Slide On (Up)"

function transition:init(__duration, __easeFunction)
	transition.super.init(self, __duration, 0, 240, __easeFunction)
end