class("SlideOffDown", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffDown

transition.name = "Slide Off (Down)"

function transition:init(__duration,  __holdTime, __easeFunction)
	transition.super.init(self, __duration, __holdTime, 0, 240, __easeFunction)
end