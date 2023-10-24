class("SlideOnLeft", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SlideOnLeft

transition.name = "Slide On (Left)"

function transition:init(__duration,  __holdTime, __easeFunction)
	transition.super.init(self, __duration, __holdTime, 400, 0, __easeFunction)
end