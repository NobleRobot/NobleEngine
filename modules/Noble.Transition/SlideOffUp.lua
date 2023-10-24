class("SlideOffUp", nil, Noble.Transition).extends(Noble.Transition.SlideOff)
local transition = Noble.Transition.SlideOffUp

transition.name = "Slide Off (Up)"

function transition:init(__duration,  __holdTime, __easeFunction)
	transition.super.init(self, __duration, __holdTime, 0, -240, __easeFunction)
end